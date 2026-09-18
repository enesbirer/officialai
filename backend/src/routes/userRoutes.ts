import { Router } from "express";
import { UserController } from "../controllers/user/UserController";
import { authMiddleware } from "../middlewares/auth";

const router = Router();
const userController = new UserController();

router.get("/profile", authMiddleware, (req, res, next) => userController.getProfile(req, res, next));
router.put("/profile", authMiddleware, (req, res, next) => userController.updateProfile(req, res, next));

export default router;
