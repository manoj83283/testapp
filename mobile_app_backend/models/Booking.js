import mongoose from "mongoose";

const bookingSchema = new mongoose.Schema(
  {
    /// ✅ CUSTOMER (WHO BOOKED)
    user: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "User",
      required: true,
    },

    /// ✅ SERVICE (WHAT BOOKED)
    service: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "Service",
      required: true,
    },

    /// ✅ PROVIDER (VERY IMPORTANT 🔥)
    /// Helps provider dashboard directly fetch bookings
    provider: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "User",
    },

    /// ✅ BOOKING DETAILS
    date: {
      type: Date,
    },

    notes: {
      type: String,
      trim: true,
    },

    /// ✅ ADDRESS DETAILS (LIKE SWIGGY)
    address: {
      type: String,
      required: true,
    },

    location: {
      type: String, // later upgrade → GeoJSON
    },

    /// ✅ PRICING SYSTEM 💰
    hoursBooked: {
      type: Number,
      default: 1,
    },

    pricePerHour: {
      type: Number,
    },

    totalPrice: {
      type: Number,
    },

    /// ✅ PAYMENT SYSTEM
    paymentMethod: {
      type: String,
      enum: ["COD", "ONLINE"],
      default: "COD",
    },

    paymentStatus: {
      type: String,
      enum: ["pending", "paid", "failed"],
      default: "pending",
    },

    /// ✅ ORDER STATUS FLOW (IMPORTANT 🔥)
    status: {
      type: String,
      enum: [
        "pending",     // user placed
        "accepted",    // provider accepted
        "rejected",    // provider rejected
        "in_progress", // work started
        "completed",   // done
        "cancelled",   // user cancelled
      ],
      default: "pending",
    },

    /// ✅ TRACKING (FUTURE READY)
    startedAt: Date,
    completedAt: Date,

    /// ✅ RATINGS (POST COMPLETION 🔥)
    rating: {
      type: Number,
      min: 1,
      max: 5,
    },

    review: String,
  },
  {
    timestamps: true,
  }
);

export default mongoose.model("Booking", bookingSchema);