import Service from "../models/service.js";

// ✅ CREATE SERVICE (Provider adds service)
export const createService = async (req, res) => {
  try {
    const {
      name,
      providerName,
      category,
      description,
      pricePerDay,
      location,
      serviceType,
      imageUrl   // ✅ ADD THIS
    } = req.body;

    if (!name || !providerName || !category || !location) {
      return res.status(400).json({
        message: "Required fields missing",
      });
    }

    const service = await Service.create({
      name,
      providerName,
      category: category.toLowerCase().trim(),
      description,
      pricePerDay,
      location,
      serviceType,
      imageUrl, // ✅ STORE IMAGE
      provider: req.user?.id,
    });

    res.status(201).json({
      message: "Service created successfully",
      service,
    });
  } catch (err) {
    res.status(500).json({
      message: "Failed to create service",
      error: err.message,
    });
  }
};


// ✅ GET SERVICES (with category filter)
export const getServices = async (req, res) => {
  try {
    const { category } = req.query;

    const filter = {
      isAvailable: true,
    };

    // ✅ FILTER BY CATEGORY
    if (category) {
      filter.category = category.toLowerCase().trim();
    }

    const services = await Service.find(filter).sort({
      createdAt: -1,
    });

    res.status(200).json(services);
  } catch (err) {
    res.status(500).json({
      message: "Failed to fetch services",
      error: err.message,
    });
  }
};