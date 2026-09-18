import app from "./app";
import { config } from "./config";
import { PrismaClient } from "@prisma/client";

const prisma = new PrismaClient();

// Backend başlarken kategori verisi yoksa otomatik seed çalıştır
async function autoSeedIfEmpty() {
  try {
    const catCount = await prisma.petitionCategory.count();
    if (catCount === 0) {
      console.log("🗂️  Veritabanı boş görünüyor, seed otomatik çalıştırılıyor...");
      const { exec } = require("child_process");
      const seedProc = exec("npx tsx prisma/seed.ts", { cwd: process.cwd() }, (err: any, stdout: string, stderr: string) => {
        if (err) {
          console.warn("Auto seed başarısız (devam ediliyor):", err.message);
        } else {
          console.log(stdout || stderr);
          console.log("✅ Otomatik seed tamamlandı.");
        }
      });
      seedProc.stderr.on("data", (d: any) => process.stderr.write(d));
    }
  } catch (e) {
    console.warn("Auto seed kontrolü başarısız, DB bağlantısı beklemede:", (e as any)?.message);
  }
}

async function start() {
  const server = app.listen(config.port, () => {
    console.log(`\n🚀 OfficialAI Backend çalışıyor`);
    console.log(`📡 Port   : ${config.port}`);
    console.log(`🌐 URL    : http://localhost:${config.port}`);
    console.log(`🩺 Health : http://localhost:${config.port}/health`);
    console.log(`🛢️  API    : /api/${config.apiVersion}/*`);
    console.log(`⚙️  Env    : ${config.env}  |  Storage: ${config.storage.mode}  |  Email: ${config.email.mode}`);
    console.log(`🤖 AI     : ${config.ai.provider}`);
    console.log();
  });

  // Graceful shutdown
  for (const signal of ["SIGTERM", "SIGINT"] as NodeJS.Signals[]) {
    process.on(signal, () => {
      console.log(`\n${signal} alındı, kapatılıyor...`);
      server.close(() => {
        prisma.$disconnect().then(() => process.exit(0));
      });
      setTimeout(() => {
        console.error("Zaman aşımı, force kapatılıyor");
        process.exit(1);
      }, 10000);
    });
  }

  await autoSeedIfEmpty();
}

start().catch(err => {
  console.error("❌ Sunucu başlatılamadı:", err);
  process.exit(1);
});
