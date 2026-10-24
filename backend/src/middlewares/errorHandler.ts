import { Request, Response, NextFunction } from "express";
import { AppError } from "../utils/errors";
import { HTTP_STATUS } from "../constants";
import { logger } from "../utils/logger";

/**
 * Tüm hataları tek noktadan, kullanıcıya gösterilebilecek sade Türkçe
 * mesajlara çevirir. Teknik ayrıntılar yalnızca sunucu loglarına yazılır;
 * istemciye stack trace veya hassas bilgi asla gönderilmez.
 */
export const errorHandler = (
  err: Error,
  req: Request,
  res: Response,
  _next: NextFunction
) => {
  let statusCode: number = HTTP_STATUS.INTERNAL_SERVER_ERROR;
  let message = "Beklenmeyen bir sorun oluştu. Lütfen tekrar deneyin.";

  if (err instanceof AppError) {
    statusCode = err.statusCode;
    message = err.message;
  } else if (err.name === "ZodError") {
    statusCode = HTTP_STATUS.BAD_REQUEST;
    const issues = (err as unknown as { issues?: Array<{ message?: string }> }).issues;
    const first = issues && issues.length > 0 ? issues[0].message : undefined;
    message = first || "Girdiğiniz bilgiler geçersiz. Lütfen kontrol edip tekrar deneyin.";
  } else if (err.name === "PrismaClientKnownRequestError") {
    const code = (err as unknown as { code?: string }).code;
    if (code === "P2002") {
      statusCode = HTTP_STATUS.CONFLICT;
      message = "Bu bilgilerle kayıtlı bir kayıt zaten var.";
    } else if (code === "P2025") {
      statusCode = HTTP_STATUS.NOT_FOUND;
      message = "Aradığınız kayıt bulunamadı.";
    } else {
      statusCode = HTTP_STATUS.BAD_REQUEST;
      message = "İşlem tamamlanamadı. Lütfen tekrar deneyin.";
    }
  } else if (err.name === "PrismaClientValidationError") {
    statusCode = HTTP_STATUS.BAD_REQUEST;
    message = "İstek geçersiz. Lütfen tekrar deneyin.";
  } else if ((err as unknown as { type?: string }).type === "entity.parse.failed") {
    statusCode = HTTP_STATUS.BAD_REQUEST;
    message = "Gönderilen veri okunamadı. Lütfen tekrar deneyin.";
  } else if ((err as unknown as { type?: string }).type === "entity.too.large") {
    statusCode = HTTP_STATUS.BAD_REQUEST;
    message = "Gönderilen veri çok büyük.";
  }

  // Teknik ayrıntı yalnızca sunucu tarafında tutulur.
  logger.error("İstek işlenirken hata oluştu", {
    method: req.method,
    path: req.originalUrl,
    statusCode,
    name: err.name,
    detail: err.message,
  });
  if (process.env.NODE_ENV !== "production") {
    console.error(err.stack);
  }

  res.status(statusCode).json({
    success: false,
    message,
  });
};
