import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import '../services/api_service.dart';

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

  late IO.Socket socket;

  List<Map<String, dynamic>> messages = [];
  final TextEditingController controller = TextEditingController();
  final ScrollController scrollController = ScrollController();

  String? bookingStatus; // ✅ NEW

  @override
  void initState() {
    super.initState();
    connectSocket();
    loadMessages();
  }

  /// ✅ SOCKET CONNECT
  void connectSocket() {
    socket = IO.io(
      "http://10.152.35.172:5000",
      IO.OptionBuilder()
          .setTransports(['websocket'])
          .enableAutoConnect()
          .build(),
    );

    socket.onConnect((_) {
      print("✅ Connected");
      socket.emit("joinRoom", widget.roomId);
    });

    /// ✅ RECEIVE CHAT MESSAGE
    socket.on("receiveMessage", (data) {
      final msg = Map<String, dynamic>.from(data);

      setState(() => messages.add(msg));
      scrollToBottom();
    });

    /// ✅ ✅ REAL-TIME BOOKING UPDATE 🔥
    socket.on("bookingUpdate", (data) {
      print("✅ Booking Updated: $data");

      setState(() {
        bookingStatus = data["status"];
      });

      /// ✅ USER FEEDBACK (LIKE SWIGGY)
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Booking ${data["status"]}"),
          backgroundColor: Colors.blue,
          duration: const Duration(seconds: 2),
        ),
      );
    });
  }

  /// ✅ LOAD OLD MESSAGES
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
      print("❌ Load error: $e");
    }
  }

  /// ✅ SEND MESSAGE
  void sendMessage() {
    final text = controller.text.trim();
    if (text.isEmpty) return;

    final msg = {
      "roomId": widget.roomId,
      "senderId": widget.currentUserId,
      "receiverId": widget.receiverId,
      "message": text,
    };

    socket.emit("sendMessage", msg);

    setState(() => messages.add(msg));

    controller.clear();
    scrollToBottom();
  }

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

  /// ✅ STATUS COLOR (OPTIONAL UI)
  Color getStatusColor(String status) {
    switch (status) {
      case "accepted":
        return Colors.green;
      case "rejected":
      case "cancelled":
        return Colors.red;
      case "completed":
        return Colors.blue;
      case "in_progress":
        return Colors.purple;
      default:
        return Colors.orange;
    }
  }

  @override
  void dispose() {
    socket.disconnect();
    socket.dispose();
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

          /// ✅ ✅ BOOKING STATUS BANNER (NEW 🔥)
          if (bookingStatus != null)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(8),
              color: getStatusColor(bookingStatus!),
              child: Text(
                "Booking Status: ${bookingStatus!.toUpperCase()}",
                style: const TextStyle(color: Colors.white),
                textAlign: TextAlign.center,
              ),
            ),

          /// ✅ MESSAGES
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
                      color:
                          isMe ? Colors.blue : Colors.grey[300],
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

          /// ✅ INPUT BOX
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
              )
            ],
          )
        ],
      ),
    );
  }
}