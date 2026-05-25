import mongoose from "mongoose";

const serviceSchema = new mongoose.Schema(
  {
    // ✅ Basic details
    name: { type: String, required: true, trim: true },

    providerName: {
      type: String,
      required: true,
      trim: true,
    },

    // ✅ IMPORTANT (needed for Flutter category match)
    category: {
      type: String,
      required: true,
      trim: true,
      lowercase: true,
    },

    iconURL: { type: String, default: "" },
    description: { type: String },

    // ✅ Pricing
    pricePerDay: { type: Number, default: 0 },
    pricePerHour: { type: Number, default: 0 },
    basePrice: { type: Number, default: 0 },

    // ✅ Simple location (Flutter uses string)
    location: {
      type: String,
      required: true,
        trim: true,
     },
     
    imageUrl: {
      type: String,
      default: "",
    },
    // ✅ Ratings
    rating: { type: Number, default: 0 },
    reviewCount: { type: Number, default: 0 },

    // ✅ Provider link
    provider: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "User",
    },

    isAvailable: {
      type: Boolean,
      default: true,
    },
  },
  { timestamps: true }
);

const Service = mongoose.model("Service", serviceSchema);

export default Service;