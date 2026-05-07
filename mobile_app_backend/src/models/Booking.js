import mongoose from "mongoose";

const bookingSchema = new mongoose.Schema({
  userId: { type: mongoose.Schema.Types.ObjectId, ref: "User", required: true },
  serviceId: { type: mongoose.Schema.Types.ObjectId, ref: "Service", required: true },
  providerId: { type: mongoose.Schema.Types.ObjectId, ref: "User", required: true },
  date: { type: Date, required: true },
  status: {
    type: String,
    enum: ["Pending", "Confirmed", "In Progress", "Completed", "Cancelled"],
    default: "Pending",
  },
  paymentStatus: {
    type: String,
    enum: ["Unpaid", "Paid", "Refunded"],
    default: "Unpaid",
  },
  totalAmount: Number,
  notes: String,
}, { timestamps: true });

export default mongoose.model("Booking", bookingSchema);