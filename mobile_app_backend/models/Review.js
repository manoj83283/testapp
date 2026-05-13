import mongoose from 'mongoose';

const reviewSchema = new mongoose.Schema({
  customerId: { type: mongoose.Schema.Types.ObjectId, ref: 'User' },
  providerId: { type: mongoose.Schema.Types.ObjectId, ref: 'Provider' },
  rating: Number,
  text: String,
  mediaUrls: [String]
});

export default mongoose.model('Review', reviewSchema);