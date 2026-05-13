import Service from '../models/service.js';

// Provider creates a service
export const createService = async (req, res) => {
  try {
    const service = await Service.create({ ...req.body, providerId: req.user.id });
    res.status(201).json(service);
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
};

// Everyone can view services
export const getServices = async (req, res) => {
  const services = await Service.find().populate('providerId', 'name email');
  res.json(services);
};