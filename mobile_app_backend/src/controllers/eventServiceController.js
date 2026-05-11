import EventService from '../models/EventService.js';

// Get all event services
export const getEventServices = async (req, res) => {
  try {
    const services = await EventService.find();
    res.status(200).json({ success: true, services });
  } catch (error) {
    console.error('Fetch error:', error);
    res.status(500).json({ success: false, message: 'Server error fetching event services' });
  }
};

// Seed sample event services
export const seedEventServices = async (req, res) => {
  try {
    const sampleServices = [
      { name: 'Photographer', icon: 'camera_alt', category: 'Media', description: 'Event photography and instant photo printing' },
      { name: 'Makeup Artist', icon: 'brush', category: 'Beauty', description: 'Professional makeup for events' },
      { name: 'Decoration Artist', icon: 'celebration', category: 'Decor', description: 'Event decoration and theme setup' },
      { name: 'Dancers', icon: 'music_note', category: 'Entertainment', description: 'Dance performances for events' },
      { name: 'Singers', icon: 'mic', category: 'Entertainment', description: 'Live singing performances' },
      { name: 'Mehandi Artist', icon: 'spa', category: 'Beauty', description: 'Mehandi designs for weddings and parties' },
      { name: 'DJ', icon: 'headphones', category: 'Music', description: 'DJ and sound setup for events' },
      { name: 'Sangeet Organizer', icon: 'event', category: 'Music', description: 'Sangeet and musical night arrangements' },
      { name: 'Babysitters', icon: 'child_care', category: 'Care', description: 'Child care during events' },
      { name: 'Catering Services', icon: 'restaurant', category: 'Food', description: 'Food and beverage catering' },
      { name: 'Cookers & Chefs', icon: 'local_dining', category: 'Food', description: 'Professional cooks and chefs for events' },
      { name: 'Funny Events Spot Artists', icon: 'emoji_emotions', category: 'Entertainment', description: 'Comedians and entertainers for crowd engagement' },
      { name: 'Painters', icon: 'palette', category: 'Art', description: 'Instant painting and art creation during events' },
      { name: 'Engagement Activity Providers', icon: 'groups', category: 'Fun', description: 'Games and interactive activities for guests' },
    ];

    await EventService.deleteMany();
    await EventService.insertMany(sampleServices);

    res.status(201).json({ success: true, message: 'Event services seeded successfully' });
  } catch (error) {
    console.error('Seed error:', error);
    res.status(500).json({ success: false, message: 'Error seeding event services' });
  }
};