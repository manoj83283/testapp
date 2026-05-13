import express from 'express';
import dotenv from 'dotenv';
import cors from 'cors';
import { connectDB } from './config/db.js';
import authRoutes from './routes/authRoutes.js';
import serviceRoutes from './routes/serviceRoutes.js';
import bookingRoutes from './routes/bookingRoutes.js';
import reviewRoutes from './routes/reviewRoutes.js';

dotenv.config();
const app = express();
app.use(cors());
app.use(express.json());
connectDB();

app.use('/api/auth', authRoutes);
app.use('/api/services', serviceRoutes);
app.use('/api/bookings', bookingRoutes);
app.use('/api/reviews', reviewRoutes);

app.get('/', (req, res) => res.send('Backend API running'));

const PORT = process.env.PORT || 5000;
const server = app.listen(PORT, () => console.log(`✅ Server running on port ${PORT}`));

// Socket.io for chat/notifications
import { Server } from 'socket.io';
const io = new Server(server, { cors: { origin: '*' } });
io.on('connection', socket => {
  console.log('User connected:', socket.id);
  socket.on('sendMessage', data => io.emit('receiveMessage', data));
});