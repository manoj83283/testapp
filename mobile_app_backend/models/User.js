import mongoose from "mongoose";
import bcrypt from "bcryptjs";

const userSchema = new mongoose.Schema(
  {
    firstName: { 
      type: String, 
      required: true,
      trim: true 
    },

    lastName: { 
      type: String, 
      required: true,
      trim: true 
    },

    email: { 
      type: String, 
      required: true, 
      unique: true,
      lowercase: true,
      trim: true 
    },

    phone: { 
      type: String, 
      required: true 
    },

    password: { 
      type: String, 
      required: true,
      minlength: 6
    },

    // ✅ optional but useful for frontend compatibility
    role: {
      type: String,
      default: "user"
    }
  },
  { timestamps: true }
);


// ✅ Hash password before saving
userSchema.pre("save", async function (next) {
  if (!this.isModified("password")) return next();

  const salt = await bcrypt.genSalt(10);
  this.password = await bcrypt.hash(this.password, salt);

  next();
});


// ✅ Compare password (for login)
userSchema.methods.matchPassword = async function (enteredPassword) {
  return await bcrypt.compare(enteredPassword, this.password);
};



// ✅ Hide password in response (VERY IMPORTANT)
userSchema.methods.toJSON = function () {
  const userObj = this.toObject();
  delete userObj.password;
  return userObj;
};


const User = mongoose.model("User", userSchema);
export default User;
