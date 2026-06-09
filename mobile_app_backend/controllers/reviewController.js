import Review from "../models/review.js";
import Service from "../models/service.js";

export const addReview = async (req, res) => {
  try {
    const { serviceId, rating, comment } = req.body;

    if (!serviceId || !rating) {
      return res.status(400).json({
        message: "Service ID and rating required",
      });
    }

    const review = await Review.create({
      service: serviceId,
      user: req.user.id,
      rating,
      comment,
    });

    // ✅ UPDATE SERVICE RATING
    const reviews = await Review.find({ service: serviceId });

    const avgRating =
      reviews.reduce((acc, r) => acc + r.rating, 0) /
      reviews.length;

    await Service.findByIdAndUpdate(serviceId, {
      rating: avgRating,
      reviewCount: reviews.length,
    });

    res.json({
      message: "✅ Review added",
      review,
    });

  } catch (err) {
    res.status(500).json({
      message: "Failed to add review",
      error: err.message,
    });
  }
};
