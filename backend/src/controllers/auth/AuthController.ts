import { Request, Response, NextFunction } from "express";
import { AuthService } from "../../services/auth/AuthService";
import { HTTP_STATUS } from "../../constants";
import {
  registerSchema,
  loginSchema,
  refreshTokenSchema,
  verifyEmailSchema,
} from "../../validators/auth";

export class AuthController {
  private authService: AuthService;

  constructor() {
    this.authService = new AuthService();
  }

  async register(req: Request, res: Response, next: NextFunction) {
    try {
      const { email, password, firstName, lastName } = registerSchema.parse(req.body);
      const result = await this.authService.register(email, password, firstName, lastName);
      res.status(HTTP_STATUS.CREATED).json({ success: true, data: result });
    } catch (error) {
      next(error);
    }
  }

  async verifyEmail(req: Request, res: Response, next: NextFunction) {
    try {
      const { email, code } = verifyEmailSchema.parse(req.body);
      const result = await this.authService.verifyEmail(email, code);
      res.status(HTTP_STATUS.OK).json({ success: true, data: result });
    } catch (error) {
      next(error);
    }
  }

  async login(req: Request, res: Response, next: NextFunction) {
    try {
      const { email, password } = loginSchema.parse(req.body);
      const result = await this.authService.login(email, password);
      res.status(HTTP_STATUS.OK).json({ success: true, data: result });
    } catch (error) {
      next(error);
    }
  }

  async refreshToken(req: Request, res: Response, next: NextFunction) {
    try {
      const { refreshToken } = refreshTokenSchema.parse(req.body);
      const result = await this.authService.refreshTokens(refreshToken);
      res.status(HTTP_STATUS.OK).json({ success: true, data: result });
    } catch (error) {
      next(error);
    }
  }

  async logout(req: Request, res: Response, next: NextFunction) {
    try {
      if (!req.user) {
        return next();
      }
      await this.authService.logout(req.user.id);
      res.status(HTTP_STATUS.OK).json({ success: true, message: "Logged out successfully" });
    } catch (error) {
      next(error);
    }
  }
}
