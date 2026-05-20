import Booking from "../models/booking.js";

export const createBooking = async (req, res) => {
  try {
    const { serviceId, date, notes } = req.body;

    if (!serviceId || !date) {
      return res.status(400).json({ message: "Service ID and date are required" });
    }

    const booking = await Booking.create({
      user: req.user._id,
      service: serviceId,
      date,
      notes,
      status: "pending",
    });

    res.status(201).json({
      message: "Booking created successfully",
      booking,
    });
  } catch (error) {
    res.status(500).json({ message: "Server error", error: error.message });
  }
};

export const getUserBookings = async (req, res) => {
  try {
    const bookings = await Booking.find({ user: req.user._id })
      .populate("service", "name basePrice iconURL")
      .sort({ date: -1 });

    res.status(200).json(bookings);
  } catch (error) {
    res.status(500).json({ message: "Server error", error: error.message });
  }
};