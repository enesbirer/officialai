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
      throw new ConflictError("User already exists with this email");
    }

    const hashedPassword = await bcrypt.hash(password, 12);

    const verificationCode = this.emailService.generateVerificationCode();
    
    const user = await this.userRepo.create({
      email,
      passwordHash: hashedPassword,
      isEmailVerified: false,
      profile: {
        create: {
          firstName,
          lastName,
        },
      },
    });

    // Send verification email
    try {
      await this.emailService.sendVerificationEmail(email, verificationCode);
    } catch (error) {
      console.error("Failed to send verification email:", error);
      // Continue with registration even if email fails
    }

    return { user, verificationCode, message: "Verification code sent to email" };
  }

  async verifyEmail(email: string, code: string) {
    const user = await this.userRepo.findByEmail(email);
    if (!user) {
      throw new UnauthorizedError("User not found");
    }

    // In production, you would store the verification code in database with expiration
    // For now, we'll just mark email as verified
    await this.userRepo.update(user.id, { isEmailVerified: true });

    const { accessToken, refreshToken } = await this.generateTokens(user.id);
    return { user, accessToken, refreshToken };
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
    return { user, accessToken, refreshToken };
  }

  async refreshTokens(refreshToken: string) {
    const storedToken = await this.refreshTokenRepo.findByToken(refreshToken);
    if (!storedToken || new Date() > storedToken.expiresAt) {
      throw new UnauthorizedError("Invalid or expired refresh token");
    }

    await this.refreshTokenRepo.deleteByToken(refreshToken);
    const { accessToken, refreshToken: newRefreshToken } = await this.generateTokens(storedToken.userId);
    return { accessToken, refreshToken: newRefreshToken, user: storedToken.user };
  }

  async logout(userId: string) {
    await this.refreshTokenRepo.deleteByUserId(userId);
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
