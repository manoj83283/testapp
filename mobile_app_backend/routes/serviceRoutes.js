import express from "express";
import {
  createService,
  getServices,
  getMyServices,
  updateService,
  deleteService,
} from "../controllers/serviceController.js";

import { protect } from "../middleware/authMiddleware.js";

const router = express.Router();

/// ✅ POST (ADD SERVICE)
router.post("/", protect, createService);

/// ✅ GET ALL
router.get("/", getServices);

/// ✅ GET MY SERVICES
router.get("/my", protect, getMyServices);

/// ✅ UPDATE
router.put("/:id", protect, updateService);

/// ✅ DELETE
router.delete("/:id", protect, deleteService);

export default router;