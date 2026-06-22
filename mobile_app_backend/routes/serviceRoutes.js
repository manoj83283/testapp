import express from "express";
import Service from "../models/service.js"; // ✅ REQUIRED (for availability toggle)

import {
  createService,
  getServices,
  getMyServices,
  updateService,
  deleteService,
} from "../controllers/serviceController.js";

import {
  protect,
  authorizeRoles,
} from "../middleware/authMiddleware.js";

const router = express.Router();


/// ✅ CREATE SERVICE (PROVIDER ONLY)
router.post(
  "/",
  protect,
  authorizeRoles("provider"),
  createService
);


/// ✅ GET ALL SERVICES (PUBLIC + FILTER + LOCATION SORT SUPPORT ✅)
router.get("/", getServices);


/// ✅ GET MY SERVICES (PROVIDER DASHBOARD)
router.get(
  "/my",
  protect,
  authorizeRoles("provider"),
  getMyServices
);


/// ✅ UPDATE SERVICE
router.put(
  "/:id",
  protect,
  authorizeRoles("provider"),
  updateService
);


/// ✅ DELETE SERVICE
router.delete(
  "/:id",
  protect,
  authorizeRoles("provider"),
  deleteService
);


/// ✅ ✅ TOGGLE AVAILABILITY (VERY IMPORTANT FOR PROVIDER UX 🔥)
router.put(
  "/:id/availability",
  protect,
  authorizeRoles("provider"),
  async (req, res) => {
    try {
      const service = await Service.findByIdAndUpdate(
        req.params.id,
        { isAvailable: req.body.isAvailable },
        { new: true }
      );

      if (!service) {
        return res.status(404).json({
          message: "Service not found",
        });
      }

      res.json({
        message: "✅ Availability updated",
        service,
      });

    } catch (err) {
      res.status(500).json({
        message: err.message,
      });
    }
  }
);


/// ✅ EXPORT ROUTER
export default router;