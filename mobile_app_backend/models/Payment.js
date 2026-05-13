import mongoose from "mongoose";

const paymentSchema = new mongoose.Schema({
  bookingId: { type: mongoose.Schema.Types.ObjectId, ref: "Booking", required: true },
  userId: { type: mongoose.Schema.Types.ObjectId, ref: "User", required: true },
  providerId: { type: mongoose.Schema.Types.ObjectId, ref: "User", required: true },
  amount: { type: Number, required: true },
  paymentMethod: { type: String, enum: ["Card", "UPI", "Wallet", "Cash"], required: true },
  transactionId: String,
  status: { type: String, enum: ["Success", "Failed", "Pending"], default: "Pending" },
}, { timestamps: true });

export default mongoose.model("Payment", paymentSchema);