import nodemailer from "nodemailer";
import { config } from "../../config";

export class EmailService {
  private transporter?: nodemailer.Transporter;

  constructor() {
    if (config.email.mode === "smtp" && config.email.user && config.email.password) {
      this.transporter = nodemailer.createTransport({
        host: "smtp.gmail.com",
        port: 587,
        secure: false,
        auth: {
          user: config.email.user,
          pass: config.email.password,
        },
      });
    }
  }

  async sendVerificationEmail(email: string, verificationCode: string) {
    const html = `
      <div style="font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto; padding: 20px;">
        <div style="background: linear-gradient(135deg, #0A1E3C 0%, #1A2A4A 100%); padding: 30px; border-radius: 10px; text-align: center;">
          <h1 style="color: #00A8E1; margin: 0;">OfficialAI</h1>
          <p style="color: #B8C5D6; margin: 10px 0;">E-posta Doğrulama Kodu</p>
        </div>
        <div style="padding: 30px; background: #f5f5f5; border-radius: 10px; margin-top: 20px;">
          <p style="color: #333; font-size: 16px;">Merhaba, hesabınızı doğrulamak için kodunuz:</p>
          <div style="background: #00A8E1; color: white; padding: 20px; border-radius: 5px; font-size: 32px; font-weight: bold; text-align: center; margin: 20px 0; letter-spacing: 5px;">
            ${verificationCode}
          </div>
          <p style="color: #666; font-size: 14px;">Bu kod 10 dakika içinde geçerlidir.</p>
        </div>
        <p style="color: #999; font-size: 12px; text-align: center; margin-top: 20px;">
          Eğer bu kodu siz istemediyseniz, bu e-postayı görmezden gelebilirsiniz.
        </p>
      </div>
    `;

    const subject = "OfficialAI - E-posta Doğrulama Kodu";

    if (!this.transporter || config.email.mode === "log") {
      console.log(`\n===== [EMAIL MODE=log] Gönderim Simüle Edildi =====
To: ${email}
Subject: ${subject}
Verification Code: ${verificationCode}
=========================================================\n`);
      return;
    }

    try {
      await this.transporter.sendMail({
        from: config.email.from,
        to: email,
        subject,
        html,
      });
    } catch (error) {
      console.error("Email gönderimi başarısız, fallback log:", error);
      console.log(`[EMAIL FALLBACK] Verification code for ${email}: ${verificationCode}`);
    }
  }

  generateVerificationCode(): string {
    return Math.floor(100000 + Math.random() * 900000).toString();
  }
}
