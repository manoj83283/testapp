import express from "express";
import {
  getAllServices,
  getFeaturedServices,
  getServicesByCategory,
  addService,
  updateService,
  deleteService,
} from "../controllers/serviceController.js";

const router = express.Router();

router.get("/", getAllServices);
router.get("/featured", getFeaturedServices);
router.get("/category/:category", getServicesByCategory);
router.post("/", addService);
router.put("/:id", updateService);
router.delete("/:id", deleteService);

export default router;