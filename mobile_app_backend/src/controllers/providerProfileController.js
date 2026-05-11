import ServiceProvider from '../models/ServiceProvider.js';

// Update provider profile
export const updateProviderProfile = async (req, res) => {
  try {
    const providerId = req.user.id;
    const { description, rating, pricePerHour, pricePerDay, location } = req.body;

    const updateData = { description, rating, pricePerHour, pricePerDay, location };

    // Add uploaded media
    if (req.files) {
      if (req.files.photos) {
        updateData['media.photos'] = req.files.photos.map(f => `/uploads/${f.filename}`);
      }
      if (req.files.videos) {
        updateData['media.videos'] = req.files.videos.map(f => `/uploads/${f.filename}`);
      }
    }

    const updated = await ServiceProvider.findByIdAndUpdate(providerId, updateData, { new: true });
    res.status(200).json({ success: true, provider: updated });
  } catch (err) {
    console.error(err);
    res.status(500).json({ success: false, message: 'Error updating profile' });
  }
};