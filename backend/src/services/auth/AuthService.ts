import bcrypt from "bcrypt";
import jwt from "jsonwebtoken";
import { v4 as uuidv4 } from "uuid";
import { config } from "../../config";
import { UserRepository } from "../../repositories/UserRepository";
import { ProfileRepository } from "../../repositories/ProfileRepository";
import { RefreshTokenRepository } from "../../repositories/RefreshTokenRepository";
import { BadRequestError, ConflictError, UnauthorizedError } from "../../utils/errors";
import { EmailService } from "../email/EmailService";

export class AuthService {
  private userRepo: UserRepository;
  private profileRepo: ProfileRepository;
  private refreshTokenRepo: RefreshTokenRepository;
  private emailService: EmailService;

  constructor() {
    this.userRepo = new UserRepository();
    this.profileRepo = new ProfileRepository();
    this.refreshTokenRepo = new RefreshTokenRepository();
    this.emailService = new EmailService();
  }

  async register(email: string, password: string, firstName?: string, lastName?: string) {
    const existingUser = await this.userRepo.findByEmail(email);
    if (existingUser) {
      throw new ConflictError("Bu e-posta adresi ile kayıtlı bir kullanıcı zaten var");
    }

    const hashedPassword = await bcrypt.hash(password, 12);

    // 6 haneli doğrulama kodu üret ve 10 dakika geçerli olacak şekilde sakla.
    const verificationCode = this.emailService.generateVerificationCode();
    const verificationCodeExpiresAt = new Date(Date.now() + 10 * 60 * 1000);

    const user = await this.userRepo.create({
      email,
      passwordHash: hashedPassword,
      isEmailVerified: false,
      verificationCode,
      verificationCodeExpiresAt,
      profile: {
        create: {
          firstName,
          lastName,
        },
      },
    });

    // Doğrulama e-postasını gönder
    let emailSent = false;
    try {
      emailSent = await this.emailService.sendVerificationEmail(email, verificationCode);
    } catch (error) {
      console.error("Failed to send verification email:", error);
      // E-posta gönderimi başarısız olsa bile kayıt tamamlanır.
    }

    return {
      user: this.sanitize(user),
      emailSent,
      message: emailSent
        ? "Doğrulama kodu e-posta adresinize gönderildi"
        : "Kayıt oluşturuldu ancak doğrulama e-postası gönderilemedi. Lütfen daha sonra tekrar deneyin.",
      // SMTP yapılandırılmadığında (geliştirme) kod istemciye döner ki akış test edilebilsin.
      // Gerçek SMTP (EMAIL_MODE=smtp) aktif olduğunda bu alan asla dönmez.
      ...this.devCodeFallback(emailSent, verificationCode),
    };
  }

  /** Kullanıcı için yeni bir doğrulama kodu üretip tekrar gönderir. */
  async resendVerificationCode(email: string) {
    const user = await this.userRepo.findByEmail(email);
    if (!user) {
      throw new UnauthorizedError("Kullanıcı bulunamadı");
    }
    if (user.isEmailVerified) {
      return { emailSent: false, message: "Bu hesap zaten doğrulanmış." };
    }

    const verificationCode = this.emailService.generateVerificationCode();
    const verificationCodeExpiresAt = new Date(Date.now() + 10 * 60 * 1000);

    await this.userRepo.update(user.id, { verificationCode, verificationCodeExpiresAt });

    let emailSent = false;
    try {
      emailSent = await this.emailService.sendVerificationEmail(email, verificationCode);
    } catch (error) {
      console.error("Failed to resend verification email:", error);
    }

    return {
      emailSent,
      message: emailSent
        ? "Doğrulama kodu e-posta adresinize yeniden gönderildi"
        : "Doğrulama e-postası gönderilemedi. Lütfen daha sonra tekrar deneyin.",
      ...this.devCodeFallback(emailSent, verificationCode),
    };
  }

  /**
   * Geliştirme kolaylığı: e-posta gönderimi mümkün değilse (log modu) kodu
   * istemciye döndürür. Üretimde (EMAIL_MODE=smtp) her zaman boş nesne döner.
   */
  private devCodeFallback(emailSent: boolean, verificationCode: string) {
    if (!emailSent && config.email.mode === "log") {
      return { verificationCode, devCode: true };
    }
    return {};
  }

  async verifyEmail(email: string, code: string) {
    const user = await this.userRepo.findByEmail(email);
    if (!user) {
      throw new UnauthorizedError("Kullanıcı bulunamadı");
    }

    // Zaten doğrulanmış hesaplar için doğrudan giriş yap.
    if (!user.isEmailVerified) {
      if (!user.verificationCode || !user.verificationCodeExpiresAt) {
        throw new BadRequestError("Doğrulama kodu bulunamadı. Lütfen tekrar kayıt olun.");
      }
      if (new Date() > user.verificationCodeExpiresAt) {
        throw new BadRequestError("Doğrulama kodunun süresi doldu. Lütfen yeni bir kod isteyin.");
      }
      if (user.verificationCode !== code.trim()) {
        throw new BadRequestError("Doğrulama kodu hatalı");
      }
    }

    const updated = await this.userRepo.update(user.id, {
      isEmailVerified: true,
      verificationCode: null,
      verificationCodeExpiresAt: null,
    });

    const { accessToken, refreshToken } = await this.generateTokens(user.id);
    return { user: this.sanitize(updated), accessToken, refreshToken };
  }

  async login(email: string, password: string) {
    const user = await this.userRepo.findByEmail(email);
    if (!user || !user.passwordHash) {
      throw new UnauthorizedError("Invalid credentials");
    }

    const isValidPassword = await bcrypt.compare(password, user.passwordHash);
    if (!isValidPassword) {
      throw new UnauthorizedError("Invalid credentials");
    }

    const { accessToken, refreshToken } = await this.generateTokens(user.id);
    return { user: this.sanitize(user), accessToken, refreshToken };
  }

  async refreshTokens(refreshToken: string) {
    const storedToken = await this.refreshTokenRepo.findByToken(refreshToken);
    if (!storedToken || new Date() > storedToken.expiresAt) {
      throw new UnauthorizedError("Invalid or expired refresh token");
    }

    await this.refreshTokenRepo.deleteByToken(refreshToken);
    const { accessToken, refreshToken: newRefreshToken } = await this.generateTokens(storedToken.userId);
    return { accessToken, refreshToken: newRefreshToken, user: this.sanitize(storedToken.user) };
  }

  async logout(userId: string) {
    await this.refreshTokenRepo.deleteByUserId(userId);
  }

  /** Kullanıcı nesnesinden hassas alanları (şifre hash'i, doğrulama kodu) temizler. */
  private sanitize(user: any) {
    if (!user || typeof user !== "object") return user;
    const { passwordHash, verificationCode, verificationCodeExpiresAt, ...safe } = user;
    return safe;
  }

  private async generateTokens(userId: string) {
    const signOptions: jwt.SignOptions = {
      expiresIn: config.jwt.accessExpiresIn as any,
    };
    const accessToken = jwt.sign({ userId }, config.jwt.secret as jwt.Secret, signOptions);

    const refreshToken = uuidv4();
    const expiresAt = new Date();
    expiresAt.setDate(expiresAt.getDate() + 7);

    await this.refreshTokenRepo.create({
      user: { connect: { id: userId } },
      token: refreshToken,
      expiresAt,
    });

    return { accessToken, refreshToken };
  }
}
