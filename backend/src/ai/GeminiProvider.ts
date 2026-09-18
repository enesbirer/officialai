import { GoogleGenerativeAI, HarmCategory, HarmBlockThreshold } from "@google/generative-ai";
import { config } from "../config";
import { AIProvider, AIResponse, AIStreamChunk } from "./AIProvider";

export class GeminiProvider implements AIProvider {
  private genAI?: GoogleGenerativeAI;

  constructor() {
    if (config.ai.geminiApiKey) {
      this.genAI = new GoogleGenerativeAI(config.ai.geminiApiKey);
    }
  }

  private requireGenAI(): GoogleGenerativeAI {
    if (!this.genAI) {
      throw new Error("GEMINI_API_KEY is not configured");
    }
    return this.genAI;
  }

  private async withRetry<T>(fn: () => Promise<T>, maxRetries = 3, baseDelay = 1000): Promise<T> {
    let lastError: unknown = null;
    for (let attempt = 1; attempt <= maxRetries; attempt++) {
      try {
        return await fn();
      } catch (err: unknown) {
          lastError = err;
          if (attempt === maxRetries) break;
          const delay = baseDelay * Math.pow(2, attempt - 1);
          await new Promise(res => setTimeout(res, delay));
        }
    }
    throw lastError;
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

    const result = await this.withRetry(async () => {
      const genAI = this.requireGenAI();
      const model = genAI.getGenerativeModel({
        model: "gemini-2.0-flash",
        safetySettings: this.getSafetySettings(),
        generationConfig: {
          temperature: 0.7,
          topP: 0.95,
          topK: 40,
          maxOutputTokens: 8192,
        },
      });
      const res = await model.generateContent({
        contents: [
          { role: "user", parts: [{ text: systemPrompt }] },
          { role: "model", parts: [{ text: "Anladım. Verdiğin tüm güvenlik kurallarına, format talimatlarına ve bağlam bilgilerine uyacağım. Hazırım, lütfen kullanıcı isteğini ilet." }] },
          { role: "user", parts: [{ text: userPrompt }] },
        ],
      });
      return res;
    });

    const response = await result.response;
    const text = response.text();
    const usage = response.usageMetadata;
    const processingTime = Date.now() - startTime;

    return {
      content: text,
      processingTime,
      tokensUsed: usage ? (usage.promptTokenCount || 0) + (usage.candidatesTokenCount || 0) : undefined,
    };
  }

  async *generateStream(systemPrompt: string, userPrompt: string): AsyncGenerator<AIStreamChunk> {
    const startTime = Date.now();
    const genAI = this.requireGenAI();

    const model = genAI.getGenerativeModel({
      model: "gemini-2.0-flash",
      safetySettings: this.getSafetySettings(),
      generationConfig: {
        temperature: 0.7,
        topP: 0.95,
        topK: 40,
        maxOutputTokens: 8192,
      },
    });

    const result = await model.generateContentStream({
      contents: [
        { role: "user", parts: [{ text: systemPrompt }] },
        { role: "model", parts: [{ text: "Anladım. Verdiğin tüm güvenlik kurallarına, format talimatlarına ve bağlam bilgilerine uyacağım. Hazırım, lütfen kullanıcı isteğini ilet." }] },
        { role: "user", parts: [{ text: userPrompt }] },
      ],
    });

    for await (const chunk of result.stream) {
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
