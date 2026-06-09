import express from "express";
import { signup, signin, getProfile } from "../controllers/authController.js";
import { protect } from "../middleware/authMiddleware.js";

const router = express.Router();

router.post("/signup", signup);
router.post("/signin", signin);
router.get("/profile", protect, getProfile); // ✅ ADD THIS

export default router;