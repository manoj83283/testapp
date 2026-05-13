import mongoose from 'mongoose';

const bookingSchema = new mongoose.Schema({
  customerId: { type: mongoose.Schema.Types.ObjectId, ref: 'User' },
  serviceId: { type: mongoose.Schema.Types.ObjectId, ref: 'Service' },
  providerId: { type: mongoose.Schema.Types.ObjectId, ref: 'User' },
  date: Date,
  hoursBooked: Number,
  totalPrice: Number,
  status: { type: String, enum: ['pending', 'confirmed', 'completed'], default: 'pending' }
});

export default mongoose.model('Booking', bookingSchema);