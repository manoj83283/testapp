import express from "express";

import {
  createBooking,
  getBookings,
  getProviderBookings,
  updateBookingStatus,
  cancelBooking,
  rateBooking,
} from "../controllers/bookingController.js";

import {
  protect,
  authorizeRoles,
} from "../middleware/authMiddleware.js";

const router = express.Router();

/// ✅ CREATE BOOKING (CUSTOMER)
router.post(
  "/",
  protect,
  authorizeRoles("user", "provider"), // both allowed if needed
  createBooking
);


/// ✅ GET CUSTOMER BOOKINGS
router.get(
  "/",
  protect,
  getBookings
);


/// ✅ GET PROVIDER BOOKINGS (DASHBOARD)
router.get(
  "/provider",
  protect,
  authorizeRoles("provider"),
  getProviderBookings
);


/// ✅ UPDATE STATUS (PROVIDER ACTIONS)
router.put(
  "/:id/status",
  protect,
  authorizeRoles("provider"),
  updateBookingStatus
);


/// ✅ CANCEL BOOKING (CUSTOMER SIDE)
router.put(
  "/:id/cancel",
  protect,
  cancelBooking
);


/// ✅ RATE BOOKING (AFTER COMPLETION ⭐)
router.put(
  "/:id/rate",
  protect,
  rateBooking
);


/// ✅ OPTIONAL: GET SINGLE BOOKING DETAILS 🔥
router.get(
  "/:id",
  protect,
  async (req, res) => {
    try {
      const booking = await Booking.findById(req.params.id)
        .populate("user", "firstName lastName email")
        .populate("service")
        .populate("provider", "firstName lastName email");

      if (!booking) {
        return res.status(404).json({
          message: "Booking not found",
        });
      }

      res.json(booking);

    } catch (err) {
      res.status(500).json({
        message: err.message,
      });
    }
  }
);

export default router;