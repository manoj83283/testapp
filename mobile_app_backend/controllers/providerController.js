import Provider from '../models/provider.js';

export const createProvider = async (req, res) => {
  try {
    const provider = await Provider.create(req.body);
    res.status(201).json(provider);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

export const getProviders = async (req, res) => {
  const providers = await Provider.find();
  res.json(providers);
};