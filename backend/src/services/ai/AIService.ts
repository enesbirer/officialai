import { AIProvider, AIResponse, AIStreamChunk } from "../../ai/AIProvider";
import { GeminiProvider } from "../../ai/GeminiProvider";
import { DemoAIProvider } from "../../ai/DemoAIProvider";
import { PromptBuilder } from "../../prompts/PromptBuilder";
import {
  PETITION_SYSTEM_PROMPT_BASE,
  EMAIL_SYSTEM_PROMPT_BASE,
  CV_SYSTEM_PROMPT_BASE,
  CHAT_SYSTEM_PROMPT_BASE,
  OCR_ANALYSIS_SYSTEM_PROMPT,
  DEFAULT_SAFETY_RULES,
} from "../../prompts/promptTemplates";
import { config } from "../../config";
import prisma from "../../config/prisma";

interface CVData {
  personalInfo: any;
  education: any[];
  experience: any[];
  skills: string[];
}

export class AIService {
  private provider: AIProvider;

  constructor() {
    this.provider = config.ai.geminiApiKey ? new GeminiProvider() : new DemoAIProvider();
  }

  private applySafetyRules(builder: PromptBuilder): PromptBuilder {
    DEFAULT_SAFETY_RULES.forEach((rule) => builder.addSafetyRule(rule));
    return builder;
  }

  private async savePromptHistory(params: {
    userId: string;
    type: string;
    systemPrompt: string;
    userPrompt: string;
    response: string;
    processingTime: number;
    tokensUsed?: number;
    petitionId?: string;
    emailId?: string;
    cvId?: string;
    conversationId?: string;
  }) {
    try {
      await prisma.promptHistory.create({
        data: {
          userId: params.userId,
          type: params.type,
          provider: config.ai.provider,
          systemPrompt: params.systemPrompt,
          userPrompt: params.userPrompt,
          response: params.response,
          processingTime: params.processingTime,
          tokensUsed: params.tokensUsed,
          petitionId: params.petitionId,
          emailId: params.emailId,
          cvId: params.cvId,
          conversationId: params.conversationId,
        },
      });
    } catch (err) {
      console.warn("Prompt history kaydedilemedi:", err);
    }
  }

  async getPetitionCategories() {
    return prisma.petitionCategory.findMany({
      where: { isActive: true },
      orderBy: { name: "asc" },
    });
  }

  async getTemplatesByCategory(categoryId?: string, type?: string) {
    return prisma.template.findMany({
      where: {
        isActive: true,
        ...(categoryId ? { petitionCategoryId: categoryId } : {}),
        ...(type ? { type } : {}),
      },
      include: { category: true, petitionCategory: true },
      orderBy: { name: "asc" },
    });
  }

  async generatePetition(
    userId: string,
    categoryId: string,
    answers: Record<string, string>
  ): Promise<{ content: string; petitionId: string; documentId: string; title: string }> {
    const category = await prisma.petitionCategory.findUnique({
      where: { id: categoryId },
    });

    const template = await prisma.template.findFirst({
      where: { petitionCategoryId: categoryId, isActive: true },
    });

    const categoryName = category?.name || "Genel Başvuru";

    const builder = new PromptBuilder()
      .setSystemPrompt(PETITION_SYSTEM_PROMPT_BASE)
      .setUserPrompt(`
Aşağıdaki bilgileri kullanarak TAM ve PROFESYONEL bir TÜRKÇE resmi dilekçe/dava dilekçesi oluştur.

Kategori: ${categoryName}
Kullanıcı Cevapları / Bilgileri:
${Object.entries(answers)
  .map(([key, value]) => `- ${key}: ${value}`)
  .join("\n")}

${template ? `Şablon Yapısı (başvuru): ${JSON.stringify(template.structure)}` : ""}

Tüm alanları doldur, eksik bilgi olursa mantıklı varsayım yap ve [BELİRTİNİZ] ile işaretle. 
Tam formatı, tüm bölümleriyle birlikte ver. Başlık, muhatap, bilgiler, konu, açıklama, talep, dayanak, kanıt, imza, ekler, nüsha hepsi olsun.
`);

    if (category) builder.addPetitionCategory(categoryName, answers);
    this.applySafetyRules(builder);
    const { systemPrompt, userPrompt } = builder.build();

    const startTime = Date.now();
    const response: AIResponse = await this.provider.generate(systemPrompt, userPrompt);
    const processingTime = Date.now() - startTime;

    const titleMatch = response.content.match(/^#*\s*(.+)$/m) ||
      response.content.match(/={2,}\s*(.+?)\s*={2,}/);
    const title = titleMatch ? titleMatch[1].trim().slice(0, 80) : `${categoryName} - Oluşturulan Dilekçe`;

    const petition = await prisma.petition.create({
      data: {
        userId,
        categoryId,
        title,
        content: response.content,
        metadata: { answers, categoryName },
      },
    });

    await this.savePromptHistory({
      userId,
      type: "petition",
      systemPrompt,
      userPrompt,
      response: response.content,
      processingTime,
      tokensUsed: response.tokensUsed,
      petitionId: petition.id,
    });

    return {
      content: response.content,
      petitionId: petition.id,
      documentId: petition.id,
      title: petition.title,
    };
  }

  async generateEmail(
    userId: string,
    type: string,
    tone: string,
    language: string,
    context: string,
    recipient?: string,
    senderName?: string
  ): Promise<{ content: string; emailId: string; documentId: string; subject: string }> {
    const builder = new PromptBuilder()
      .setSystemPrompt(EMAIL_SYSTEM_PROMPT_BASE)
      .setUserPrompt(`
Aşağıdaki bilgilere göre PROFESYONEL bir e-posta oluştur:

E-posta Tipi: ${type}
Ton / Üslup: ${tone}
Dil: ${language}
Muhatap / Alıcı: ${recipient || "[Alıcı belirtilecek]"}
Gönderen Adı: ${senderName || "[Gönderen adı belirtilecek]"}
Bağlam / İçerik Açıklaması: ${context}

Tüm formatı koru: Konu, selamlama, açılış, gövde 1-2 paragraf, çağrı noktası, kapanış, imza.
`);

    builder.addContextNote(`Tone/Tarz: ${tone} | Language/Dil: ${language} | Type/Tip: ${type}`);
    this.applySafetyRules(builder);
    const { systemPrompt, userPrompt } = builder.build();

    const startTime = Date.now();
    const response = await this.provider.generate(systemPrompt, userPrompt);
    const processingTime = Date.now() - startTime;

    const subjectMatch = response.content.match(/KONU[:\s]+(.+)$/im) ||
      response.content.match(/SUBJECT[:\s]+(.+)$/im) ||
      response.content.match(/^#\s+(.+)$/m);
    const subject = subjectMatch ? subjectMatch[1].trim().slice(0, 120) : `Oluşturulan ${type} E-postası`;

    const email = await prisma.generatedEmail.create({
      data: {
        userId,
        type,
        tone,
        language,
        subject,
        content: response.content,
      },
    });

    await this.savePromptHistory({
      userId,
      type: "email",
      systemPrompt,
      userPrompt,
      response: response.content,
      processingTime,
      tokensUsed: response.tokensUsed,
      emailId: email.id,
    });

    return {
      content: response.content,
      emailId: email.id,
      documentId: email.id,
      subject,
    };
  }

  async generateCV(
    userId: string,
    personalInfo: any,
    education: any[],
    experience: any[],
    skills: string[],
    templateId?: string
  ): Promise<{ content: string; cvId: string; documentId: string; title: string }> {
    const language = personalInfo?.language || "tr";
    const builder = new PromptBuilder()
      .setSystemPrompt(CV_SYSTEM_PROMPT_BASE)
      .setUserPrompt(`
Aşağıdaki bilgilere göre ATS uyumlu, PROFESYONEL bir CV/Özgeçmiş oluştur. DİL: ${language === "tr" ? "TÜRKÇE" : "ENGLISH"}.

Kişisel Bilgiler:
${JSON.stringify(personalInfo, null, 2)}

Eğitim Bilgileri:
${JSON.stringify(education, null, 2)}

İş Deneyimi:
${JSON.stringify(experience, null, 2)}

Yetenekler / Skills:
${skills.map((s, i) => `${i + 1}. ${s}`).join("\n")}

${templateId ? `CV Şablon ID: ${templateId}` : "Standart tek sütun şablon kullan."}

Tüm CV bölümlerini eksiksiz doldur. Profesyonel özet, iş deneyimi başarı maddeleri, eğitim, yetenekler. Uzunluk 1-2 sayfa olsun.
`);

    this.applySafetyRules(builder);
    builder.addContextNote(`Dil: ${language}`);
    const { systemPrompt, userPrompt } = builder.build();

    const startTime = Date.now();
    const response = await this.provider.generate(systemPrompt, userPrompt);
    const processingTime = Date.now() - startTime;

    const fullName = [personalInfo?.firstName, personalInfo?.lastName]
      .filter(Boolean)
      .join(" ") || "CV";
    const title = `${fullName} - Özgeçmiş`;

    const cv = await prisma.generatedCV.create({
      data: {
        userId,
        templateId,
        title,
        content: response.content,
        personalInfo,
        education,
        experience,
        skills,
      },
    });

    await this.savePromptHistory({
      userId,
      type: "cv",
      systemPrompt,
      userPrompt,
      response: response.content,
      processingTime,
      tokensUsed: response.tokensUsed,
      cvId: cv.id,
    });

    return {
      content: response.content,
      cvId: cv.id,
      documentId: cv.id,
      title: cv.title,
    };
  }

  async analyzeOCR(
    userId: string,
    ocrText: string,
    customInstructions?: string
  ): Promise<{
    content: string;
    ocrDocumentId?: string;
    documentId?: string;
    fullText: string;
    summary: string;
    keywords: string[];
    importantDetails: string[];
    actionItems: string[];
    risks: string[];
    suggestions: string[];
  }> {
    const builder = new PromptBuilder()
      .setSystemPrompt(OCR_ANALYSIS_SYSTEM_PROMPT)
      .setUserPrompt(`
Aşağıdaki OCR ile okunmuş metni analiz et. Tüm kurallara uyarak formatı uygula.

OKUNMUŞ METİN (ham):
"""${ocrText}"""

${customInstructions ? `Ekstra Talimatlar: ${customInstructions}` : ""}
`);

    this.applySafetyRules(builder);
    const { systemPrompt, userPrompt } = builder.build();

    const startTime = Date.now();
    const response = await this.provider.generate(systemPrompt, userPrompt);
    const processingTime = Date.now() - startTime;

    let ocrDocumentId: string | undefined = undefined;
    try {
      const ocrDoc = await prisma.oCRDocument.create({
        data: {
          userId,
          content: response.content,
          metadata: { rawText: ocrText, processingTime, customInstructions },
        },
      });
      ocrDocumentId = ocrDoc.id;
    } catch (err) {
      console.warn("OCR document kaydedilemedi:", err);
    }

    await this.savePromptHistory({
      userId,
      type: "ocr-analysis",
      systemPrompt,
      userPrompt,
      response: response.content,
      processingTime,
      tokensUsed: response.tokensUsed,
    });

    const structured = parseOcrAnalysisToMap(response.content);

    return {
      content: response.content,
      ocrDocumentId,
      documentId: ocrDocumentId,
      fullText: response.content,
      summary: structured.summary,
      keywords: structured.keywords,
      importantDetails: structured.importantDetails,
      actionItems: structured.actionItems,
      risks: structured.risks,
      suggestions: structured.suggestions,
    };
  }

  async chat(
    userId: string,
    userMessage: string,
    history: Array<{ role: string; content: string }> = [],
    conversationId?: string
  ): Promise<{ content: string; conversationId: string; messageId: string }> {
    let workingConversationId = conversationId;
    if (!workingConversationId) {
      const conv = await prisma.aIConversation.create({
        data: {
          userId,
          title: userMessage.trim().slice(0, 80) || "Yeni Sohbet",
        },
      });
      workingConversationId = conv.id;
    } else {
      await prisma.aIConversation.update({
        where: { id: workingConversationId, userId },
        data: { updatedAt: new Date() },
      });
    }

    const userMsg = await prisma.aIMessage.create({
      data: {
        conversationId: workingConversationId,
        role: "user",
        content: userMessage,
      },
    });

    const recentMessages = (await prisma.aIMessage.findMany({
      where: { conversationId: workingConversationId },
      orderBy: { createdAt: "asc" },
      take: 20,
    })).map(m => ({ role: m.role, content: m.content }));

    const builder = new PromptBuilder()
      .setSystemPrompt(CHAT_SYSTEM_PROMPT_BASE)
      .setUserPrompt(`Kullanıcı Mesajı: ${userMessage}`);

    if (recentMessages.length > 0) {
      builder.setChatHistory(recentMessages.slice(0, -1));
    }
    this.applySafetyRules(builder);
    const { systemPrompt, userPrompt } = builder.build();

    const startTime = Date.now();
    const response = await this.provider.generate(systemPrompt, userPrompt);
    const processingTime = Date.now() - startTime;

    const assistantMsg = await prisma.aIMessage.create({
      data: {
        conversationId: workingConversationId,
        role: "assistant",
        content: response.content,
      },
    });

    await this.savePromptHistory({
      userId,
      type: "chat",
      systemPrompt,
      userPrompt,
      response: response.content,
      processingTime,
      tokensUsed: response.tokensUsed,
      conversationId: workingConversationId,
    });

    return {
      content: response.content,
      conversationId: workingConversationId,
      messageId: assistantMsg.id,
    };
  }

  async streamChat(
    userId: string,
    userMessage: string,
    history: Array<{ role: string; content: string }> = [],
    conversationId?: string
  ): Promise<{ stream: AsyncGenerator<AIStreamChunk>; conversationId: string }> {
    let workingConversationId = conversationId;
    if (!workingConversationId) {
      const conv = await prisma.aIConversation.create({
        data: {
          userId,
          title: userMessage.trim().slice(0, 80) || "Yeni Sohbet",
        },
      });
      workingConversationId = conv.id;
    }

    await prisma.aIMessage.create({
      data: {
        conversationId: workingConversationId,
        role: "user",
        content: userMessage,
      },
    });

    const builder = new PromptBuilder()
      .setSystemPrompt(CHAT_SYSTEM_PROMPT_BASE)
      .setUserPrompt(`Kullanıcı Mesajı: ${userMessage}`);

    if (history.length > 0) builder.setChatHistory(history);
    this.applySafetyRules(builder);
    const { systemPrompt, userPrompt } = builder.build();

    if (this.provider.generateStream) {
      return {
        stream: this.provider.generateStream(systemPrompt, userPrompt),
        conversationId: workingConversationId,
      };
    }

    const fullResp = await this.provider.generate(systemPrompt, userPrompt);
    const asyncGenerator = (async function* () {
      yield { content: fullResp.content, processingTime: fullResp.processingTime, done: false } as AIStreamChunk;
      yield { content: "", processingTime: fullResp.processingTime, done: true } as AIStreamChunk;
    })();

    return { stream: asyncGenerator, conversationId: workingConversationId };
  }

  async getUserDocuments(userId: string, type?: string) {
    const results: any[] = [];

    const petitions = await prisma.petition.findMany({
      where: { userId, deletedAt: null, ...(type && type !== "petition" ? {} : {}) },
      include: { category: true },
      orderBy: { createdAt: "desc" },
      take: type && type !== "petition" ? 0 : 50,
    });
    petitions.forEach(p => {
      if (!type || type === "petition") {
        results.push({
          id: p.id,
          type: "petition",
          title: p.title,
          content: p.content,
          isFavorite: p.isFavorite,
          createdAt: p.createdAt,
          category: p.category?.name || null,
        });
      }
    });

    const emails = await prisma.generatedEmail.findMany({
      where: { userId, deletedAt: null },
      orderBy: { createdAt: "desc" },
      take: type && type !== "email" ? 0 : 50,
    });
    emails.forEach(e => {
      if (!type || type === "email") {
        results.push({
          id: e.id,
          type: "email",
          title: e.subject,
          content: e.content,
          isFavorite: e.isFavorite,
          createdAt: e.createdAt,
          meta: { tone: e.tone, language: e.language },
        });
      }
    });

    const cvs = await prisma.generatedCV.findMany({
      where: { userId, deletedAt: null },
      orderBy: { createdAt: "desc" },
      take: type && type !== "cv" ? 0 : 50,
    });
    cvs.forEach(c => {
      if (!type || type === "cv") {
        results.push({
          id: c.id,
          type: "cv",
          title: c.title,
          content: c.content,
          isFavorite: c.isFavorite,
          createdAt: c.createdAt,
        });
      }
    });

    return results.sort((a, b) => new Date(b.createdAt).getTime() - new Date(a.createdAt).getTime());
  }

  async getFavorites(userId: string) {
    const favs = await prisma.favoriteDocument.findMany({
      where: { userId },
      orderBy: { createdAt: "desc" },
      take: 100,
    });

    const results = [];
    for (const fav of favs) {
      let doc: any = null;
      if (fav.documentType === "petition") {
        doc = await prisma.petition.findUnique({ where: { id: fav.documentId } });
      } else if (fav.documentType === "email") {
        doc = await prisma.generatedEmail.findUnique({ where: { id: fav.documentId } });
      } else if (fav.documentType === "cv") {
        doc = await prisma.generatedCV.findUnique({ where: { id: fav.documentId } });
      }
      if (doc) {
        results.push({
          favoriteId: fav.id,
          id: fav.documentId,
          type: fav.documentType,
          title: doc.title || doc.subject || "Belge",
          content: doc.content,
          isFavorite: true,
          createdAt: fav.createdAt,
        });
      }
    }
    return results;
  }

  async toggleFavorite(userId: string, documentId: string, documentType: "petition" | "email" | "cv") {
    const existing = await prisma.favoriteDocument.findUnique({
      where: {
        userId_documentId_documentType: { userId, documentId, documentType },
      },
    });

    const updateDocFavorite = async (value: boolean) => {
      if (documentType === "petition") {
        await prisma.petition.update({ where: { id: documentId }, data: { isFavorite: value } });
      } else if (documentType === "email") {
        await prisma.generatedEmail.update({ where: { id: documentId }, data: { isFavorite: value } });
      } else {
        await prisma.generatedCV.update({ where: { id: documentId }, data: { isFavorite: value } });
      }
    };

    if (existing) {
      await prisma.favoriteDocument.delete({ where: { id: existing.id } });
      await updateDocFavorite(false);
      return { favorited: false, isFavorite: false };
    } else {
      await prisma.favoriteDocument.create({ data: { userId, documentId, documentType } });
      await updateDocFavorite(true);
      return { favorited: true, isFavorite: true };
    }
  }

  async getConversations(userId: string) {
    return prisma.aIConversation.findMany({
      where: { userId, deletedAt: null },
      orderBy: { updatedAt: "desc" },
      take: 50,
    });
  }

  async getConversationMessages(userId: string, conversationId: string) {
    const conv = await prisma.aIConversation.findUnique({
      where: { id: conversationId, userId },
      include: { messages: { orderBy: { createdAt: "asc" }, take: 100 } },
    });
    if (!conv) throw new Error("Conversation not found");
    return { conversation: conv, messages: conv.messages };
  }
}

interface OcrStructured {
  summary: string;
  keywords: string[];
  importantDetails: string[];
  actionItems: string[];
  risks: string[];
  suggestions: string[];
}

function stripLeadingEmoji(s: string): string {
  return s.replace(/^[\s\u{1F300}-\u{1FAFF}\u{2600}-\u{27BF}\u{1F1E6}-\u{1F1FF}]+/u, "").trim();
}

function extractBulletBlock(text: string, sectionKeywords: RegExp, nextKeywords: RegExp): string[] {
  const lines = text.split(/\r?\n/);
  const out: string[] = [];
  let capture = false;
  for (const rawLine of lines) {
    const line = rawLine.trim();
    if (!line) continue;
    if (!capture) {
      if (sectionKeywords.test(line)) capture = true;
      continue;
    }
    if (nextKeywords.test(line)) break;
    const cleaned = stripLeadingEmoji(line)
      .replace(/^(\d+\.\s*|\u25A1\s*|\u25A0\s*|\u2022\s*|[-*]\s*)/, "")
      .replace(/\|[^\n|]*$/g, "")
      .trim();
    if (cleaned && cleaned.length > 2) out.push(cleaned);
    if (out.length >= 20) break;
  }
  return out;
}

function parseOcrAnalysisToMap(text: string): OcrStructured {
  const fallback = () => {
    const lines = text
      .split(/\r?\n/)
      .map((l) => stripLeadingEmoji(l).trim())
      .filter((l) => l.length > 10);
    return {
      summary: lines[0] || "Analiz özeti hazırlanmadı.",
      keywords: lines.slice(1, 6),
      importantDetails: lines.slice(1, 8),
      actionItems: lines.slice(4, 10),
      risks: lines.slice(2, 8),
      suggestions: lines.slice(5, 12),
    };
  };

  try {
    const summaryMatch =
      text.match(/(?:1[.．]\s*)?(?:ÖZET|OZET|Summary)[^\n\r:]*[:：]?\s*([\s\S]*?)(?=\n\s*\d+[.．]\s|\n\s*[🔑📌✅⚠️💡]|$)/i) ||
      text.match(/ÖZET[^\n\r]*\n+([\s\S]*?)(?=\n\d+\.)/i);
    const summary = summaryMatch ? summaryMatch[1].trim().split(/\n/)[0].slice(0, 400) : fallback().summary;

    const nextSec = /(?:3[.．]|4[.．]|5[.．]|6[.．]|ÖNEMLİ DETAYLAR|EYLEM|RİSK|ÖNERİ|Anahtar|Important|Action)/i;

    const keywords = extractBulletBlock(
      text,
      /(?:2[.．]\s*)?(?:ANAHTAR\s*KEL|ANAHATAR|KEYWORD|Keywords)/i,
      nextSec
    );
    const importantDetails = extractBulletBlock(
      text,
      /(?:3[.．]\s*)?(?:ÖNEMLİ\s*DETAY|IMPORTANT|DETAYLAR|Important\s*Details)/i,
      /(?:4[.．]|5[.．]|6[.．]|EYLEM|RİSK|ÖNERİ)/i
    );
    const actionItems = extractBulletBlock(
      text,
      /(?:4[.．]\s*)?(?:EYLEM\s*NOK|ACTION|Yapılacaklar)/i,
      /(?:5[.．]|6[.．]|RİSK|ÖNERİ)/i
    );
    const risks = extractBulletBlock(
      text,
      /(?:5[.．]\s*)?(?:RİSK|RISK|UYARI|WARNING)/i,
      /(?:6[.．]|ÖNERİ|SONUÇ)/i
    );
    const suggestions = extractBulletBlock(
      text,
      /(?:6[.．]\s*)?(?:ÖNER|SUGGESTION|ÖNEMLİ\s*SONUÇ|SONUÇ)/i,
      /$/
    );

    return {
      summary: summary || fallback().summary,
      keywords: keywords.length ? keywords : fallback().keywords,
      importantDetails: importantDetails.length ? importantDetails : fallback().importantDetails,
      actionItems: actionItems.length ? actionItems : fallback().actionItems,
      risks: risks.length ? risks : fallback().risks,
      suggestions: suggestions.length ? suggestions : fallback().suggestions,
    };
  } catch {
    return fallback();
  }
}
