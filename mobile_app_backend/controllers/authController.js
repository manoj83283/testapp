import User from "../models/user.js";
import jwt from "jsonwebtoken";

// ================= TOKEN =================
const generateToken = (user) => {
  return jwt.sign(
    {
      id: user._id,
      role: user.role,
    },
    process.env.JWT_SECRET || "secret",
    { expiresIn: "7d" }
  );
};

// =======================================================
// ✅ ✅ ✅ SIGNUP (FINAL CLEAN VERSION)
// =======================================================
export const signup = async (req, res) => {
  try {

    let {
      firstName,
      lastName,
      email,
      phone,
      password,
      role,
      dob,
      location,
      shopName,
    } = req.body;

    /// ✅ VALIDATION
    if (
      !firstName ||
      !lastName ||
      !email ||
      !phone ||
      !password ||
      !dob ||
      !location ||
      !role
    ) {
      return res.status(400).json({
        msg: "All fields are required",
      });
    }

    /// ✅ CLEAN DATA
    firstName = firstName.trim();
    lastName = lastName.trim();
    email = email.toLowerCase().trim();
    phone = phone.trim();

    /// ✅ AGE VALIDATION
    const birthDate = new Date(dob);
    const today = new Date();

    let age = today.getFullYear() - birthDate.getFullYear();

    if (
      today.getMonth() < birthDate.getMonth() ||
      (today.getMonth() === birthDate.getMonth() &&
        today.getDate() < birthDate.getDate())
    ) {
      age--;
    }

    if (age < 18) {
      return res.status(400).json({
        msg: "You must be at least 18 years old",
      });
    }

    /// ✅ CHECK EXISTING USER
    const userExists = await User.findOne({ email });

    if (userExists) {
      return res.status(400).json({
        msg: "User already exists",
      });
    }

    /// ✅ CREATE USER (FIXED ✅)
    const user = await User.create({
      firstName,
      lastName,
      email,
      phone,
      password,
      dob,
      location,
      role: role === "provider" ? "provider" : "user",
      shopName: shopName || "",
    });

    /// ✅ TOKEN
    const token = generateToken(user);

    return res.status(201).json({
      message: "Signup successful",
      token,
      user,
    });

  } catch (error) {
    console.error("❌ Signup error:", error);

    res.status(500).json({
      msg: "Server error",
      error: error.message,
    });
  }
};

// =======================================================
// ✅ SIGNIN
// =======================================================
export const signin = async (req, res) => {
  try {

    let { email, password } = req.body;

    if (!email || !password) {
      return res.status(400).json({
        msg: "Email and password required",
      });
    }

    email = email.toLowerCase().trim();

    const user = await User.findOne({ email });

    if (!user || !(await user.matchPassword(password))) {
      return res.status(400).json({
        msg: "Invalid credentials",
      });
    }

    const token = generateToken(user);

    res.status(200).json({
      message: "Login successful",
      token,
      user,
    });

  } catch (error) {
    console.error("❌ Login error:", error);

    res.status(500).json({
      msg: error.message,
    });
  }
};

// =======================================================
// ✅ PROFILE
// =======================================================
export const getProfile = async (req, res) => {
  try {
    res.json({
      user: req.user,
    });
  } catch (error) {
    res.status(500).json({
      msg: error.message,
    });
  }
};