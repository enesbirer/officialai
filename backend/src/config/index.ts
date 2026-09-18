import dotenv from "dotenv";
import path from "path";

dotenv.config({ path: path.resolve(process.cwd(), ".env") });

const parseCorsOrigins = (raw?: string): string | string[] => {
  if (!raw) return "*";
  if (raw === "*") return "*";
  const parts = raw.split(",").map(s => s.trim()).filter(Boolean);
  if (parts.length === 0) return "*";
  return parts;
};

export const config = {
  env: process.env.NODE_ENV || "development",
  port: parseInt(process.env.PORT || "3000", 10),
  apiVersion: process.env.API_VERSION || "v1",
  database: {
    url: process.env.DATABASE_URL || "",
  },
  jwt: {
    secret: process.env.JWT_SECRET || "officialai-dev-secret-change-in-production-please-32chars!",
    accessExpiresIn: process.env.JWT_ACCESS_EXPIRES_IN || "30m",
    refreshExpiresIn: process.env.JWT_REFRESH_EXPIRES_IN || "30d",
  },
  ai: {
    provider: process.env.AI_PROVIDER || "gemini",
    geminiApiKey: process.env.GEMINI_API_KEY || "",
  },
  cloudinary: {
    cloudName: process.env.CLOUDINARY_CLOUD_NAME || "",
    apiKey: process.env.CLOUDINARY_API_KEY || "",
    apiSecret: process.env.CLOUDINARY_API_SECRET || "",
  },
  email: {
    user: process.env.EMAIL_USER || "",
    password: process.env.EMAIL_PASSWORD || "",
    from: process.env.EMAIL_FROM || "OfficialAI <noreply@officialai.com>",
    // Use 'log' for dev to skip real SMTP, saves keys
    mode: (process.env.EMAIL_MODE as "log" | "smtp") || "log",
  },
  storage: {
    // local | cloudinary
    mode: (process.env.STORAGE_MODE as "local" | "cloudinary") || "local",
    localDir: process.env.STORAGE_LOCAL_DIR || path.resolve(process.cwd(), ".storage"),
  },
  cors: {
    origin: parseCorsOrigins(process.env.CORS_ORIGIN),
  },
  rateLimit: {
    windowMs: parseInt(process.env.RATE_LIMIT_WINDOW_MS || "900000", 10),
    maxRequests: parseInt(process.env.RATE_LIMIT_MAX_REQUESTS || "500", 10),
  },
};
