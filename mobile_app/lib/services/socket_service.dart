import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class SocketService {
  static IO.Socket? socket;

  // ------------------------------------------------------------
  // ✅ BASE URL HANDLER (AUTO SWITCH)
  // ------------------------------------------------------------
  static String getBaseUrl() {
    if (kIsWeb) {
      return "http://localhost:5000"; // ✅ Web
    }

    if (Platform.isAndroid) {
      return "http://10.0.2.2:5000"; // ✅ Android Emulator
    }

    // ✅ Real Device (same WiFi)
    return "http://192.168.1.40:5000";
  }

  // ------------------------------------------------------------
  // ✅ CONNECT SOCKET (SMART + SAFE)
  // ------------------------------------------------------------
  static void connect() {
    if (socket != null && socket!.connected) {
      print("⚠️ Socket already connected");
      return;
    }

    final baseUrl = getBaseUrl();
    print("🌐 Connecting to: $baseUrl");

    socket = IO.io(
      baseUrl,
      IO.OptionBuilder()
          .setTransports(['websocket'])
          .disableAutoConnect()
          .enableReconnection()
          .setReconnectionAttempts(5)
          .setReconnectionDelay(2000)
          .build(),
    );

    socket!.connect();

    // ✅ CONNECTION EVENTS
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
  // ✅ CHAT SYSTEM (REAL-TIME)
  // ------------------------------------------------------------

  /// ✅ JOIN ROOM
  static void joinRoom(String roomId) {
    if (socket == null || !socket!.connected) {
      print("❌ Cannot join room, socket not connected");
      return;
    }

    socket!.emit("joinRoom", roomId);
    print("📦 Joined Room: $roomId");
  }

  /// ✅ STRUCTURED MESSAGE
  static void sendMessage({
    required String roomId,
    required String message,
    required String senderId,
  }) {
    if (socket == null || !socket!.connected) {
      print("❌ Socket not connected");
      return;
    }

    socket!.emit("sendMessage", {
      "roomId": roomId,
      "message": message,
      "senderId": senderId,
    });

    print("📤 Sent Message: $message");
  }

  /// ✅ FLEXIBLE MESSAGE (RAW)
  static void sendMessageRaw(Map data) {
    if (socket == null || !socket!.connected) {
      print("❌ Socket not connected");
      return;
    }

    socket!.emit("sendMessage", data);
    print("📤 Raw Message Sent: $data");
  }

  /// ✅ RECEIVE MESSAGE
  static void listenMessages(Function(dynamic) callback) {
    socket?.on("receiveMessage", (data) {
      print("📥 New Message: $data");
      callback(data);
    });
  }

  // ------------------------------------------------------------
  // ✅ PROVIDER REAL-TIME FEATURES
  // ------------------------------------------------------------

  /// ✅ PROVIDER STATUS (ONLINE / OFFLINE)
  static void notifyProviderStatus() {
    if (socket == null || !socket!.connected) {
      print("❌ Socket not connected");
      return;
    }

    socket!.emit("providerStatusChange");
    print("🟢 Provider status updated");
  }

  /// ✅ LOCATION UPDATE (LIVE TRACKING) ✅ FIXED ORDER
  static void updateLocation({
    required String roomId,
    required double lat,
    required double lng,
  }) {
    if (socket == null || !socket!.connected) {
      print("❌ Socket not connected");
      return;
    }

    socket!.emit("updateLocation", {
      "roomId": roomId,
      "lat": lat,
      "lng": lng,
    });

    print("📍 Location updated: $lat, $lng");
  }

  // ------------------------------------------------------------
  // ✅ CLEANUP
  // ------------------------------------------------------------
  static void removeListeners() {
    socket?.off("newBooking");
    socket?.off("bookingUpdate");
    socket?.off("receiveMessage");
    print("🧹 Listeners removed");
  }

  // ------------------------------------------------------------
  // ✅ DISCONNECT
  // ------------------------------------------------------------
  static void disconnect() {
    if (socket != null) {
      socket!.disconnect();
      socket!.dispose();
      socket = null;
      print("🔌 Socket Disconnected & Disposed");
    }
  }
}