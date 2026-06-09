import Booking from "../models/booking.js";
import Service from "../models/service.js";
import { io } from "../server.js";

/// ✅ CREATE BOOKING (FULL LOGIC + PRICING + PROVIDER + REALTIME)
export const createBooking = async (req, res) => {
  try {
    const {
      serviceId,
      date,
      notes,
      address,
      location,
      hoursBooked = 1,
      paymentMethod = "COD",
    } = req.body;

    /// ✅ GET SERVICE DETAILS
    const service = await Service.findById(serviceId).populate("provider");

    if (!service) {
      return res.status(404).json({ message: "Service not found" });
    }

    /// ✅ CALCULATE PRICE
    const pricePerHour = service.price || 0;
    const totalPrice = pricePerHour * hoursBooked;

    /// ✅ CREATE BOOKING
    const booking = await Booking.create({
      user: req.user.id,
      service: serviceId,
      provider: service.provider._id, // 🔥 IMPORTANT
      date,
      notes,
      address,
      location,
      hoursBooked,
      pricePerHour,
      totalPrice,
      paymentMethod,
      paymentStatus: paymentMethod === "COD" ? "pending" : "pending",
      status: "pending",
    });

    /// ✅ POPULATE RESPONSE
    const populatedBooking = await Booking.findById(booking._id)
      .populate("user", "firstName lastName email")
      .populate({
        path: "service",
        populate: {
          path: "provider",
          select: "_id firstName lastName email",
        },
      });

    /// ✅ REAL-TIME EVENT (NEW BOOKING)
    io.emit("newBooking", populatedBooking);

    res.status(201).json(populatedBooking);

  } catch (err) {
    console.error("❌ Create Booking Error:", err);
    res.status(500).json({ message: err.message });
  }
};


/// ✅ GET CUSTOMER BOOKINGS
export const getBookings = async (req, res) => {
  try {
    const bookings = await Booking.find({ user: req.user.id })
      .populate("service")
      .sort({ createdAt: -1 }); // latest first

    res.json(bookings);

  } catch (err) {
    console.error("❌ Get Bookings Error:", err);
    res.status(500).json({ message: err.message });
  }
};


/// ✅ GET PROVIDER BOOKINGS (FAST - NO FILTER LOOP 🔥)
export const getProviderBookings = async (req, res) => {
  try {
    const bookings = await Booking.find({ provider: req.user.id })
      .populate("user", "firstName lastName email")
      .populate("service")
      .sort({ createdAt: -1 });

    res.json(bookings);

  } catch (err) {
    console.error("❌ Provider Bookings Error:", err);
    res.status(500).json({ message: err.message });
  }
};


/// ✅ UPDATE BOOKING STATUS (FULL FLOW + REALTIME)
export const updateBookingStatus = async (req, res) => {
  try {
    const { status } = req.body;

    const booking = await Booking.findById(req.params.id);

    if (!booking) {
      return res.status(404).json({ message: "Booking not found" });
    }

    /// ✅ UPDATE STATUS
    booking.status = status;

    /// ✅ AUTO TRACK TIMES
    if (status === "in_progress") {
      booking.startedAt = new Date();
    }

    if (status === "completed") {
      booking.completedAt = new Date();
      booking.paymentStatus = "paid";
    }

    await booking.save();

    /// ✅ REAL-TIME UPDATE
    io.emit("bookingUpdate", booking);

    res.json(booking);

  } catch (err) {
    console.error("❌ Update Booking Status Error:", err);
    res.status(500).json({ message: err.message });
  }
};


/// ✅ CANCEL BOOKING (CUSTOMER SIDE)
export const cancelBooking = async (req, res) => {
  try {
    const booking = await Booking.findById(req.params.id);

    if (!booking) {
      return res.status(404).json({ message: "Booking not found" });
    }

    /// ✅ ONLY OWNER CAN CANCEL
    if (booking.user.toString() !== req.user.id) {
      return res.status(403).json({ message: "Unauthorized" });
    }

    booking.status = "cancelled";
    await booking.save();

    io.emit("bookingUpdate", booking);

    res.json({ message: "Booking cancelled", booking });

  } catch (err) {
    console.error("❌ Cancel Booking Error:", err);
    res.status(500).json({ message: err.message });
  }
};


/// ✅ ADD RATING AFTER COMPLETION ⭐
export const rateBooking = async (req, res) => {
  try {
    const { rating, review } = req.body;

    const booking = await Booking.findById(req.params.id);

    if (!booking) {
      return res.status(404).json({ message: "Booking not found" });
    }

    /// ✅ ALLOW ONLY AFTER COMPLETED
    if (booking.status !== "completed") {
      return res.status(400).json({ message: "Complete booking first" });
    }

    booking.rating = rating;
    booking.review = review;

    await booking.save();

    res.json({ message: "Rating added", booking });

  } catch (err) {
    console.error("❌ Rating Error:", err);
    res.status(500).json({ message: err.message });
  }
};