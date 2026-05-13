import Review from '../models/review.js';

export const createReview = async (req, res) => {
  try {
    const review = await Review.create(req.body);
    res.status(201).json(review);
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
};

export const getReviews = async (req, res) => {
  const reviews = await Review.find().populate('customerId providerId');
  res.json(reviews);
};