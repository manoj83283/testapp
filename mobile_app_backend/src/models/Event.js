import mongoose from 'mongoose';

const eventServiceSchema = new mongoose.Schema({
  name: { type: String, required: true },
  icon: { type: String, required: true }, // store icon name or URL
  category: { type: String, required: true },
  description: { type: String },
});

const EventService = mongoose.model('EventService', eventServiceSchema);

export default EventService;