import mongoose from "mongoose";

const serviceSchema = new mongoose.Schema(
  {
    /// ✅ BASIC INFO
    name: {
      type: String,
      required: true,
      trim: true,
    },

    category: {
      type: String,
      required: true,
      lowercase: true,
      trim: true,
    },

    description: {
      type: String,
      default: "",
    },

    serviceType: {
      type: String,
      default: "",
    },

    /// ✅ PRICING
    pricePerDay: {
      type: Number,
      default: 0,
    },

    pricePerHour: {
      type: Number,
      default: 0,
    },

    basePrice: {
      type: Number,
      default: 0,
    },

    /// ✅ LOCATION (STRING ✅ NO GEO ERROR)
    location: {
      type: String,
      required: true,
      trim: true,
    },

    /// ✅ MEDIA
    imageUrl: {
      type: String,
      default: "",
    },

    images: [
      {
        type: String,
      },
    ],

    /// ✅ TAGS / SEARCH
    tags: [
      {
        type: String,
      },
    ],

    /// ✅ PROVIDER RELATION
    provider: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "User",
      required: true,
    },

    providerName: {
      type: String,
      default: "",
    },

    /// ✅ VISIBILITY FLAG
    isAvailable: {
      type: Boolean,
      default: true,
    },
  },
  {
    timestamps: true,
  }
);

export default mongoose.model("Service", serviceSchema);
