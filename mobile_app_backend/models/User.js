import mongoose from "mongoose";
import bcrypt from "bcryptjs";

const userSchema = new mongoose.Schema(
  {
    /// ✅ BASIC INFO
    firstName: {
      type: String,
      required: true,
      trim: true,
    },

    lastName: {
      type: String,
      required: true,
      trim: true,
    },

    email: {
      type: String,
      required: true,
      unique: true,
      lowercase: true,
      trim: true,
    },

    phone: {
      type: String,
      required: true,
    },

    password: {
      type: String,
      required: true,
      minlength: 6,
    },

    /// ✅ ROLE SYSTEM (CUSTOMER / PROVIDER)
    role: {
      type: String,
      enum: ["user", "provider"],
      default: "user",
    },

    /// ✅ ONLINE STATUS (REAL-TIME CHAT 🔥)
    isOnline: {
      type: Boolean,
      default: false,
    },

    /// ✅ LOCATION PERMISSION
    locationEnabled: {
      type: Boolean,
      default: true,
    },

    /// ✅ PROFILE IMAGE
    profileImage: {
      type: String,
      default: "",
    },

    /// ✅ ADDRESS (LIKE SWIGGY)
    
    addresses: [
      {
        type: {
          type: String,
          enum: ["home", "work", "corporate", "other"],
          default: "home",
        },
        addressLine: String,
        landmark: String,
        city: String,
        state: String,
        pincode: String,
        isDefault: {
          type: Boolean,
          default: false,
        },
      },
    ],


    /// ✅ GEO LOCATION (FUTURE READY)
    location: {
      type: {
        type: String,
        enum: ["Point"],
      },
      coordinates: {
        type: [Number], // [lng, lat]
      },
    },

    /// ✅ PROVIDER DETAILS (ONLY IF role = provider)
    servicesOffered: [
      {
        type: mongoose.Schema.Types.ObjectId,
        ref: "Service",
      },
    ],

    experience: {
      type: Number, // years
      default: 0,
    },

    rating: {
      type: Number,
      default: 0,
    },

    totalReviews: {
      type: Number,
      default: 0,
    },

    /// ✅ WALLET SYSTEM 💰
    walletBalance: {
      type: Number,
      default: 0,
    },

    /// ✅ NOTIFICATIONS
    notificationsEnabled: {
      type: Boolean,
      default: true,
    },
  },
  { timestamps: true }
);

/// ✅ GEO INDEX (IMPORTANT 🔥)
userSchema.index({ location: "2dsphere" });


/// ✅ HASH PASSWORD BEFORE SAVE
userSchema.pre("save", async function (next) {
  if (!this.isModified("password")) return next();

  const salt = await bcrypt.genSalt(10);
  this.password = await bcrypt.hash(this.password, salt);

  next();
});


/// ✅ COMPARE PASSWORD (LOGIN)
userSchema.methods.matchPassword = async function (enteredPassword) {
  return await bcrypt.compare(enteredPassword, this.password);
};


/// ✅ REMOVE PASSWORD FROM RESPONSE
userSchema.methods.toJSON = function () {
  const obj = this.toObject();
  delete obj.password;
  return obj;
};


/// ✅ EXPORT MODEL
export default mongoose.models.User || mongoose.model("User", userSchema);
