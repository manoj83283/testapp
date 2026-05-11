import express from 'express';
import { getEventServices, seedEventServices } from '../controllers/eventServiceController.js';
import { protect } from '../middleware/authMiddleware.js';

const router = express.Router();

// Protected route to get all event services
router.get('/', protect, getEventServices);

// Optional route to seed sample services
router.post('/seed', seedEventServices);

export default router;