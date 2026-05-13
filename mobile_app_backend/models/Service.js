import mongoose from 'mongoose';

const serviceSchema = new mongoose.Schema({
  name: { type: String, required: true },
  description: String,
  pricePerHour: Number,
  pricePerDay: Number,
  providerId: { type: mongoose.Schema.Types.ObjectId, ref: 'User' },
  location: {
    lat: Number,
    lon: Number
  }
});

export default mongoose.model('Service', serviceSchema);