import express from "express";
import {
  createService,
  getServices,
} from "../controllers/serviceController.js";
import { protect } from "../middleware/authMiddleware.js";

const router = express.Router();

// ✅ Public (user can view services)
router.get("/", getServices);

// ✅ Protected (provider adds service)
router.post("/", protect, createService);

export default router;