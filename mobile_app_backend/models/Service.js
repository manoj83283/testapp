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
      trim: true,
    },

    serviceType: {
      type: String, // hourly / fixed / package
      default: "fixed",
    },

    /// ✅ PRICING SYSTEM 💰
    price: {
      type: Number, // ✅ MAIN PRICE (for easy usage)
      default: 0,
    },

    pricePerHour: {
      type: Number,
      default: 0,
    },

    pricePerDay: {
      type: Number,
      default: 0,
    },

    basePrice: {
      type: Number,
      default: 0,
    },

    /// ✅ LOCATION (SAFE VERSION - STRING ✅)
    location: {
      type: String,
      required: true,
      trim: true,
    },

    /// ✅ FUTURE GEO SUPPORT (OPTIONAL)
    geoLocation: {
      type: {
        type: String,
        enum: ["Point"],
      },
      coordinates: {
        type: [Number], // [lng, lat]
      },
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

    /// ✅ SEARCH TAGS 🔍
    tags: [
      {
        type: String,
        lowercase: true,
      },
    ],

    /// ✅ PROVIDER RELATION 🔥
    provider: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "User",
      required: true,
    },

    providerName: {
      type: String,
      default: "",
    },

    /// ✅ RATING SYSTEM ⭐
    rating: {
      type: Number,
      default: 0,
    },

    totalReviews: {
      type: Number,
      default: 0,
    },

    /// ✅ AVAILABILITY
    isAvailable: {
      type: Boolean,
      default: true,
    },

    isActive: {
      type: Boolean,
      default: true,
    },

    /// ✅ FEATURE FLAGS
    isPopular: {
      type: Boolean,
      default: false,
    },

    isRecommended: {
      type: Boolean,
      default: false,
    },
  },
  {
    timestamps: true,
  }
);


/// ✅ INDEXES (IMPORTANT FOR PERFORMANCE 🔥)
serviceSchema.index({ category: 1 });
serviceSchema.index({ name: "text", description: "text", tags: "text" });


/// ✅ EXPORT MODEL
const Service = mongoose.model("Service", serviceSchema);
export default Service;