import User from "../models/user.js";
import jwt from "jsonwebtoken";

/// ✅ GENERATE TOKEN
const generateToken = (id) => {
  return jwt.sign(
    { id },
    process.env.JWT_SECRET || "secretkey",
    { expiresIn: "7d" }
  );
};

// =======================================================
// ✅ GOOGLE LOGIN (User / Provider default = user)
// =======================================================
export const googleLogin = async (req, res) => {
  try {
    const { email, name } = req.body;

    if (!email || !name) {
      return res.status(400).json({
        message: "Email and name are required",
      });
    }

    let user = await User.findOne({ email });

    /// ✅ IF NOT EXIST → CREATE
    if (!user) {
      const [firstName, ...rest] = name.split(" ");
      const lastName = rest.join(" ") || "";

      user = await User.create({
        firstName,
        lastName,
        email: email.toLowerCase().trim(),
        phone: "0000000000", // placeholder
        password: "google_auth", // placeholder
        role: "user", // default role
      });
    }

    return res.status(200).json({
      message: "✅ Google login successful",
      token: generateToken(user._id),
      user: {
        id: user._id,
        firstName: user.firstName,
        lastName: user.lastName,
        email: user.email,
        role: user.role,
      },
    });

  } catch (err) {
    console.error("❌ Google login error:", err);
    res.status(500).json({
      message: err.message,
    });
  }
};

// =======================================================
// ✅ SIGNUP (User & Provider)
// =======================================================
export const signup = async (req, res) => {
  try {
    console.log("📦 Signup req.body:", req.body);

    let {
      firstName,
      lastName,
      email,
      phone,
      password,
      role,
    } = req.body;

    /// ✅ VALIDATION
    if (!firstName || !lastName || !email || !phone || !password) {
      return res.status(400).json({
        message: "All fields are required",
      });
    }

    /// ✅ CLEAN INPUT
    firstName = firstName.trim();
    lastName = lastName.trim();
    email = email.toLowerCase().trim();
    phone = phone.trim();

    /// ✅ CHECK EXISTING USER
    const userExists = await User.findOne({ email });

    if (userExists) {
      return res.status(400).json({
        message: "User already exists",
      });
    }

    /// ✅ CREATE USER
    const user = await User.create({
      firstName,
      lastName,
      email,
      phone,
      password,
      role: role === "provider" ? "provider" : "user",
    });

    const token = generateToken(user._id);

    return res.status(201).json({
      message: "✅ User registered successfully",
      token,
      user: {
        id: user._id,
        firstName: user.firstName,
        lastName: user.lastName,
        email: user.email,
        phone: user.phone,
        role: user.role,
      },
    });

  } catch (error) {
    console.error("❌ Signup error:", error);

    return res.status(500).json({
      message: "Server error during signup",
      error: error.message,
    });
  }
};

// =======================================================
// ✅ SIGNIN (Login User / Provider)
// =======================================================
export const signin = async (req, res) => {
  try {
    console.log("📦 Login req.body:", req.body);

    let { email, password } = req.body;

    /// ✅ VALIDATION
    if (!email || !password) {
      return res.status(400).json({
        message: "Email and password are required",
      });
    }

    email = email.toLowerCase().trim();

    /// ✅ FIND USER
    const user = await User.findOne({ email });

    if (!user) {
      return res.status(400).json({
        message: "Invalid email or password",
      });
    }

    /// ✅ CHECK PASSWORD
    const isMatch = await user.matchPassword(password);

    if (!isMatch) {
      return res.status(400).json({
        message: "Invalid email or password",
      });
    }

    const token = generateToken(user._id);

    return res.status(200).json({
      message: "✅ Login successful",
      token,
      user: {
        id: user._id,
        firstName: user.firstName,
        lastName: user.lastName,
        email: user.email,
        phone: user.phone,
        role: user.role,
      },
    });

  } catch (error) {
    console.error("❌ Login error:", error);

    return res.status(500).json({
      message: "Server error during login",
      error: error.message,
    });
  }
};

// =======================================================
// ✅ GET PROFILE
// =======================================================
export const getProfile = async (req, res) => {
  try {
    res.json({
      user: req.user,
    });
  } catch (error) {
    res.status(500).json({
      message: "Failed to load profile",
      error: error.message,
    });
  }
};