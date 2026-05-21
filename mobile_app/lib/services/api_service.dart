import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/api_config.dart';

class ApiService {
  // ------------------------------------------------------------
  // Helper: Decode JSON safely
  // ------------------------------------------------------------
  static dynamic _decodeResponse(http.Response response) {
    try {
      if (response.body.isEmpty) {
        return {};
      }
      return jsonDecode(response.body);
    } catch (_) {
      return {
        "message": response.body,
      };
    }
  }

  // ------------------------------------------------------------
  // Helper: Get saved token
  // ------------------------------------------------------------
  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString("token");
  }

  // ------------------------------------------------------------
  // Helper: Save token
  // ------------------------------------------------------------
  static Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString("token", token);
  }

  // ------------------------------------------------------------
  // Helper: Auth headers
  // ------------------------------------------------------------
  static Future<Map<String, String>> _authHeaders() async {
    final token = await getToken();

    return {
      "Content-Type": "application/json",
      if (token != null && token.isNotEmpty) "Authorization": "Bearer $token",
    };
  }

  // ------------------------------------------------------------
  // Signup
  // ------------------------------------------------------------
  static Future<Map<String, dynamic>> signup(Map<String, dynamic> data) async {
    final url = Uri.parse(ApiConfig.signupUrl);

    final requestBody = {
      "firstName": data["firstName"]?.toString().trim() ?? "",
      "lastName": data["lastName"]?.toString().trim() ?? "",
      "email": data["email"]?.toString().trim() ?? "",
      "phone": data["phone"]?.toString().trim() ?? "",
      "password": data["password"]?.toString() ?? "",
    };

    print("🟢 Sending signup request...");
    print("🔗 Calling signup API: $url");
    print("📦 Request body: ${jsonEncode(requestBody)}");

    try {
      final response = await http
          .post(
            url,
            headers: {
              "Content-Type": "application/json",
            },
            body: jsonEncode(requestBody),
          )
          .timeout(const Duration(seconds: 10));

      print("📥 Raw response: ${response.statusCode} ${response.body}");

      final result = _decodeResponse(response);

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (result is Map<String, dynamic> && result["token"] != null) {
          await saveToken(result["token"]);
        }

        return result is Map<String, dynamic>
            ? result
            : {
                "message": "Signup successful",
                "data": result,
              };
      } else {
        return {
          "message": result is Map<String, dynamic>
              ? result["message"] ?? "Signup failed"
              : "Signup failed",
          "status": response.statusCode,
          "received": result is Map<String, dynamic> ? result["received"] : null,
        };
      }
    } catch (e) {
      print("❌ Signup error: $e");

      return {
        "message": "Network error",
        "error": e.toString(),
      };
    }
  }

  // ------------------------------------------------------------
  // Login / Signin
  // ------------------------------------------------------------
  static Future<Map<String, dynamic>> login(Map<String, dynamic> data) async {
    final url = Uri.parse(ApiConfig.signinUrl);

    final requestBody = {
      "email": data["email"]?.toString().trim() ?? "",
      "password": data["password"]?.toString() ?? "",
    };

    print("🟢 Sending login request...");
    print("🔗 Calling login API: $url");
    print("📦 Login body: ${jsonEncode(requestBody)}");

    try {
      final response = await http
          .post(
            url,
            headers: {
              "Content-Type": "application/json",
            },
            body: jsonEncode(requestBody),
          )
          .timeout(const Duration(seconds: 10));

      print("📥 Login raw response: ${response.statusCode} ${response.body}");

      final result = _decodeResponse(response);

      if (response.statusCode == 200 &&
          result is Map<String, dynamic> &&
          result["token"] != null) {
        await saveToken(result["token"]);
      }

      if (result is Map<String, dynamic>) {
        return result;
      }

      return {
        "message": "Login failed",
        "status": response.statusCode,
      };
    } catch (e) {
      print("❌ Login error: $e");

      return {
        "message": "Network error",
        "error": e.toString(),
      };
    }
  }

  // ------------------------------------------------------------
  // Fetch Services
  // ------------------------------------------------------------
  static Future<List<dynamic>> fetchServices() async {
    final url = Uri.parse(ApiConfig.serviceUrl);
    final headers = await _authHeaders();

    print("🔗 Fetch services API: $url");

    try {
      final response = await http
          .get(
            url,
            headers: headers,
          )
          .timeout(const Duration(seconds: 10));

      print("📥 Services response: ${response.statusCode} ${response.body}");

      final result = _decodeResponse(response);

      if (response.statusCode == 200) {
        if (result is List) {
          return result;
        }

        if (result is Map<String, dynamic>) {
          if (result["services"] is List) {
            return result["services"];
          }

          if (result["data"] is List) {
            return result["data"];
          }
        }

        return [];
      } else {
        throw Exception(
          result is Map<String, dynamic>
              ? result["message"] ?? "Failed to load services"
              : "Failed to load services",
        );
      }
    } 
    catch (e) {
      print("❌ Fetch services error: $e");
      throw Exception("Failed to load services: $e");
    }
  }
  // ------------------------------------------------------------
  // Fetch Services By Category
  // Dynamic Nearby Services
  // Example: GET /api/services?category=wedding
  // ------------------------------------------------------------
  static Future<List<dynamic>> fetchServicesByCategory(String categoryKey) async {
    final url = Uri.parse("${ApiConfig.serviceUrl}?category=$categoryKey");
    final headers = await _authHeaders();

    print("🔗 Fetch services by category API: $url");

    try {
      final response = await http
          .get(
            url,
            headers: headers,
          )
          .timeout(const Duration(seconds: 10));

      print(
        "📥 Category services response: ${response.statusCode} ${response.body}",
      );

      final result = _decodeResponse(response);

      if (response.statusCode == 200) {
        if (result is List) {
          return result;
        }

        if (result is Map<String, dynamic>) {
          if (result["services"] is List) {
            return result["services"];
          }

          if (result["data"] is List) {
            return result["data"];
          }
        }

        return [];
      } else {
        throw Exception(
          result is Map<String, dynamic>
              ? result["message"] ?? "Failed to load services"
              : "Failed to load services",
        );
      }
    } catch (e) {
      print("❌ Fetch category services error: $e");
      throw Exception("Failed to load services by category: $e");
    }
  }

  // ------------------------------------------------------------
  // Create Booking
  // ------------------------------------------------------------
  static Future<Map<String, dynamic>> createBooking({
    required String serviceId,
    required DateTime date,
    String? notes,
  }) async {
    final token = await getToken();

    if (token == null || token.isEmpty) {
      throw Exception("User not authenticated. Please log in again.");
    }

    final url = Uri.parse(ApiConfig.bookingUrl);

    final requestBody = {
      "serviceId": serviceId,
      "date": date.toIso8601String(),
      "notes": notes ?? "",
    };

    print("🔗 Create booking API: $url");
    print("📦 Booking body: ${jsonEncode(requestBody)}");

    try {
      final response = await http
          .post(
            url,
            headers: {
              "Content-Type": "application/json",
              "Authorization": "Bearer $token",
            },
            body: jsonEncode(requestBody),
          )
          .timeout(const Duration(seconds: 10));

      print("📥 Booking response: ${response.statusCode} ${response.body}");

      final result = _decodeResponse(response);

      if (response.statusCode == 201 || response.statusCode == 200) {
        return result is Map<String, dynamic>
            ? result
            : {
                "message": "Booking created successfully",
                "data": result,
              };
      } else {
        throw Exception(
          result is Map<String, dynamic>
              ? result["message"] ?? "Booking failed"
              : "Booking failed",
        );
      }
    } catch (e) {
      print("❌ Booking error: $e");
      throw Exception("Booking failed: $e");
    }
  }

  // ------------------------------------------------------------
  // Get User Bookings
  // ------------------------------------------------------------
  static Future<List<dynamic>> getBookings() async {
    final token = await getToken();

    if (token == null || token.isEmpty) {
      throw Exception("User not authenticated");
    }

    final url = Uri.parse(ApiConfig.bookingUrl);

    print("🔗 Get bookings API: $url");

    try {
      final response = await http
          .get(
            url,
            headers: {
              "Content-Type": "application/json",
              "Authorization": "Bearer $token",
            },
          )
          .timeout(const Duration(seconds: 10));

      print("📥 Bookings response: ${response.statusCode} ${response.body}");

      final result = _decodeResponse(response);

      if (response.statusCode == 200) {
        if (result is List) {
          return result;
        }

        if (result is Map<String, dynamic>) {
          if (result["bookings"] is List) {
            return result["bookings"];
          }

          if (result["data"] is List) {
            return result["data"];
          }
        }

        return [];
      } else {
        throw Exception(
          result is Map<String, dynamic>
              ? result["message"] ?? "Failed to load bookings"
              : "Failed to load bookings",
        );
      }
    } catch (e) {
      print("❌ Get bookings error: $e");
      throw Exception("Failed to load bookings: $e");
    }
  }

  // ------------------------------------------------------------
  // Cancel Booking
  // ------------------------------------------------------------
  static Future<Map<String, dynamic>> cancelBooking(String bookingId) async {
    final token = await getToken();

    if (token == null || token.isEmpty) {
      throw Exception("User not authenticated");
    }

    final url = Uri.parse("${ApiConfig.bookingUrl}/$bookingId/cancel");

    print("🔗 Cancel booking API: $url");

    try {
      final response = await http
          .put(
            url,
            headers: {
              "Content-Type": "application/json",
              "Authorization": "Bearer $token",
            },
          )
          .timeout(const Duration(seconds: 10));

      print("📥 Cancel response: ${response.statusCode} ${response.body}");

      final result = _decodeResponse(response);

      if (response.statusCode == 200) {
        return result is Map<String, dynamic>
            ? result
            : {
                "message": "Booking cancelled successfully",
                "data": result,
              };
      } else {
        throw Exception(
          result is Map<String, dynamic>
              ? result["message"] ?? "Failed to cancel booking"
              : "Failed to cancel booking",
        );
      }
    } catch (e) {
      print("❌ Cancel booking error: $e");
      throw Exception("Failed to cancel booking: $e");
    }
  }

  // ------------------------------------------------------------
  // Get User Profile
  // ------------------------------------------------------------
  static Future<Map<String, dynamic>> getProfile() async {
    final token = await getToken();

    if (token == null || token.isEmpty) {
      throw Exception("User not authenticated");
    }

    final url = Uri.parse(ApiConfig.profileUrl);

    print("🔗 Get profile API: $url");

    try {
      final response = await http
          .get(
            url,
            headers: {
              "Content-Type": "application/json",
              "Authorization": "Bearer $token",
            },
          )
          .timeout(const Duration(seconds: 10));

      print("📥 Profile response: ${response.statusCode} ${response.body}");

      final result = _decodeResponse(response);

      if (response.statusCode == 200) {
        return result is Map<String, dynamic>
            ? result
            : {
                "data": result,
              };
      } else {
        throw Exception(
          result is Map<String, dynamic>
              ? result["message"] ?? "Failed to fetch profile"
              : "Failed to fetch profile",
        );
      }
    } catch (e) {
      print("❌ Get profile error: $e");
      throw Exception("Failed to fetch profile: $e");
    }
  }

  // ------------------------------------------------------------
  // Update User Profile
  // ------------------------------------------------------------
  static Future<Map<String, dynamic>> updateProfile(
    Map<String, dynamic> data,
  ) async {
    final token = await getToken();

    if (token == null || token.isEmpty) {
      throw Exception("User not authenticated");
    }

    final url = Uri.parse(ApiConfig.profileUrl);

    final requestBody = {
      if (data["firstName"] != null)
        "firstName": data["firstName"].toString().trim(),
      if (data["lastName"] != null)
        "lastName": data["lastName"].toString().trim(),
      if (data["email"] != null) "email": data["email"].toString().trim(),
      if (data["phone"] != null) "phone": data["phone"].toString().trim(),
      if (data["password"] != null) "password": data["password"].toString(),
    };

    print("🔗 Update profile API: $url");
    print("📦 Update profile body: ${jsonEncode(requestBody)}");

    try {
      final response = await http
          .put(
            url,
            headers: {
              "Content-Type": "application/json",
              "Authorization": "Bearer $token",
            },
            body: jsonEncode(requestBody),
          )
          .timeout(const Duration(seconds: 10));

      print("📥 Update profile response: ${response.statusCode} ${response.body}");

      final result = _decodeResponse(response);

      if (response.statusCode == 200) {
        return result is Map<String, dynamic>
            ? result
            : {
                "message": "Profile updated successfully",
                "data": result,
              };
      } else {
        throw Exception(
          result is Map<String, dynamic>
              ? result["message"] ?? "Failed to update profile"
              : "Failed to update profile",
        );
      }
    } catch (e) {
      print("❌ Update profile error: $e");
      throw Exception("Failed to update profile: $e");
    }
  }

  // ------------------------------------------------------------
  // Logout
  // ------------------------------------------------------------
  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove("token");

    print("✅ User logged out. Token removed.");
  }

  // ------------------------------------------------------------
  // Check Login Status
  // ------------------------------------------------------------
  static Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }
}