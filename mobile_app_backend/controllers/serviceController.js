import Service from "../models/service.js";



/// ✅ CREATE SERVICE (ONLY PROVIDER)
export const createService = async (req, res) => {
  try {

    /// ✅ ROLE CHECK
    if (req.user?.role !== "provider") {
      return res.status(403).json({
        message: "❌ Only service providers can add services",
      });
    }

    const {
      name,
      providerName,
      category,
      description,
      pricePerDay,
      pricePerHour,
      basePrice,
      location,
      serviceType,
      imageUrl,
      images,
      tags,
    } = req.body;

    /// ✅ VALIDATION
    if (!name || !category || !location) {
      return res.status(400).json({
        message: "Required fields missing",
      });
    }

    const normalizedCategory = category.toLowerCase().trim();

    const service = await Service.create({
      name: name.trim(),

      providerName:
        providerName?.trim() || req.user?.firstName || "Provider",

      category: normalizedCategory,

      description: description || "",
      serviceType: serviceType || "",

      pricePerDay: Number(pricePerDay) || 0,
      pricePerHour: Number(pricePerHour) || 0,
      basePrice: Number(basePrice) || 0,

      location: location.trim(),

      imageUrl: imageUrl || "",

      images: images?.length
        ? images
        : imageUrl
        ? [imageUrl]
        : [],

      tags: tags || [],

      provider: req.user.id,

      isAvailable: true,
    });

    console.log("✅ Service Created:", service.name);

    res.status(201).json({
      message: "✅ Service created successfully",
      service,
    });

  } catch (err) {
    console.error("❌ Create Service Error:", err.message);

    res.status(500).json({
      message: "Failed to create service",
      error: err.message,
    });
  }
};



/// ✅ GET SERVICES (CUSTOMER SIDE)
export const getServices = async (req, res) => {
  try {
    const { category, search, minPrice, maxPrice } = req.query;

    const filter = {
      isAvailable: true, // ✅ only visible services
    };

    if (category) {
      filter.category = category.toLowerCase().trim();
    }

    if (minPrice || maxPrice) {
      filter.pricePerDay = {};

      if (minPrice) filter.pricePerDay.$gte = Number(minPrice);
      if (maxPrice) filter.pricePerDay.$lte = Number(maxPrice);
    }

    if (search) {
      const query = search.toLowerCase().trim();

      filter.$or = [
        { name: { $regex: query, $options: "i" } },
        { providerName: { $regex: query, $options: "i" } },
        { serviceType: { $regex: query, $options: "i" } },
        { location: { $regex: query, $options: "i" } },
      ];
    }

    const services = await Service.find(filter)
      .populate("provider", "firstName email")
      .sort({ createdAt: -1 });

    console.log(`✅ Services fetched: ${services.length}`);

    res.status(200).json(services);

  } catch (err) {
    console.error("❌ Get Services Error:", err.message);

    res.status(500).json({
      message: "Failed to fetch services",
      error: err.message,
    });
  }
};



/// ✅ GET PROVIDER'S OWN SERVICES
export const getMyServices = async (req, res) => {
  try {

    if (req.user?.role !== "provider") {
      return res.status(403).json({
        message: "Not allowed",
      });
    }

    const services = await Service.find({
      provider: req.user.id,
    }).sort({ createdAt: -1 });

    res.status(200).json(services);

  } catch (err) {
    res.status(500).json({
      message: "Failed to fetch provider services",
      error: err.message,
    });
  }
};



/// ✅ UPDATE SERVICE
export const updateService = async (req, res) => {
  try {
    const service = await Service.findById(req.params.id);

    if (!service) {
      return res.status(404).json({
        message: "Service not found",
      });
    }

    /// ✅ ONLY OWNER
    if (service.provider.toString() !== req.user.id) {
      return res.status(403).json({
        message: "Not allowed",
      });
    }

    /// ✅ UPDATE FIELDS
    Object.assign(service, req.body);

    /// ✅ NORMALIZE CATEGORY (if updated)
    if (req.body.category) {
      service.category = req.body.category.toLowerCase().trim();
    }

    await service.save();

    res.json({
      message: "✅ Service updated",
      service,
    });

  } catch (err) {
    res.status(500).json({
      message: "Update failed",
      error: err.message,
    });
  }
};



/// ✅ DELETE SERVICE
export const deleteService = async (req, res) => {
  try {
    const service = await Service.findById(req.params.id);

    if (!service) {
      return res.status(404).json({
        message: "Service not found",
      });
    }

    /// ✅ ONLY OWNER
    if (service.provider.toString() !== req.user.id) {
      return res.status(403).json({
        message: "Not allowed",
      });
    }

    await service.deleteOne();

    res.json({
      message: "✅ Service deleted",
    });

  } catch (err) {
    res.status(500).json({
      message: "Delete failed",
      error: err.message,
    });
  }
};