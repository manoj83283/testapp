import Service from "../models/service.js";


// ===========================================================
// ✅ DISTANCE FUNCTION (NEW - NEAREST LOGIC)
// ===========================================================
function getDistance(lat1, lon1, lat2, lon2) {
  const R = 6371;

  const dLat = (lat2 - lat1) * Math.PI / 180;
  const dLon = (lon2 - lon1) * Math.PI / 180;

  const a =
    Math.sin(dLat / 2) ** 2 +
    Math.cos(lat1 * Math.PI / 180) *
    Math.cos(lat2 * Math.PI / 180) *
    Math.sin(dLon / 2) ** 2;

  return R * 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
}


// ===========================================================
// ✅ CREATE SERVICE (ONLY PROVIDER)
// ===========================================================
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


// ===========================================================
// ✅ ✅ ✅ GET SERVICES (MERGED + UPGRADED)
// ===========================================================
export const getServices = async (req, res) => {
  try {
    const {
      category,
      search,
      minPrice,
      maxPrice,
      lat,
      lng,
      sort,
    } = req.query;

    const filter = {
      isAvailable: true,
      isActive: true,
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
      .populate("provider")
      .sort({ createdAt: -1 });

    let updated = services.map((s) => {
      let distance = 999;

      if (lat && lng && s.provider?.location?.coordinates) {
        const lat2 = s.provider.location.coordinates[1];
        const lng2 = s.provider.location.coordinates[0];

        distance = getDistance(Number(lat), Number(lng), lat2, lng2);
      }

      return {
        ...s._doc,
        distance,
      };
    });

    updated.sort((a, b) => {
      const scoreA =
        (a.distance || 999) * 0.7 +
        (a.pricePerDay || 500) * 0.3;

      const scoreB =
        (b.distance || 999) * 0.7 +
        (b.pricePerDay || 500) * 0.3;

      return scoreA - scoreB;
    });

    if (sort === "nearest") {
      updated.sort((a, b) => a.distance - b.distance);
    }

    if (sort === "low_price") {
      updated.sort((a, b) =>
        (a.pricePerDay || 0) - (b.pricePerDay || 0)
      );
    }

    if (sort === "high_price") {
      updated.sort((a, b) =>
        (b.pricePerDay || 0) - (a.pricePerDay || 0)
      );
    }

    console.log(`✅ Services fetched: ${updated.length}`);

    res.status(200).json(updated);

  } catch (err) {
    console.error("❌ Get Services Error:", err.message);

    res.status(500).json({
      message: "Failed to fetch services",
      error: err.message,
    });
  }
};


// ===========================================================
// ✅ GET PROVIDER'S OWN SERVICES
// ===========================================================
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


// ===========================================================
// ✅ UPDATE SERVICE (🔥 UPDATED WITH REAL-TIME REFRESH)
export const updateService = async (req, res) => {
  try {
    const service = await Service.findById(req.params.id);

    if (!service) {
      return res.status(404).json({
        message: "Service not found",
      });
    }

    if (service.provider.toString() !== req.user.id) {
      return res.status(403).json({
        message: "Not allowed",
      });
    }

    Object.assign(service, req.body);

    if (req.body.category) {
      service.category = req.body.category.toLowerCase().trim();
    }

    await service.save();

    // ✅ ✅ YOUR REQUIRED CHANGE
    // ✅ notify instantly all users (customer + providers)
    global.io.emit("refreshServices");

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


// ===========================================================
// ✅ DELETE SERVICE
// ===========================================================
export const deleteService = async (req, res) => {
  try {
    const service = await Service.findById(req.params.id);

    if (!service) {
      return res.status(404).json({
        message: "Service not found",
      });
    }

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