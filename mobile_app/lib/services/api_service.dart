import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/api_config.dart';

class ApiService {
  // 🔹 Signup
  static Future<Map<String, dynamic>> signup(Map<String, dynamic> data) async {
    final response = await http.post(
      Uri.parse("${ApiConfig.baseUrl}/auth/register"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(data),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      return {"message": "Signup failed", "status": response.statusCode};
    }
  }

  // 🔹 Login
  static Future<Map<String, dynamic>> login(Map<String, dynamic> data) async {
    final response = await http.post(
      Uri.parse("${ApiConfig.baseUrl}/auth/login"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(data),
    );

    final result = jsonDecode(response.body);

    if (response.statusCode == 200 && result["token"] != null) {
      // ✅ Save token locally
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString("token", result["token"]);
    }

    return result;
  }

  // 🔹 Fetch Services (Protected Route)
  static Future<List<dynamic>> fetchServices() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString("token");

    final response = await http.get(
      Uri.parse(ApiConfig.serviceUrl),
      headers: {
        "Content-Type": "application/json",
        if (token != null) "Authorization": "Bearer $token",
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Failed to load services: ${response.body}");
    }
  }

  // 🔹 Create Booking (Protected Route)
  static Future<Map<String, dynamic>> createBooking({
    required String serviceId,
    required DateTime date,
    String? notes,
  }) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString("token");

    if (token == null) {
      throw Exception("User not authenticated. Please log in again.");
    }

    final response = await http.post(
      Uri.parse("${ApiConfig.baseUrl}/bookings"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
      body: jsonEncode({
        "serviceId": serviceId,
        "date": date.toIso8601String(),
        "notes": notes ?? "",
      }),
    );

    if (response.statusCode == 201 || response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Booking failed: ${response.body}");
    }
  }

  // 🔹 Logout
  static Future<void> logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove("token");
  }

  // 🆕 🔹 Get User Bookings (Protected Route)
  static Future<List<dynamic>> getBookings() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString("token");

    if (token == null) throw Exception("User not authenticated");

    final response = await http.get(
      Uri.parse("${ApiConfig.baseUrl}/bookings"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Failed to load bookings: ${response.body}");
    }
  }

  // 🆕 🔹 Cancel Booking (Protected Route)
  static Future<Map<String, dynamic>> cancelBooking(String bookingId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString("token");

    if (token == null) throw Exception("User not authenticated");

    final response = await http.put(
      Uri.parse("${ApiConfig.baseUrl}/bookings/$bookingId/cancel"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Failed to cancel booking: ${response.body}");
    }
  }

  // 🆕 🔹 Get User Profile (Protected Route)
  static Future<Map<String, dynamic>> getProfile() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString("token");

    if (token == null) throw Exception("User not authenticated");

    final response = await http.get(
      Uri.parse("${ApiConfig.baseUrl}/auth/profile"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Failed to fetch profile: ${response.body}");
    }
  }

  // 🆕 🔹 Update User Profile (Protected Route)
  static Future<Map<String, dynamic>> updateProfile(Map<String, dynamic> data) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString("token");

    if (token == null) throw Exception("User not authenticated");

    final response = await http.put(
      Uri.parse("${ApiConfig.baseUrl}/auth/profile"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
      body: jsonEncode(data),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Failed to update profile: ${response.body}");
    }
  }
}