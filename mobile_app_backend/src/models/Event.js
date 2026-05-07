import mongoose from "mongoose";

const eventSchema = new mongoose.Schema({
  bookingId: { type: mongoose.Schema.Types.ObjectId, ref: "Booking", required: true },
  status: String, // e.g., "Provider on the way", "Work started", "Work completed"
  timestamp: { type: Date, default: Date.now },
}, { timestamps: true });

export default mongoose.model("Event", eventSchema);