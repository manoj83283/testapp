import express from 'express';
import { providerSignup, providerLogin } from '../controllers/providerController.js';
import { updateProviderProfile } from '../controllers/providerProfileController.js';
import { protect } from '../middleware/authMiddleware.js';
import upload from '../middleware/uploadMiddleware.js';

const router = express.Router();

router.post('/signup', providerSignup);
router.post('/login', providerLogin);

// Upload photos/videos and update profile
router.put(
  '/profile',
  protect,
  upload.fields([{ name: 'photos', maxCount: 5 }, { name: 'videos', maxCount: 3 }]),
  updateProviderProfile
);

export default router;