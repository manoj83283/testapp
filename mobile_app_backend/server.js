import express from "express";
import dotenv from "dotenv";
import cors from "cors";
import http from "http";
import { Server } from "socket.io";

import connectDB from "./config/db.js";

/// ✅ ROUTES
import authRoutes from "./routes/authRoutes.js";
import chatRoutes from "./routes/chatRoutes.js";
import serviceRoutes from "./routes/serviceRoutes.js";
import bookingRoutes from "./routes/bookingRoutes.js";
import reviewRoutes from "./routes/reviewRoutes.js";

dotenv.config();

const app = express();

/// ✅ HTTP SERVER
const server = http.createServer(app);

/// ✅ ✅ SOCKET.IO (GLOBAL EXPORT 🔥)
export const io = new Server(server, {
  cors: {
    origin: "*", // ✅ allow all (later restrict in prod)
    methods: ["GET", "POST", "PUT", "DELETE"],
  },
});

/// ✅ DB CONNECTION
connectDB();

/// ✅ MIDDLEWARE
app.use(cors()); // ✅ CORS FIX APPLIED
app.use(express.json());

/// ✅ ROUTES
app.use("/api/auth", authRoutes);
app.use("/api/chat", chatRoutes);
app.use("/api/services", serviceRoutes);
app.use("/api/bookings", bookingRoutes);
app.use("/api/reviews", reviewRoutes);

/// ✅ ROOT CHECK
app.get("/", (req, res) => {
  res.send("✅ Backend + Socket running");
});

/// ✅ ✅ ✅ SOCKET EVENTS (REAL-TIME SYSTEM)
io.on("connection", (socket) => {
  console.log("✅ User connected:", socket.id);

  /// ✅ JOIN ROOM (Booking Chat Room)
  socket.on("joinRoom", (roomId) => {
    socket.join(roomId);
    console.log("📦 Joined room:", roomId);
  });

  /// ✅ SEND MESSAGE (CHAT)
  socket.on("sendMessage", (data) => {
    try {
      const { roomId, message, senderId } = data;

      if (!roomId || !message) {
        console.log("⚠️ Invalid message data");
        return;
      }

      console.log("💬 Message:", data);

      io.to(roomId).emit("receiveMessage", {
        message,
        senderId,
        roomId,
        createdAt: new Date(),
      });
    } catch (error) {
      console.error("❌ Message Error:", error.message);
    }
  });

  /// ✅ NEW BOOKING (REAL-TIME ORDER PUSH)
  socket.on("newBooking", (booking) => {
    try {
      console.log("🆕 New Booking:", booking?._id);

      /// broadcast globally
      io.emit("bookingUpdate", booking);
    } catch (error) {
      console.error("❌ Booking Error:", error.message);
    }
  });

  /// ✅ BOOKING STATUS UPDATE
  socket.on("bookingStatusChanged", (booking) => {
    try {
      console.log("🔄 Booking Updated:", booking?._id);

      /// global update
      io.emit("bookingUpdate", booking);

      /// room-specific update (chat sync)
      if (booking?.chatRoomId) {
        io.to(booking.chatRoomId).emit("bookingUpdate", booking);
      }
    } catch (error) {
      console.error("❌ Status Update Error:", error.message);
    }
  });

  /// ✅ DISCONNECT
  socket.on("disconnect", () => {
    console.log("❌ Disconnected:", socket.id);
  });
});

/// ✅ START SERVER
const PORT = process.env.PORT || 5000;

server.listen(PORT, () => {
  console.log(`🚀 Server running on port ${PORT}`);
});