import fs from "fs";
import path from "path";
import { v2 as cloudinary } from "cloudinary";
import { config } from "../../config";
import { v4 as uuidv4 } from "uuid";

export class StorageService {
  private initialized = false;

  constructor() {
    if (config.storage.mode === "cloudinary" && config.cloudinary.cloudName) {
      cloudinary.config({
        cloud_name: config.cloudinary.cloudName,
        api_key: config.cloudinary.apiKey,
        api_secret: config.cloudinary.apiSecret,
      });
      this.initialized = true;
    } else if (config.storage.mode === "local") {
      if (!fs.existsSync(config.storage.localDir)) {
        try {
          fs.mkdirSync(config.storage.localDir, { recursive: true });
        } catch (e) {
          console.warn("Storage klasörü oluşturulamadı:", e);
        }
      }
      this.initialized = true;
    }
  }

  private saveBufferLocal(buffer: Buffer, folder: string, ext: string): string {
    const dir = path.join(config.storage.localDir, folder);
    if (!fs.existsSync(dir)) fs.mkdirSync(dir, { recursive: true });
    const name = `${Date.now()}-${uuidv4()}.${ext}`;
    const fullPath = path.join(dir, name);
    fs.writeFileSync(fullPath, buffer);
    return `/storage/${folder}/${name}`;
  }

  private saveFileLocal(filePath: string, folder: string): string {
    const ext = path.extname(filePath).replace(".", "") || "bin";
    const buf = fs.readFileSync(filePath);
    return this.saveBufferLocal(buf, folder, ext);
  }

  async uploadFile(filePath: string, folder: string = "officialai"): Promise<string> {
    if (!this.initialized) {
      return this.saveFileLocal(filePath, folder);
    }
    if (config.storage.mode === "cloudinary" && config.cloudinary.cloudName) {
      try {
        const result = await cloudinary.uploader.upload(filePath, { folder });
        return result.secure_url;
      } catch (e) {
        console.warn("Cloudinary yüklenemedi, local fallback:", e);
        return this.saveFileLocal(filePath, folder);
      }
    }
    return this.saveFileLocal(filePath, folder);
  }

  async uploadBuffer(buffer: Buffer, originalName: string, folder: string = "officialai"): Promise<string> {
    const ext = path.extname(originalName).replace(".", "").toLowerCase() || "bin";
    if (config.storage.mode === "cloudinary" && config.cloudinary.cloudName && this.initialized) {
      try {
        const tmpName = path.join(config.storage.localDir, `tmp-${uuidv4()}.${ext}`);
        fs.writeFileSync(tmpName, buffer);
        const result = await cloudinary.uploader.upload(tmpName, { folder });
        try { fs.unlinkSync(tmpName); } catch {}
        return result.secure_url;
      } catch (e) {
        console.warn("Cloudinary yüklenemedi, local fallback:", e);
      }
    }
    return this.saveBufferLocal(buffer, folder, ext);
  }

  async deleteFile(publicIdOrPath: string): Promise<void> {
    if (config.storage.mode === "cloudinary" && publicIdOrPath.startsWith("http")) {
      try {
        await cloudinary.uploader.destroy(publicIdOrPath);
      } catch (e) { console.warn("Silme başarısız:", e); }
    } else if (publicIdOrPath.startsWith("/storage/")) {
      const fullPath = path.join(config.storage.localDir, publicIdOrPath.replace("/storage/", ""));
      try { fs.unlinkSync(fullPath); } catch (e) {}
    }
  }
}
