import mongoose from 'mongoose';

const providerSchema = new mongoose.Schema({
  userId: { type: mongoose.Schema.Types.ObjectId, ref: 'User' },
  businessName: String,
  servicesOffered: [String],
  rating: { type: Number, default: 0 }
});

export default mongoose.model('Provider', providerSchema);