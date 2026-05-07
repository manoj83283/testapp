import mongoose from "mongoose";

const serviceSchema = new mongoose.Schema({
  providerId: { type: mongoose.Schema.Types.ObjectId, ref: "User", required: true },
  category: { type: String, required: true },
  title: { type: String, required: true },
  description: String,
  price: { type: Number, required: true },
  image: String,
  featured: { type: Boolean, default: false },
  ratingCount: { type: Number, default: 0 },
  averageRating: { type: Number, default: 0 },
}, { timestamps: true });

export default mongoose.model("Service", serviceSchema);