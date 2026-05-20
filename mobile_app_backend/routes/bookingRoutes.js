import express from "express";
import { protect } from "../middleware/authMiddleware.js";
import {
  createBooking,
  getUserBookings,
} from "../controllers/bookingController.js";

const router = express.Router();

// Create a new booking
router.post("/", protect, createBooking);

// Get all bookings for logged‑in user
router.get("/", protect, getUserBookings);

export default router;