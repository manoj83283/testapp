import express from "express";
import dotenv from "dotenv";
import cors from "cors";
import http from "http";
import { Server } from "socket.io";

import connectDB from "./config/db.js";

// ✅ ROUTES
import authRoutes from "./routes/authRoutes.js";
import chatRoutes from "./routes/chatRoutes.js";
import serviceRoutes from "./routes/serviceRoutes.js";
import bookingRoutes from "./routes/bookingRoutes.js";
import reviewRoutes from "./routes/reviewRoutes.js";

dotenv.config();

const app = express();

/// ✅ CREATE HTTP SERVER
const server = http.createServer(app);

/// ✅ ✅ EXPORT SOCKET (VERY IMPORTANT)
export const io = new Server(server, {
  cors: {
    origin: "*",
    methods: ["GET", "POST"],
  },
});

/// ✅ DB
connectDB();

/// ✅ MIDDLEWARE
app.use(cors());
app.use(express.json());

/// ✅ ROUTES
app.use("/api/auth", authRoutes);
app.use("/api/chat", chatRoutes);
app.use("/api/services", serviceRoutes);
app.use("/api/bookings", bookingRoutes);
app.use("/api/reviews", reviewRoutes);

/// ✅ ROOT
app.get("/", (req, res) => {
  res.send("✅ Backend + Socket running");
});

/// ✅ ✅ SOCKET LOGIC
io.on("connection", (socket) => {
  console.log("✅ Connected:", socket.id);

  socket.on("joinRoom", (roomId) => {
    socket.join(roomId);
  });

  socket.on("sendMessage", (data) => {
    io.to(data.roomId).emit("receiveMessage", data);
  });

  /// ✅ REAL-TIME BOOKINGS (NEW 🔥)
  socket.on("newBooking", (booking) => {
    io.emit("bookingUpdate", booking);
  });

  socket.on("disconnect", () => {
    console.log("❌ Disconnected:", socket.id);
  });
});

/// ✅ START
const PORT = process.env.PORT || 5000;

server.listen(PORT, () => {
  console.log(`🚀 Server running on ${PORT}`);
});