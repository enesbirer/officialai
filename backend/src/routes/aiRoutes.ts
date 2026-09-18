import { Router } from "express";
import { AIController } from "../controllers/ai/AIController";
import { authMiddleware } from "../middlewares/auth";

const router = Router();
const aiController = new AIController();

router.get("/categories", authMiddleware, (req, res, next) => aiController.getCategories(req, res, next));
router.get("/templates", authMiddleware, (req, res, next) => aiController.getTemplates(req, res, next));

router.post("/petition", authMiddleware, (req, res, next) => aiController.generatePetition(req, res, next));
router.post("/email", authMiddleware, (req, res, next) => aiController.generateEmail(req, res, next));
router.post("/cv", authMiddleware, (req, res, next) => aiController.generateCV(req, res, next));
router.post("/ocr/analyze", authMiddleware, (req, res, next) => aiController.analyzeOCR(req, res, next));
router.post("/chat", authMiddleware, (req, res, next) => aiController.chat(req, res, next));

router.get("/documents", authMiddleware, (req, res, next) => aiController.getDocuments(req, res, next));
router.get("/favorites", authMiddleware, (req, res, next) => aiController.getFavorites(req, res, next));
router.post("/favorites/toggle", authMiddleware, (req, res, next) => aiController.toggleFavorite(req, res, next));

router.get("/chat/conversations", authMiddleware, (req, res, next) => aiController.getConversations(req, res, next));
router.get("/chat/conversations/:id", authMiddleware, (req, res, next) => aiController.getConversationMessages(req, res, next));

export default router;
