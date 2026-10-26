import nodemailer from "nodemailer";
import { config } from "../../config";

interface MailAttachment {
  filename: string;
  content: Buffer;
  contentType?: string;
}

interface DocumentMailInput {
  to: string;
  subject: string;
  title: string;
  message?: string;
  content: string;
  attachments?: MailAttachment[];
}

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

  /**
   * Gerçek SMTP gönderimi yapılandırılmış mı?
   * false ise e-postalar gönderilmez, yalnızca loglanır (geliştirme modu).
   */
  get isConfigured(): boolean {
    return !!this.transporter;
  }

  private fromAddress(): string {
    return config.email.user ? `OfficialAI <${config.email.user}>` : config.email.from;
  }

  /** Ortak gönderim yolu. Transporter yoksa veya hata olursa false döner. */
  private async send(options: {
    to: string;
    subject: string;
    html: string;
    text?: string;
    attachments?: MailAttachment[];
  }): Promise<boolean> {
    if (!this.transporter) {
      console.log(`\n===== [EMAIL MODE=${config.email.mode}] Gönderim Simüle Edildi =====
To: ${options.to}
Subject: ${options.subject}
${options.text ?? "(html içerik)"}
${options.attachments?.length ? `Ekler: ${options.attachments.map((a) => a.filename).join(", ")}` : ""}
=========================================================\n`);
      return false;
    }

    try {
      await this.transporter.sendMail({
        from: this.fromAddress(),
        to: options.to,
        subject: options.subject,
        html: options.html,
        text: options.text,
        attachments: options.attachments,
      });
      console.log(`✉️  E-posta gönderildi: ${options.to} — ${options.subject}`);
      return true;
    } catch (error) {
      console.error("Email gönderimi başarısız:", error);
      return false;
    }
  }

  async sendVerificationEmail(email: string, verificationCode: string): Promise<boolean> {
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
    return this.send({
      to: email,
      subject,
      html,
      text: `OfficialAI doğrulama kodunuz: ${verificationCode} (10 dakika geçerlidir)`,
    });
  }

  /**
   * Oluşturulan belgeyi (dilekçe vb.) PDF ekiyle birlikte alıcıya gönderir.
   * Kullanıcı uygulamadan çıkmadan belgeyi e-posta ile iletebilir.
   */
  async sendDocumentEmail(input: DocumentMailInput): Promise<boolean> {
    const { to, subject, title, message, content, attachments } = input;

    const safeMessage = (message ?? "").trim();
    const preview = content.length > 2000 ? `${content.slice(0, 2000)}…` : content;

    const html = `
      <div style="font-family: Arial, sans-serif; max-width: 640px; margin: 0 auto; padding: 20px; color: #1c1c1e;">
        <div style="background: #0A1E3C; padding: 24px; border-radius: 12px; text-align: center;">
          <h1 style="color: #00A8E1; margin: 0; font-size: 22px;">OfficialAI</h1>
          <p style="color: #B8C5D6; margin: 8px 0 0;">Belge Gönderimi</p>
        </div>
        ${safeMessage ? `<p style="font-size: 15px; line-height: 1.5;">${escapeHtml(safeMessage)}</p>` : ""}
        <h2 style="font-size: 17px; margin: 20px 0 8px;">${escapeHtml(title)}</h2>
        <div style="background: #f5f5f5; border-radius: 10px; padding: 18px; white-space: pre-wrap; font-size: 14px; line-height: 1.6;">${escapeHtml(preview)}</div>
        <p style="color: #8a8a8e; font-size: 12px; margin-top: 18px;">
          Belgenin tamamı ${attachments?.length ? "ekli PDF dosyasında" : "bu e-postanın içeriğindedir"}.
        </p>
      </div>
    `;

    return this.send({
      to,
      subject,
      html,
      text: `${safeMessage ? safeMessage + "\n\n" : ""}${title}\n\n${content}`,
      attachments,
    });
  }

  generateVerificationCode(): string {
    return Math.floor(100000 + Math.random() * 900000).toString();
  }
}

/** Kullanıcı içeriğini HTML'e gömmeden önce güvenli hale getirir. */
function escapeHtml(value: string): string {
  return value
    .replace(/&/g, "&amp;")
    .replace(/</g, "&lt;")
    .replace(/>/g, "&gt;")
    .replace(/"/g, "&quot;");
}
