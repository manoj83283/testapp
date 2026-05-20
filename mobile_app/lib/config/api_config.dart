import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;

class ApiConfig {
  /// Automatically detects the environment and returns the correct base URL.
  static String get baseUrl {
    if (kIsWeb) {
      // Running in Chrome/Edge (Flutter Web)
      return "http://localhost:5000/api";
    } else if (Platform.isAndroid) {
      // Running on Android Emulator
      return "http://10.0.2.2:5000/api";
    } else if (Platform.isIOS) {
      // Running on iOS Simulator
      return "http://127.0.0.1:5000/api";
    } else {
      // Running on a physical device or desktop build
      // ✅ Use your computer's local IP address here
      return "http://192.168.1.36:5000/api";
    }
  }

  // 🔹 Common API endpoints
  static String get signupUrl => "$baseUrl/auth/register";
  static String get loginUrl => "$baseUrl/auth/login";
  static String get serviceUrl => "$baseUrl/services";
  static String get bookingUrl => "$baseUrl/bookings";
  static String get profileUrl => "$baseUrl/auth/profile";
}