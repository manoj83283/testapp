import 'dart:async';
import 'package:flutter/material.dart';

import '../services/api_service.dart';
import '../services/socket_service.dart';

class ChatScreen extends StatefulWidget {
  final String roomId;
  final String currentUserId;
  final String receiverId;

  const ChatScreen({
    super.key,
    required this.roomId,
    required this.currentUserId,
    required this.receiverId,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {

  List<Map<String, dynamic>> messages = [];
  final TextEditingController controller = TextEditingController();
  final ScrollController scrollController = ScrollController();

  String? bookingStatus;

  Timer? _chatTimer;

  @override
  void initState() {
    super.initState();

    /// ✅ CONNECT SOCKET
    SocketService.connect();

    /// ✅ JOIN ROOM
    SocketService.joinRoom(widget.roomId);

    /// ✅ LOAD HISTORY
    loadMessages();

    /// ✅ POLLING (kept)
    _chatTimer = Timer.periodic(
      const Duration(seconds: 2),
      (_) => loadMessages(),
    );

    /// ✅ REAL-TIME (service wrapper)
    SocketService.listenMessages((data) {
      final msg = Map<String, dynamic>.from(data);

      if (msg["roomId"] == widget.roomId) {
        setState(() {
          messages.add(msg);
        });

        scrollToBottom();
      }
    });

    /// ✅ DIRECT SOCKET LISTENER ✅ FIXED
    SocketService.socket?.on("receiveMessage", (data) {
      final msg = Map<String, dynamic>.from(data);

      if (msg["roomId"] == widget.roomId) {
        setState(() {
          messages.add(msg);
        });

        scrollToBottom();
      }
    });

    /// ✅ BOOKING STATUS UPDATE
    SocketService.listenBookingUpdate((data) {
      if (data["chatRoomId"] == widget.roomId) {
        setState(() {
          bookingStatus = data["status"];
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Booking ${data["status"]}"),
            backgroundColor: Colors.blue,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    });
  }

  // ==========================================================
  // ✅ LOAD CHAT HISTORY
  // ==========================================================
  Future<void> loadMessages() async {
    try {
      final data = await ApiService.getMessages(widget.roomId);

      setState(() {
        messages = List<Map<String, dynamic>>.from(
          data.map((e) => Map<String, dynamic>.from(e)),
        );
      });

      scrollToBottom();

    } catch (e) {
      print("❌ Load messages error: $e");
    }
  }

  // ==========================================================
  // ✅ SEND MESSAGE
  // ==========================================================
  void sendMessage() {
    final text = controller.text.trim();
    if (text.isEmpty) return;

    final msg = {
      "roomId": widget.roomId,
      "senderId": widget.currentUserId,
      "receiverId": widget.receiverId,
      "message": text,
    };

    /// ✅ SOCKET SEND
    SocketService.sendMessage(
      roomId: widget.roomId,
      message: text,
      senderId: widget.currentUserId,
    );

    /// ✅ RAW BACKUP
    SocketService.sendMessageRaw(msg);

    /// ✅ UI UPDATE
    setState(() => messages.add(msg));

    controller.clear();
    scrollToBottom();
  }

  // ==========================================================
  // ✅ AUTO SCROLL
  // ==========================================================
  void scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (scrollController.hasClients) {
        scrollController.animateTo(
          scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  // ==========================================================
  // ✅ STATUS COLOR
  // ==========================================================
  Color getStatusColor(String status) {
    switch (status) {
      case "accepted":
        return Colors.green;
      case "completed":
        return Colors.blue;
      case "in_progress":
        return Colors.purple;
      case "cancelled":
        return Colors.red;
      default:
        return Colors.orange;
    }
  }

  @override
  void dispose() {
    _chatTimer?.cancel();

    /// ✅ FIXED NULL SAFE
    SocketService.socket?.off("receiveMessage");

    SocketService.removeListeners();
    controller.dispose();
    scrollController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: const Text("Chat"),
      ),

      body: Column(
        children: [

          /// ✅ BOOKING STATUS
          if (bookingStatus != null)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(8),
              color: getStatusColor(bookingStatus!),
              child: Text(
                "Booking Status: ${bookingStatus!.toUpperCase()}",
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white),
              ),
            ),

          /// ✅ CHAT LIST
          Expanded(
            child: ListView.builder(
              controller: scrollController,
              itemCount: messages.length,
              itemBuilder: (_, i) {

                final m = messages[i];
                final isMe =
                    m["senderId"] == widget.currentUserId;

                return Align(
                  alignment: isMe
                      ? Alignment.centerRight
                      : Alignment.centerLeft,

                  child: Container(
                    margin: const EdgeInsets.all(8),
                    padding: const EdgeInsets.all(10),

                    decoration: BoxDecoration(
                      color: isMe
                          ? Colors.blue
                          : Colors.grey[300],
                      borderRadius: BorderRadius.circular(10),
                    ),

                    child: Text(
                      m["message"] ?? "",
                      style: TextStyle(
                        color: isMe
                            ? Colors.white
                            : Colors.black,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          /// ✅ INPUT
          Row(
            children: [

              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: TextField(
                    controller: controller,
                    decoration: const InputDecoration(
                      hintText: "Type message...",
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
              ),

              IconButton(
                icon: const Icon(Icons.send),
                onPressed: sendMessage,
              ),
            ],
          ),
        ],
      ),
    );
  }
}