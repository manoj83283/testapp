import bcrypt from 'bcryptjs';
import jwt from 'jsonwebtoken';
import ServiceProvider from '../models/ServiceProvider.js';

// Provider Signup
export const providerSignup = async (req, res) => {
  try {
    const { name, email, password, serviceType } = req.body;

    const existing = await ServiceProvider.findOne({ email });
    if (existing) return res.status(400).json({ success: false, message: 'Email already registered' });

    const hashedPassword = await bcrypt.hash(password, 10);
    const provider = await ServiceProvider.create({
      name,
      email,
      password: hashedPassword,
      serviceType,
    });

    const token = jwt.sign({ id: provider._id }, process.env.JWT_SECRET, { expiresIn: '1d' });
    res.status(201).json({ success: true, token, provider });
  } catch (err) {
    console.error(err);
    res.status(500).json({ success: false, message: 'Server error' });
  }
};

// Provider Login
export const providerLogin = async (req, res) => {
  try {
    const { email, password } = req.body;
    const provider = await ServiceProvider.findOne({ email });
    if (!provider) return res.status(404).json({ success: false, message: 'Provider not found' });

    const valid = await bcrypt.compare(password, provider.password);
    if (!valid) return res.status(401).json({ success: false, message: 'Invalid credentials' });

    const token = jwt.sign({ id: provider._id }, process.env.JWT_SECRET, { expiresIn: '1d' });
    res.status(200).json({ success: true, token, provider });
  } catch (err) {
    console.error(err);
    res.status(500).json({ success: false, message: 'Server error' });
  }
};