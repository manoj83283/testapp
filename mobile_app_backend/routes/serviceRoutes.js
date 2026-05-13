import express from 'express';
import { createService, getServices } from '../controllers/serviceController.js';
import { protect } from '../middleware/authMiddleware.js';
const router = express.Router();

router.post('/', protect, createService);
router.get('/', getServices);

export default router;