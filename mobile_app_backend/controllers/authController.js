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
// ✅ ✅ REGISTER USER (UPDATED ✅)
// =======================================================
export const registerUser = async (req, res) => {
  try {
    const { name, email, phone, location, dob, shopName } = req.body;

    /// ✅ REQUIRED VALIDATION
    if (!name || !email || !phone || !location || !dob) {
      return res.status(400).json({
        msg: "All required fields must be filled",
      });
    }

    /// ✅ CLEAN DATA
    const cleanName = name.trim();
    const cleanEmail = email.toLowerCase().trim();
    const cleanPhone = phone.trim();

    /// ✅ AGE VALIDATION (18+)
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
    const userExists = await User.findOne({ email: cleanEmail });

    if (userExists) {
      return res.status(400).json({
        msg: "User already exists",
      });
    }

    /// ✅ CREATE USER
    const user = await User.create({
      name: cleanName,
      email: cleanEmail,
      phone: cleanPhone,
      location,
      dob,
      shopName: shopName || "",
    });

    return res.status(201).json({
      message: "✅ User registered successfully",
      user,
    });

  } catch (error) {
    console.error("❌ Register error:", error);

    res.status(500).json({
      msg: error.message,
    });
  }
};

// =======================================================
// ✅ GOOGLE LOGIN
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

    /// ✅ CREATE IF NOT EXISTS
    if (!user) {
      const [firstName, ...rest] = name.split(" ");
      const lastName = rest.join(" ") || "";

      user = await User.create({
        firstName,
        lastName,
        email: email.toLowerCase().trim(),
        phone: "0000000000",
        password: "google_auth",
        role: "user",
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
// ✅ SIGNUP (MAIN API)
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
      dob,
      location,
    } = req.body;

    /// ✅ VALIDATION
    if (!firstName || !lastName || !email || !phone || !password || !dob || !location) {
      return res.status(400).json({
        message: "All fields are required",
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
        message: "You must be at least 18 years old",
      });
    }

    /// ✅ EXISTS CHECK
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
      dob,
      location,
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

    res.status(500).json({
      message: "Server error during signup",
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
        message: "Email and password are required",
      });
    }

    email = email.toLowerCase().trim();

    const user = await User.findOne({ email });

    if (!user) {
      return res.status(400).json({
        message: "Invalid email or password",
      });
    }

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

    res.status(500).json({
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