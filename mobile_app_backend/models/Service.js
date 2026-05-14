import mongoose from "mongoose";

const serviceSchema = new mongoose.Schema(
  {
    // Basic details
    name: { type: String, required: true },
    iconURL: { type: String, required: true },
    description: { type: String },

    // Pricing details
    pricePerDay: { type: Number, default: 0 },
    pricePerHour: { type: Number, default: 0 },
    basePrice: { type: Number, default: 0 },

    // Location info (for provider or service area)
    location: {
      type: {
        type: String,
        enum: ["Point"],
        default: "Point",
      },
      coordinates: {
        type: [Number], // [longitude, latitude]
        default: [0, 0],
      },
      address: { type: String },
      city: { type: String },
      state: { type: String },
      pincode: { type: String },
    },

    // Analytics
    avgRating: { type: Number, default: 0 },
    providerCount: { type: Number, default: 0 },

    // Relationships (optional)
    providerIds: [{ type: mongoose.Schema.Types.ObjectId, ref: "Provider" }],
  },
  { timestamps: true }
);

// Enable geospatial queries
serviceSchema.index({ location: "2dsphere" });

const Service = mongoose.model("Service", serviceSchema);
export default Service;