import User from "../models/user.js";

// ======================================================
// ✅ ADD ADDRESS
// ======================================================
export const addAddress = async (req, res) => {
  try {
    const { type, addressLine, landmark, city, state, pincode } = req.body;

    if (!addressLine || !city || !state || !pincode) {
      return res.status(400).json({
        msg: "Required fields missing",
      });
    }

    const user = await User.findById(req.user.id);

    const newAddress = {
      type: type || "home",
      addressLine,
      landmark: landmark || "",
      city,
      state,
      pincode,
      isDefault: user.addresses.length === 0, // first = default
    };

    user.addresses.push(newAddress);

    await user.save();

    res.json(user.addresses);

  } catch (error) {
    res.status(500).json({ msg: error.message });
  }
};

// ======================================================
// ✅ GET ADDRESSES
// ======================================================
export const getAddresses = async (req, res) => {
  try {
    const user = await User.findById(req.user.id);
    res.json(user.addresses);
  } catch (error) {
    res.status(500).json({ msg: error.message });
  }
};

// ======================================================
// ✅ UPDATE ADDRESS (EDIT)
// ======================================================
export const updateAddress = async (req, res) => {
  try {
    const { id } = req.params;

    const user = await User.findById(req.user.id);

    const address = user.addresses.id(id);

    if (!address) {
      return res.status(404).json({ msg: "Address not found" });
    }

    // update fields
    address.type = req.body.type || address.type;
    address.addressLine = req.body.addressLine || address.addressLine;
    address.landmark = req.body.landmark || address.landmark;
    address.city = req.body.city || address.city;
    address.state = req.body.state || address.state;
    address.pincode = req.body.pincode || address.pincode;

    await user.save();

    res.json(user.addresses);

  } catch (error) {
    res.status(500).json({ msg: error.message });
  }
};

// ======================================================
// ✅ DELETE ADDRESS
// ======================================================
export const deleteAddress = async (req, res) => {
  try {
    const user = await User.findById(req.user.id);

    user.addresses = user.addresses.filter(
      (addr) => addr._id.toString() !== req.params.id
    );

    await user.save();

    res.json(user.addresses);

  } catch (error) {
    res.status(500).json({ msg: error.message });
  }
};

// ======================================================
// ✅ SET DEFAULT ADDRESS (NEW ✅ PRODUCTION FEATURE)
// ======================================================
export const setDefaultAddress = async (req, res) => {
  try {
    const user = await User.findById(req.user.id);

    user.addresses.forEach((addr) => {
      addr.isDefault = addr._id.toString() === req.params.id;
    });

    await user.save();

    res.json(user.addresses);

  } catch (error) {
    res.status(500).json({ msg: error.message });
  }
};