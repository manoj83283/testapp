import User from "../models/user.js";
import jwt from "jsonwebtoken";

const generateToken = (id) => {
  return jwt.sign(
    { id },
    process.env.JWT_SECRET || "secretkey",
    { expiresIn: "7d" }
  );
};

// ✅ SIGNUP
export const signup = async (req, res) => {
  try {
    console.log("📦 Signup req.body:", req.body);

    let { firstName, lastName, email, phone, password } = req.body;

    if (!firstName || !lastName || !email || !phone || !password) {
      return res.status(400).json({
        message: "All fields are required",
        received: {
          firstName,
          lastName,
          email,
          phone,
          password: password ? "provided" : "missing",
        },
      });
    }

    firstName = firstName.trim();
    lastName = lastName.trim();
    email = email.toLowerCase().trim();
    phone = phone.trim();

    const userExists = await User.findOne({ email });

    if (userExists) {
      return res.status(400).json({
        message: "User already exists",
      });
    }

    const user = await User.create({
      firstName,
      lastName,
      email,
      phone,
      password,
    });

    const token = generateToken(user._id);

    return res.status(201).json({
      message: "User registered successfully",
      token,
      user: {
        id: user._id,
        firstName: user.firstName,
        lastName: user.lastName,
        email: user.email,
        phone: user.phone,
        role: user.role || "user",
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

// ✅ SIGNIN
export const signin = async (req, res) => {
  try {
    console.log("📦 Login req.body:", req.body);

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
      message: "Login successful",
      token,
      user: {
        id: user._id,
        firstName: user.firstName,
        lastName: user.lastName,
        email: user.email,
        phone: user.phone,
        role: user.role || "user",
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