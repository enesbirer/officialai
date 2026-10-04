import express from "express";
import cors from "cors";
import helmet from "helmet";
import compression from "compression";
import morgan from "morgan";
import path from "path";
import fs from "fs";
import { config } from "./config";
import { rateLimiter } from "./middlewares/rateLimiter";
import { errorHandler } from "./middlewares/errorHandler";
import authRoutes from "./routes/authRoutes";
import aiRoutes from "./routes/aiRoutes";
import userRoutes from "./routes/userRoutes";

const app = express();

// Ensure storage directory exists and serve static
if (!fs.existsSync(config.storage.localDir)) {
  try { fs.mkdirSync(config.storage.localDir, { recursive: true }); } catch {}
}
app.use("/storage", express.static(config.storage.localDir, { maxAge: "7d" }));

// Helmet - security headers (CORS eklerken esnek ayarlar)
app.use(helmet({
  contentSecurityPolicy: {
    directives: {
      defaultSrc: ["'self'"],
      styleSrc: ["'self'", "'unsafe-inline'"],
      scriptSrc: ["'self'"],
      imgSrc: ["'self'", "data:", "https://res.cloudinary.com", "https:"],
      connectSrc: ["'self'", "https:"],
      fontSrc: ["'self'", "data:"],
      frameAncestors: ["'none'"],
    },
    reportOnly: false,
  },
  hsts: { maxAge: 31536000, includeSubDomains: true, preload: true },
  xssFilter: true,
  noSniff: true,
  frameguard: { action: "sameorigin" },
  permittedCrossDomainPolicies: false,
  crossOriginOpenerPolicy: false,
  crossOriginResourcePolicy: false,
}));

// CORS - mobile için esnek
const corsOrigins = config.cors.origin;
const isWildcard = corsOrigins === "*" || (Array.isArray(corsOrigins) && corsOrigins.includes("*"));
if (isWildcard) {
  app.use(cors({
    origin: true,
    credentials: true,
    methods: ["GET", "POST", "PUT", "PATCH", "DELETE", "OPTIONS"],
    allowedHeaders: ["Content-Type", "Authorization", "X-Requested-With", "Accept", "Accept-Language", "Origin"],
    preflightContinue: false,
    optionsSuccessStatus: 204,
    maxAge: 86400,
  }));
} else {
  const allowed = Array.isArray(corsOrigins) ? corsOrigins : [corsOrigins];
  const corsOptions = {
    origin: (origin: string | undefined, callback: (err: Error | null, allow?: boolean) => void) => {
      if (!origin || allowed.includes(origin) || /^https?:\/\/localhost(:\d+)?$/.test(origin) || /^http:\/\/(192\.168\.|10\.|127\.)/.test(origin)) {
        callback(null, true);
      } else {
        console.warn("CORS blocked origin:", origin);
        callback(new Error("Not allowed by CORS"));
      }
    },
    credentials: true,
    methods: ["GET", "POST", "PUT", "PATCH", "DELETE", "OPTIONS"],
    allowedHeaders: ["Content-Type", "Authorization", "X-Requested-With", "Accept", "Accept-Language"],
  };
  app.use(cors(corsOptions));
}

app.options("*", cors());

// Body parsers
app.use(express.json({ limit: "50mb" }));
app.use(express.urlencoded({ extended: true, limit: "50mb" }));

// Compression & logging
app.use(compression({
  level: 6,
  filter: (req, res) => {
    if (req.headers["x-no-compression"]) return false;
    return compression.filter(req, res);
  },
}));
app.use(morgan(config.env === "production" ? "combined" : "dev"));

// Rate limiter
app.use(rateLimiter);

// API routes
const apiBase = `/api/${config.apiVersion}`;
app.use(`${apiBase}/auth`, authRoutes);
app.use(`${apiBase}/ai`, aiRoutes);
app.use(`${apiBase}/users`, userRoutes);

// Health endpoints
app.get("/health", (req, res) => {
  res.status(200).json({
    status: "OK",
    env: config.env,
    apiVersion: config.apiVersion,
    storageMode: config.storage.mode,
    emailMode: config.email.mode,
    timestamp: new Date().toISOString(),
  });
});

// Admin migration endpoint
app.get("/api/v1/admin/migrate", async (req, res) => {
  try {
    console.log("🔄 Manuel migration başlatılıyor...");
    const { exec } = require("child_process");

    exec("npx prisma migrate deploy", { cwd: process.cwd() }, (err: any, stdout: string, stderr: string) => {
      if (err) {
        console.error("Migration hatası:", err);
        return res.status(500).json({ success: false, error: err.message });
      }
      console.log("Migration başarılı:", stdout);

      // Migration sonrası seed çalıştır
      exec("npx tsx prisma/seed.ts", { cwd: process.cwd() }, (seedErr: any, seedStdout: string, seedStderr: string) => {
        if (seedErr) {
          console.error("Seed hatası:", seedErr);
          return res.status(500).json({ success: false, error: seedErr.message });
        }
        console.log("Seed başarılı:", seedStdout);
        res.json({ success: true, message: "Migration ve seed başarıyla tamamlandı" });
      });
    });
  } catch (e) {
    res.status(500).json({ success: false, error: (e as any).message });
  }
});

app.get("/", (req, res) => {
  res.json({
    name: "OfficialAI Backend",
    version: "1.0.0",
    docs: "Visit /api/v1/* for endpoints",
    health: "/health",
  });
});

// Error handler (son middleware olmalı)
app.use(errorHandler);

// 404
app.use((req, res) => {
  res.status(404).json({ success: false, error: "Route bulunamadı", path: req.originalUrl });
});

export default app;
