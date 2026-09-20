import { Request, Response, NextFunction } from "express";
import { AIService } from "../../services/ai/AIService";
import { HTTP_STATUS } from "../../constants";
import {
  generatePetitionSchema,
  generateEmailSchema,
  generateCVSchema,
  chatSchema,
  ocrAnalyzeSchema,
  toggleFavoriteSchema,
} from "../../validators/ai";

export class AIController {
  private aiService: AIService;

  constructor() {
    this.aiService = new AIService();
  }

  async getCategories(req: Request, res: Response, next: NextFunction) {
    try {
      const data = await this.aiService.getPetitionCategories();
      res.status(HTTP_STATUS.OK).json({ success: true, data });
    } catch (e) { next(e); }
  }

  async getTemplates(req: Request, res: Response, next: NextFunction) {
    try {
      const { categoryId, type } = req.query as any;
      const data = await this.aiService.getTemplatesByCategory(categoryId, type);
      res.status(HTTP_STATUS.OK).json({ success: true, data });
    } catch (e) { next(e); }
  }

  async generatePetition(req: Request, res: Response, next: NextFunction) {
    try {
      const { categoryId, answers } = generatePetitionSchema.parse(req.body);
      const result = await this.aiService.generatePetition(req.user!.id, categoryId, answers);
      res.status(HTTP_STATUS.OK).json({ success: true, data: result });
    } catch (error) {
      next(error);
    }
  }

  async generateEmail(req: Request, res: Response, next: NextFunction) {
    try {
      const { type, tone, language, context, recipient, senderName } = generateEmailSchema.parse(req.body);
      const result = await this.aiService.generateEmail(
        req.user!.id, type, tone, language, context, recipient, senderName
      );
      res.status(HTTP_STATUS.OK).json({ success: true, data: result });
    } catch (error) {
      next(error);
    }
  }

  async generateCV(req: Request, res: Response, next: NextFunction) {
    try {
      const { templateId, personalInfo, education, experience, skills } = generateCVSchema.parse(req.body);
      const result = await this.aiService.generateCV(
        req.user!.id, personalInfo, education, experience, skills, templateId
      );
      res.status(HTTP_STATUS.OK).json({ success: true, data: result });
    } catch (error) {
      next(error);
    }
  }

  async analyzeOCR(req: Request, res: Response, next: NextFunction) {
    try {
      const { text, customInstructions } = ocrAnalyzeSchema.parse(req.body);
      const result = await this.aiService.analyzeOCR(req.user!.id, text, customInstructions);
      res.status(HTTP_STATUS.OK).json({ success: true, data: result });
    } catch (error) {
      next(error);
    }
  }

  async chat(req: Request, res: Response, next: NextFunction) {
    try {
      const { message, history, conversationId } = chatSchema.parse(req.body);
      const typedHistory = (history || []).map((h: any) => ({
        role: h.role || 'user',
        content: h.content || ''
      }));
      const result = await this.aiService.chat(req.user!.id, message, typedHistory, conversationId);
      res.status(HTTP_STATUS.OK).json({ success: true, data: result });
    } catch (error) {
      next(error);
    }
  }

  async getDocuments(req: Request, res: Response, next: NextFunction) {
    try {
      const { type } = req.query as any;
      const data = await this.aiService.getUserDocuments(req.user!.id, type || undefined);
      res.status(HTTP_STATUS.OK).json({ success: true, data });
    } catch (error) {
      next(error);
    }
  }

  async getFavorites(req: Request, res: Response, next: NextFunction) {
    try {
      const data = await this.aiService.getFavorites(req.user!.id);
      res.status(HTTP_STATUS.OK).json({ success: true, data });
    } catch (error) {
      next(error);
    }
  }

  async toggleFavorite(req: Request, res: Response, next: NextFunction) {
    try {
      const { documentId, documentType } = toggleFavoriteSchema.parse(req.body);
      const data = await this.aiService.toggleFavorite(req.user!.id, documentId, documentType as any);
      res.status(HTTP_STATUS.OK).json({ success: true, data });
    } catch (error) {
      next(error);
    }
  }

  async getConversations(req: Request, res: Response, next: NextFunction) {
    try {
      const data = await this.aiService.getConversations(req.user!.id);
      res.status(HTTP_STATUS.OK).json({ success: true, data });
    } catch (e) { next(e); }
  }

  async getConversationMessages(req: Request, res: Response, next: NextFunction) {
    try {
      const { id } = req.params;
      const data = await this.aiService.getConversationMessages(req.user!.id, id);
      res.status(HTTP_STATUS.OK).json({ success: true, data });
    } catch (e) { next(e); }
  }
}
