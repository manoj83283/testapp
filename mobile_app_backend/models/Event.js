import mongoose from 'mongoose';

const eventSchema = new mongoose.Schema({
  title: String,
  description: String,
  location: String,
  date: Date,
  providerId: { type: mongoose.Schema.Types.ObjectId, ref: 'Provider' },
});

export default mongoose.model('Event', eventSchema);