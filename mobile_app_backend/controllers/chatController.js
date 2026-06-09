import Chat from "../models/chat.js";

/// ✅ SEND MESSAGE
export const sendMessage = async (req, res) => {
  try {
    const { receiverId, message } = req.body;

    if (!receiverId || !message) {
      return res.status(400).json({
        message: "Missing fields",
      });
    }

    const chat = await Chat.create({
      sender: req.user.id,
      receiver: receiverId,
      message,
    });

    res.status(201).json(chat);

  } catch (err) {
    res.status(500).json({
      message: err.message,
    });
  }
};


/// ✅ GET CHAT BETWEEN TWO USERS
export const getMessages = async (req, res) => {
  try {
    const { userId } = req.params;

    const chats = await Chat.find({
      $or: [
        { sender: req.user.id, receiver: userId },
        { sender: userId, receiver: req.user.id },
      ],
    }).sort({ createdAt: 1 });

    res.json(chats);

  } catch (err) {
    res.status(500).json({
      message: err.message,
    });
  }
};