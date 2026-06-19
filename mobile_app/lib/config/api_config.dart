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
    } else if (Platform.isIOS) {
      // Running on iOS Simulator
      return "http://192.168.1.40:5000/api";
    } else {
      // Running on Windows desktop / physical device
      return "http://10.152.35.172:5000/api";
    }
  }

  // 🔹 Common API endpoints
  static String get signupUrl => "$baseUrl/auth/signup";
  static String get signinUrl => "$baseUrl/auth/signin";

  // ✅ Optional alias, if your api_service.dart still uses loginUrl
  static String get loginUrl => signinUrl;

  static String get serviceUrl => "$baseUrl/services";
  //static const String serviceUrl = "$baseUrl/api/services";
  static String get bookingUrl => "$baseUrl/bookings";
  static String get profileUrl => "$baseUrl/auth/profile";
  static String get authUrl => "$baseUrl/auth";
}