import express from "express";
import { protect } from "../middleware/authMiddleware.js";

import {
  createBooking,
  getBookings,
  getProviderBookings,
  updateBookingStatus,
  cancelBooking,
  rateBooking,
} from "../controllers/bookingController.js";

const router = express.Router();

/// ✅ CREATE BOOKING
router.post("/", protect, createBooking);

/// ✅ GET CUSTOMER BOOKINGS
router.get("/", protect, getBookings);

/// ✅ GET PROVIDER BOOKINGS
router.get("/provider", protect, getProviderBookings);

/// ✅ UPDATE STATUS (Provider actions)
router.put("/:id/status", protect, updateBookingStatus);

/// ✅ CANCEL BOOKING (Customer side)
router.put("/:id/cancel", protect, cancelBooking);

/// ✅ ADD RATING (After completion)
router.put("/:id/rate", protect, rateBooking);

export default router;