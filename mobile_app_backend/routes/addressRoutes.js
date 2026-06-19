import express from "express";
import {
  addAddress,
  getAddresses,
  deleteAddress,
  updateAddress,
  setDefaultAddress,
} from "../controllers/addressController.js";

import { protect } from "../middleware/authMiddleware.js";

const router = express.Router();

router.post("/", protect, addAddress);
router.get("/", protect, getAddresses);
router.delete("/:id", protect, deleteAddress);
router.put("/:id", protect, updateAddress);
router.patch("/default/:id", protect, setDefaultAddress);
export default router;