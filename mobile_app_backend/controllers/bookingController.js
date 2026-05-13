import Booking from '../models/booking.js';

export const createBooking = async (req, res) => {
  try {
    const booking = await Booking.create(req.body);
    res.status(201).json(booking);
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
};

export const getBookings = async (req, res) => {
  const bookings = await Booking.find().populate('serviceId providerId customerId');
  res.json(bookings);
};