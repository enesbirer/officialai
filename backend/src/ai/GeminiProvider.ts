import { GoogleGenerativeAI, HarmCategory, HarmBlockThreshold } from "@google/generative-ai";
import { config } from "../config";
import { AppError } from "../utils/errors";
import { HTTP_STATUS } from "../constants";
import { AIProvider, AIResponse, AIStreamChunk } from "./AIProvider";

// SDK'nın iç tip adlarını doğrudan içe aktarmak yerine, model metotlarının
// dönüş tiplerinden türetilir (SDK sürümünden bağımsız kalmak için).
type GeminiContentResult = Awaited<
  ReturnType<ReturnType<GoogleGenerativeAI["getGenerativeModel"]>["generateContent"]>
>;
type GeminiStreamResult = Awaited<
  ReturnType<ReturnType<GoogleGenerativeAI["getGenerativeModel"]>["generateContentStream"]>
>;

// Kullanımdan kaldırılmış (artık desteklenmeyen) model adları.
// Bu modeller 404 döndürür ve yeniden denenmesi anlamsızdır.
const RETIRED_MODELS = [
  "gemini-1.0",
  "gemini-1.5",
  "gemini-2.0",
  "gemini-pro-vision",
];

export class GeminiProvider implements AIProvider {
  private genAI?: GoogleGenerativeAI;
  private modelName: string;

  constructor() {
    this.modelName = config.ai.geminiModel;
    if (RETIRED_MODELS.some((m) => this.modelName.startsWith(m))) {
      console.warn(
        `[GeminiProvider] UYARI: "${this.modelName}" kullanımdan kaldırılmış bir model. ` +
          `GEMINI_MODEL ortam değişkenini güncel bir modelle (örn. "gemini-3.8-flash") ayarlayın.`
      );
    }
    if (config.ai.geminiApiKey) {
      this.genAI = new GoogleGenerativeAI(config.ai.geminiApiKey);
    }
  }

  /**
   * Denenecek model listesi: birincil model + yedek modeller.
   * Kullanımdan kaldırılan bir model 404 döndürürse sıradaki model denenir.
   */
  private candidateModels(): string[] {
    const list = [this.modelName, ...(config.ai.geminiFallbackModels || [])];
    return Array.from(new Set(list.filter(Boolean)));
  }

  /** Hatanın kullanılamayan/geçersiz model kaynaklı olup olmadığını belirler. */
  private isModelUnavailable(err: unknown): boolean {
    const e = err as { status?: number; message?: string; response?: { status?: number } };
    const status = e?.status ?? e?.response?.status;
    const msg = String(e?.message ?? "");
    return (
      status === 404 ||
      /not found|no longer available|is not supported|does not support|INVALID_ARGUMENT/i.test(msg)
    );
  }

  /**
   * Hatanın model kotası/rate limit kaynaklı olup olmadığını belirler.
   * Gemini kotası proje ve model bazında ayrı tutulduğu için bir model
   * limite takıldığında yedek model genellikle çalışmaya devam eder.
   */
  private isRateLimited(err: unknown): boolean {
    const e = err as { status?: number; message?: string; response?: { status?: number } };
    const status = e?.status ?? e?.response?.status;
    const msg = String(e?.message ?? "");
    return status === 429 || /quota|rate limit|RESOURCE_EXHAUSTED/i.test(msg);
  }

  /** Hatadan sonra yedek modelin denenmesi gerekip gerekmediğini belirler. */
  private shouldTryNextModel(err: unknown): boolean {
    return this.isModelUnavailable(err) || this.isRateLimited(err);
  }

  private requireGenAI(): GoogleGenerativeAI {
    if (!this.genAI) {
      throw new AppError(
        "Yapay zekâ servisi şu anda yapılandırılmamış. Lütfen daha sonra tekrar deneyin.",
        HTTP_STATUS.SERVICE_UNAVAILABLE
      );
    }
    return this.genAI;
  }

  /** Hatanın yeniden denenmeye uygun olup olmadığını belirler. */
  private isRetryable(err: unknown): boolean {
    const e = err as {
      status?: number;
      code?: number;
      message?: string;
      response?: { status?: number };
    };
    const status = e?.status ?? e?.response?.status ?? e?.code;
    // 429 (kota) aynı modelde saniyeler içinde düzelmez; tekrar denemek yerine
    // yedek modele geçilir (bkz. shouldTryNextModel).
    if (typeof status === "number") {
      return status === 500 || status === 502 || status === 503 || status === 504;
    }
    const msg = String(e?.message ?? "");
    if (this.isRateLimited(err)) {
      return false;
    }
    // Geçersiz model / geçersiz anahtar / hatalı istek -> tekrar denemek anlamsız
    if (/404|not found|no longer available|is not supported|API key not valid|API_KEY_INVALID|INVALID_ARGUMENT|400/i.test(msg)) {
      return false;
    }
    return true;
  }

  /** Ham SDK hatasını kullanıcıya gösterilebilir güvenli bir mesaja çevirir. */
  private toFriendlyError(err: unknown): never {
    const e = err as { status?: number; message?: string; response?: { status?: number } };
    const status = e?.status ?? e?.response?.status;
    const rawMessage = String(e?.message ?? "");

    if (status === 404 || /no longer available|not found/i.test(rawMessage)) {
      console.error("[GeminiProvider] Model kullanılamıyor:", this.modelName);
      throw new AppError(
        "Yapay zekâ modeli şu anda kullanılamıyor. Lütfen daha sonra tekrar deneyin.",
        HTTP_STATUS.SERVICE_UNAVAILABLE
      );
    }
    if (status === 429 || /quota|rate limit|RESOURCE_EXHAUSTED/i.test(rawMessage)) {
      throw new AppError(
        "Yapay zekâ servisi şu anda yoğun. Lütfen birkaç dakika sonra tekrar deneyin.",
        HTTP_STATUS.TOO_MANY_REQUESTS
      );
    }
    if (status === 403 || /API key not valid|API_KEY_INVALID|permission/i.test(rawMessage)) {
      console.error("[GeminiProvider] API anahtarı geçersiz veya yetkisiz.");
      throw new AppError(
        "Yapay zekâ servisine erişilemiyor. Lütfen daha sonra tekrar deneyin.",
        HTTP_STATUS.SERVICE_UNAVAILABLE
      );
    }
    if (/timeout|ETIMEDOUT|ECONNRESET|ENOTFOUND|fetch failed/i.test(rawMessage)) {
      throw new AppError(
        "Yapay zekâ servisine bağlanılamadı. İnternet bağlantınızı kontrol edip tekrar deneyin.",
        HTTP_STATUS.GATEWAY_TIMEOUT
      );
    }

    console.error("[GeminiProvider] Beklenmeyen hata:", rawMessage);
    throw new AppError(
      "Dilekçe oluşturulamadı. Lütfen tekrar deneyin.",
      HTTP_STATUS.BAD_GATEWAY
    );
  }

  private async withRetry<T>(fn: () => Promise<T>, maxRetries = 3, baseDelay = 1000): Promise<T> {
    let lastError: unknown = null;
    for (let attempt = 1; attempt <= maxRetries; attempt++) {
      try {
        return await fn();
      } catch (err: unknown) {
        lastError = err;
        // Kalıcı hatalarda (geçersiz model, yetki vb.) tekrar denemeyi bırak.
        if (attempt === maxRetries || !this.isRetryable(err)) break;
        const delay = baseDelay * Math.pow(2, attempt - 1);
        await new Promise(res => setTimeout(res, delay));
      }
    }
    // Ham hatayı yukarı fırlat: çağıran taraf model yedeklemesi yapabilsin.
    throw lastError;
  }

  /**
   * Model üretim ayarları tek noktadan yönetilir; kod içinde dağınık
   * generationConfig tanımı bırakılmaz. Ürettiğimiz belgeler en fazla 1-2
   * sayfa olduğundan 2048 token yeterlidir ve kontrolsüz uzun üretimi engeller.
   */
  private generationConfig() {
    return {
      temperature: 0.7,
      topP: 0.95,
      topK: 40,
      maxOutputTokens: 2048,
    };
  }

  private getSafetySettings() {
    return [
      {
        category: HarmCategory.HARM_CATEGORY_HARASSMENT,
        threshold: HarmBlockThreshold.BLOCK_MEDIUM_AND_ABOVE,
      },
      {
        category: HarmCategory.HARM_CATEGORY_HATE_SPEECH,
        threshold: HarmBlockThreshold.BLOCK_MEDIUM_AND_ABOVE,
      },
      {
        category: HarmCategory.HARM_CATEGORY_SEXUALLY_EXPLICIT,
        threshold: HarmBlockThreshold.BLOCK_MEDIUM_AND_ABOVE,
      },
      {
        category: HarmCategory.HARM_CATEGORY_DANGEROUS_CONTENT,
        threshold: HarmBlockThreshold.BLOCK_MEDIUM_AND_ABOVE,
      },
    ];
  }

  async generate(systemPrompt: string, userPrompt: string): Promise<AIResponse> {
    const startTime = Date.now();

    const models = this.candidateModels();
    let result: GeminiContentResult | undefined;
    let lastError: unknown = null;

    for (const modelName of models) {
      try {
        result = await this.withRetry(async () => {
          const genAI = this.requireGenAI();
          const model = genAI.getGenerativeModel({
            model: modelName,
            safetySettings: this.getSafetySettings(),
            generationConfig: this.generationConfig(),
          });
          return model.generateContent({
            contents: [
              { role: "user", parts: [{ text: systemPrompt }] },
              { role: "model", parts: [{ text: "Anladım. Verdiğin tüm güvenlik kurallarına, format talimatlarına ve bağlam bilgilerine uyacağım. Hazırım, lütfen kullanıcı isteğini ilet." }] },
              { role: "user", parts: [{ text: userPrompt }] },
            ],
          });
        });
        // Çalışan modeli hatırla (sonraki çağrılarda doğrudan kullanılır).
        this.modelName = modelName;
        break;
      } catch (err) {
        lastError = err;
        if (!this.shouldTryNextModel(err)) break;
        console.warn(
          `[GeminiProvider] "${modelName}" modeli kullanılamıyor veya kotası dolu, sıradaki model deneniyor.`
        );
      }
    }

    if (!result) {
      this.toFriendlyError(lastError);
    }

    const response = await result.response;
    let text = "";
    try {
      text = response.text();
    } catch {
      // Güvenlik filtresi veya boş yanıt
      throw new AppError(
        "İçerik oluşturulamadı. Lütfen girdiğiniz bilgileri gözden geçirip tekrar deneyin.",
        HTTP_STATUS.UNPROCESSABLE_ENTITY
      );
    }
    if (!text || !text.trim()) {
      throw new AppError(
        "Yapay zekâ boş bir yanıt döndürdü. Lütfen tekrar deneyin.",
        HTTP_STATUS.BAD_GATEWAY
      );
    }
    const usage = response.usageMetadata;
    const processingTime = Date.now() - startTime;

    return {
      content: text.trim(),
      processingTime,
      tokensUsed: usage ? (usage.promptTokenCount || 0) + (usage.candidatesTokenCount || 0) : undefined,
    };
  }

  async *generateStream(systemPrompt: string, userPrompt: string): AsyncGenerator<AIStreamChunk> {
    const startTime = Date.now();
    const models = this.candidateModels();
    let streamResult: GeminiStreamResult | undefined;
    let lastError: unknown = null;

    for (const modelName of models) {
      try {
        const genAI = this.requireGenAI();
        const model = genAI.getGenerativeModel({
          model: modelName,
          safetySettings: this.getSafetySettings(),
          generationConfig: this.generationConfig(),
        });
        streamResult = await model.generateContentStream({
          contents: [
            { role: "user", parts: [{ text: systemPrompt }] },
            { role: "model", parts: [{ text: "Anladım. Verdiğin tüm güvenlik kurallarına, format talimatlarına ve bağlam bilgilerine uyacağım. Hazırım, lütfen kullanıcı isteğini ilet." }] },
            { role: "user", parts: [{ text: userPrompt }] },
          ],
        });
        this.modelName = modelName;
        break;
      } catch (err) {
        lastError = err;
        if (!this.shouldTryNextModel(err)) break;
        console.warn(
          `[GeminiProvider] "${modelName}" modeli kullanılamıyor veya kotası dolu, sıradaki model deneniyor.`
        );
      }
    }

    if (!streamResult) {
      this.toFriendlyError(lastError);
    }

    for await (const chunk of streamResult!.stream) {
      const chunkText = chunk.text();
      yield {
        content: chunkText,
        processingTime: Date.now() - startTime,
        done: false,
      };
    }

    const processingTime = Date.now() - startTime;
    yield {
      content: "",
      processingTime,
      done: true,
    };
  }
}
