import 'package:socket_io_client/socket_io_client.dart' as IO;

class SocketService {
  static IO.Socket? socket;

  /// ✅ CONNECT SOCKET
  static void connect() {
    if (socket != null && socket!.connected) return;

    socket = IO.io(
      "http://10.0.2.2:5000", // ✅ CHANGE for real device
      IO.OptionBuilder()
          .setTransports(['websocket'])
          .enableAutoConnect()
          .enableReconnection()
          .build(),
    );

    socket!.onConnect((_) {
      print("✅ Socket Connected: ${socket!.id}");
    });

    socket!.onDisconnect((_) {
      print("❌ Socket Disconnected");
    });

    socket!.onConnectError((err) {
      print("❌ Connection Error: $err");
    });

    socket!.onError((err) {
      print("❌ Socket Error: $err");
    });
  }

  // ------------------------------------------------------------
  // ✅ BOOKING EVENTS
  // ------------------------------------------------------------

  static void listenBooking(Function(dynamic) callback) {
    socket?.on("newBooking", callback);
  }

  static void listenBookingUpdate(Function(dynamic) callback) {
    socket?.on("bookingUpdate", callback);
  }

  // ------------------------------------------------------------
  // ✅ CHAT SYSTEM (FIXED)
  // ------------------------------------------------------------

  /// ✅ JOIN ROOM
  static void joinRoom(String roomId) {
    socket?.emit("joinRoom", roomId);
    print("📦 Joined Room: $roomId");
  }

  /// ✅ SEND MESSAGE
  static void sendMessage({
    required String roomId,
    required String message,
    required String senderId,
  }) {
    socket?.emit("sendMessage", {
      "roomId": roomId,
      "message": message,
      "senderId": senderId,
    });

    print("📤 Sent Message: $message");
  }

  /// ✅ RECEIVE MESSAGE
  static void listenMessages(Function(dynamic) callback) {
    socket?.on("receiveMessage", (data) {
      print("📥 New Message: $data");
      callback(data);
    });
  }

  // ------------------------------------------------------------
  // ✅ REMOVE LISTENERS (VERY IMPORTANT)
  // ------------------------------------------------------------

  static void removeListeners() {
    socket?.off("newBooking");
    socket?.off("bookingUpdate");
    socket?.off("receiveMessage");
  }

  // ------------------------------------------------------------
  // ✅ DISCONNECT SOCKET
  // ------------------------------------------------------------

  static void disconnect() {
    socket?.dispose();
    socket = null;
    print("🔌 Socket Disposed");
  }
}
