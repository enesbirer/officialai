import { Request, Response, NextFunction } from "express";
import { AppError } from "../utils/errors";
import { HTTP_STATUS } from "../constants";

export const errorHandler = (
  err: Error,
  req: Request,
  res: Response,
  next: NextFunction
) => {
  let statusCode = HTTP_STATUS.INTERNAL_SERVER_ERROR;
  let message = "Internal Server Error";

  if (err instanceof AppError) {
    statusCode = err.statusCode;
    message = err.message;
  } else if (err.name === "ZodError") {
    statusCode = HTTP_STATUS.BAD_REQUEST;
    message = "Validation failed";
  } else if (err.name === "PrismaClientKnownRequestError") {
    // Handle Prisma errors here if needed
  }

  console.error(err.stack);

  res.status(statusCode).json({
    success: false,
    message,
    stack: process.env.NODE_ENV === "development" ? err.stack : undefined,
  });
};
