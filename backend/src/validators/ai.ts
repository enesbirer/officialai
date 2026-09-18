import { z } from "zod";

const EMAIL_TYPES = ["RESMI", "IS", "OZEL", "AKADEMIK", "BASVURU"] as const;
const TONES = ["resmi", "profesyonel", "dostca", "akademik", "sirket", "motivasyonel"] as const;
const LANGS = ["tr", "en"] as const;
const DOC_TYPES = ["petition", "email", "cv"] as const;

const upperOrDefault = <T extends readonly [string, ...string[]]>(
  raw: unknown,
  allowed: T,
  fallback: T[number]
): T[number] => {
  if (typeof raw !== "string") return fallback;
  const up = raw.trim().toUpperCase();
  return (allowed as readonly string[]).includes(up) ? (up as T[number]) : fallback;
};

const lowerOrDefault = <T extends readonly [string, ...string[]]>(
  raw: unknown,
  allowed: T,
  fallback: T[number]
): T[number] => {
  if (typeof raw !== "string") return fallback;
  const lo = raw.trim().toLowerCase();
  return (allowed as readonly string[]).includes(lo) ? (lo as T[number]) : fallback;
};

export const generatePetitionSchema = z.object({
  categoryId: z.string().min(1, "Kategori zorunlu"),
  answers: z.record(z.string(), z.string()).default({}),
});

export const generateEmailSchema = z
  .object({
    type: z.unknown().transform((v) => upperOrDefault(v, EMAIL_TYPES, "IS")),
    tone: z.unknown().transform((v) => lowerOrDefault(v, TONES, "profesyonel")),
    language: z.unknown().transform((v) => lowerOrDefault(v, LANGS, "tr")),
    context: z.unknown().transform((v) => (typeof v === "string" ? v.trim() : "")),
    recipient: z.unknown().transform((v) => (typeof v === "string" && v.trim().length ? v.trim() : undefined)),
    senderName: z
      .unknown()
      .transform((v) => (typeof v === "string" && v.trim().length ? v.trim() : undefined)),
  })
  .refine((s) => s.context.length >= 5, {
    message: "İçerik/açıklama en az 5 karakter olmalı",
    path: ["context"],
  });

export const generateCVSchema = z.object({
  templateId: z.string().optional(),
  personalInfo: z.record(z.any()).default({}),
  education: z.array(z.record(z.any())).default([]),
  experience: z.array(z.record(z.any())).default([]),
  skills: z.array(z.string()).default([]),
});

export const chatSchema = z
  .object({
    message: z.unknown().optional(),
    userMessage: z.unknown().optional(),
    history: z.array(z.object({ role: z.string(), content: z.string() })).optional(),
    conversationId: z.string().nullish(),
  })
  .transform((s) => {
    const raw = (typeof s.userMessage === "string" ? s.userMessage : typeof s.message === "string" ? s.message : "") || "";
    return {
      message: raw,
      history: s.history,
      conversationId: typeof s.conversationId === "string" && s.conversationId.length ? s.conversationId : undefined,
    };
  })
  .refine((s) => s.message.length >= 1, {
    message: "Mesaj boş olamaz",
    path: ["message"],
  });

export const ocrAnalyzeSchema = z
  .object({
    text: z.unknown().optional(),
    ocrText: z.unknown().optional(),
    customInstructions: z
      .unknown()
      .transform((v) => (typeof v === "string" && v.trim().length ? v.trim() : undefined)),
  })
  .transform((s) => {
    const raw =
      (typeof s.ocrText === "string" ? s.ocrText : typeof s.text === "string" ? s.text : "") || "";
    return { text: raw, customInstructions: s.customInstructions };
  })
  .refine((s) => s.text.length >= 5, {
    message: "OCR metni en az 5 karakter olmalı",
    path: ["text"],
  });

export const toggleFavoriteSchema = z
  .object({
    documentId: z.unknown().transform((v) => (typeof v === "string" ? v.trim() : "")),
    documentType: z.unknown().transform((v) => lowerOrDefault(v, DOC_TYPES, "petition")),
  })
  .refine((s) => s.documentId.length >= 1, {
    message: "Document id zorunlu",
    path: ["documentId"],
  });

