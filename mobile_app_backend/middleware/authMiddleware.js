import jwt from "jsonwebtoken";
import User from "../models/User.js";

/// ✅ PROTECT ROUTES (AUTH CHECK)
export const protect = async (req, res, next) => {
  let token;

  // ✅ CHECK AUTH HEADER
  if (
    req.headers.authorization &&
    req.headers.authorization.startsWith("Bearer")
  ) {
    try {
      /// ✅ EXTRACT TOKEN
      token = req.headers.authorization.split(" ")[1];

      /// ✅ VERIFY TOKEN
      const decoded = jwt.verify(token, process.env.JWT_SECRET);

      /// ✅ FETCH USER (WITHOUT PASSWORD 🔥)
      req.user = await User.findById(decoded.id).select("-password");

      if (!req.user) {
        return res.status(401).json({
          message: "User not found",
        });
      }

      next();

    } catch (error) {
      console.error("❌ Auth Error:", error.message);

      return res.status(401).json({
        message: "Not authorized, token failed",
      });
    }
  } else {
    return res.status(401).json({
      message: "Not authorized, no token",
    });
  }
};


/// ✅ ROLE-BASED AUTH (IMPORTANT 🔥)
export const authorizeRoles = (...roles) => {
  return (req, res, next) => {
    if (!roles.includes(req.user.role)) {
      return res.status(403).json({
        message: "Access denied: insufficient permissions",
      });
    }
    next();
  };
};


/// ✅ OPTIONAL: ADMIN ONLY (FUTURE USE)
export const isAdmin = (req, res, next) => {
  if (req.user.role !== "admin") {
    return res.status(403).json({
      message: "Access denied: Admin only",
    });
  }
  next();
};