import mongoose from "mongoose";

const bookingSchema = new mongoose.Schema(
  {
    /// ✅ CUSTOMER (WHO BOOKED)
    user: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "User",
      required: true,
      index: true,
    },

    /// ✅ SERVICE (WHAT BOOKED)
    service: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "Service",
      required: true,
    },

    /// ✅ PROVIDER (IMPORTANT 🔥)
    provider: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "User",
      index: true,
    },

    /// ✅ BOOKING DETAILS
    date: {
      type: Date,
    },

    notes: {
      type: String,
      trim: true,
      default: "",
    },

    /// ✅ ADDRESS (LIKE SWIGGY)
    address: {
      type: String,
      required: true,
      trim: true,
    },

    location: {
      type: String, // upgrade later to GeoJSON
    },

    /// ✅ PRICING 💰
    hoursBooked: {
      type: Number,
      default: 1,
      min: 1,
    },

    pricePerHour: {
      type: Number,
      default: 0,
    },

    totalPrice: {
      type: Number,
      default: 0,
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

    /// ✅ ORDER STATUS FLOW 🔥
    status: {
      type: String,
      enum: [
        "pending",      // user placed
        "accepted",     // provider accepted
        "rejected",     // provider rejected
        "in_progress",  // work started
        "completed",    // done
        "cancelled",    // user cancelled
      ],
      default: "pending",
      index: true,
    },

    /// ✅ TRACKING (TIMELINE)
    startedAt: {
      type: Date,
    },

    completedAt: {
      type: Date,
    },

    cancelledAt: {
      type: Date,
    },

    /// ✅ RATING SYSTEM ⭐
    rating: {
      type: Number,
      min: 1,
      max: 5,
    },

    review: {
      type: String,
      trim: true,
    },

    /// ✅ CHAT ROOM (VERY IMPORTANT 🔥)
    /// Store bookingId as roomId
    chatRoomId: {
      type: String,
    },
  },
  {
    timestamps: true,
  }
);


/// ✅ INDEXES (PERFORMANCE BOOST 🚀)
bookingSchema.index({ user: 1, createdAt: -1 });
bookingSchema.index({ provider: 1, status: 1 });
bookingSchema.index({ service: 1 });


/// ✅ AUTO SET CHAT ROOM ID (BEST PRACTICE)
bookingSchema.pre("save", function (next) {
  if (!this.chatRoomId) {
    this.chatRoomId = this._id.toString();
  }
  next();
});


/// ✅ EXPORT
const Booking = mongoose.model("Booking", bookingSchema);
export default Booking;