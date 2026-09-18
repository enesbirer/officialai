import { Router } from "express";
import { AuthController } from "../controllers/auth/AuthController";
import { authMiddleware } from "../middlewares/auth";

const router = Router();
const authController = new AuthController();

router.post("/register", (req, res, next) => authController.register(req, res, next));
router.post("/verify-email", (req, res, next) => authController.verifyEmail(req, res, next));
router.post("/login", (req, res, next) => authController.login(req, res, next));
router.post("/refresh", (req, res, next) => authController.refreshToken(req, res, next));
router.post("/logout", authMiddleware, (req, res, next) => authController.logout(req, res, next));

export default router;
