import mongoose from 'mongoose';

const serviceProviderSchema = new mongoose.Schema({
  name: { type: String, required: true },
  email: { type: String, required: true, unique: true },
  password: { type: String, required: true },
  serviceType: { type: String, required: true }, // e.g., Photographer, DJ, Makeup Artist
  description: { type: String },
  rating: { type: Number, default: 0 },
  pricePerHour: { type: Number },
  pricePerDay: { type: Number },
  location: {
    city: String,
    state: String,
    country: String,
    coordinates: {
      lat: Number,
      lng: Number,
    },
  },
  media: {
    photos: [String], // URLs of uploaded images
    videos: [String], // URLs of uploaded videos
  },
}, { timestamps: true });

const ServiceProvider = mongoose.model('ServiceProvider', serviceProviderSchema);

export default ServiceProvider;