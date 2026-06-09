import mongoose from "mongoose";

const reviewSchema = new mongoose.Schema({
  service: {
    type: mongoose.Schema.Types.ObjectId,
    ref: "Service",
  },
  user: {
    type: mongoose.Schema.Types.ObjectId,
    ref: "User",
  },
  rating: Number,
  comment: String,
});

export default mongoose.model("Review", reviewSchema);