import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/api_config.dart';

class ApiService {

  static const Duration _timeout = Duration(seconds: 15);

  // ------------------------------------------------------------
  // ✅ RESPONSE HANDLER
  // ------------------------------------------------------------
  static dynamic _handleResponse(http.Response response) {
    final body = response.body.trim();

    dynamic data;
    try {
      data = body.isNotEmpty ? jsonDecode(body) : {};
    } catch (_) {
      data = {"message": body};
    }

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return data;
    } else {
      throw Exception(data["message"] ?? "Something went wrong");
    }
  }

  // ------------------------------------------------------------
  // ✅ REQUEST WRAPPER
  // ------------------------------------------------------------
  static Future<dynamic> _request(Future<http.Response> request) async {
    try {
      final response = await request.timeout(_timeout);
      return _handleResponse(response);
    } on TimeoutException {
      throw Exception("Request timeout - check internet");
    } catch (e) {
      throw Exception("Network error: ${e.toString()}");
    }
  }

  // ------------------------------------------------------------
  // ✅ TOKEN HANDLING
  // ------------------------------------------------------------
  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString("token");
  }

  static Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString("token", token);
  }

  static Future<String?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString("userId");
  }

  static Future<void> saveUserId(String id) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString("userId", id);
  }

  static Future<Map<String, String>> _authHeaders() async {
    final token = await getToken();

    return {
      "Content-Type": "application/json",
      if (token != null && token.isNotEmpty)
        "Authorization": "Bearer $token",
    };
  }
// ------------------------------------------------------------
// ✅ AUTH
// ------------------------------------------------------------
  static Future<Map<String, dynamic>> login(Map data) async {
    final res = await _request(
      http.post(
        Uri.parse(ApiConfig.signinUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(data),
      ),
    );
    if (res["token"] != null) await saveToken(res["token"]);
    if (res["user"] != null && res["user"]["id"] != null) {
      await saveUserId(res["user"]["id"]);
    }
    return res;
  }

/// ✅ ✅ ✅ UPDATED SIGNUP (FINAL VERSION)
  static Future<Map<String, dynamic>> signup({
    required String firstName,
    required String lastName,
    required String email,
    required String phone,
    required String password,
    required String role,
    required String dob,
    required String location,
  }) async {
    final res = await _request(
      http.post(
        Uri.parse(ApiConfig.signupUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "firstName": firstName,
          "lastName": lastName,
          "email": email,
          "phone": phone,
          "password": password,
          "role": role,
          "dob": dob,               
          "location": location,     
        }),
      ),
    );

   /// SAVE SESSION
    if (res["token"] != null) {
      await saveToken(res["token"]);
    }
    if (res["user"] != null && res["user"]["id"] != null) {
      await saveUserId(res["user"]["id"]);
    }
    return res;
  }

  /// ✅ GOOGLE LOGIN
  static Future<Map<String, dynamic>> googleLogin({
    required String email,
    required String name,
  }) async {
    final res = await _request(
      http.post(
        Uri.parse("${ApiConfig.baseUrl}/auth/google"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "email": email,
          "name": name,
          }),
        ),
      );
    if (res["token"] != null) await saveToken(res["token"]);
    if (res["user"] != null && res["user"]["id"] != null) {
      await saveUserId(res["user"]["id"]);
    }
    return res;
  }
  

  // ------------------------------------------------------------
  // ✅ SERVICES
  // ------------------------------------------------------------
  static Future<List<dynamic>> fetchServices() async {
    final res = await _request(
      http.get(Uri.parse(ApiConfig.serviceUrl)),
    );
    return res is List ? res : [];
  }

  static Future<List<dynamic>> fetchServicesByCategory(String category) async {
    final res = await _request(
      http.get(Uri.parse("${ApiConfig.serviceUrl}?category=${category.toLowerCase()}")),
    );
    return res is List ? res : [];
  }

  static Future<Map<String, dynamic>> createService(Map data) async {
    final headers = await _authHeaders();

    return await _request(
      http.post(
        Uri.parse(ApiConfig.serviceUrl),
        headers: headers,
        body: jsonEncode(data),
      ),
    );
  }

  static Future<List<dynamic>> getMyServices() async {
    final headers = await _authHeaders();

    final res = await _request(
      http.get(
        Uri.parse("${ApiConfig.serviceUrl}/my"),
        headers: headers,
      ),
    );

    return res is List ? res : [];
  }

  static Future<void> deleteService(String id) async {
    final headers = await _authHeaders();

    await _request(
      http.delete(
        Uri.parse("${ApiConfig.serviceUrl}/$id"),
        headers: headers,
      ),
    );
  }

  static Future<Map<String, dynamic>> updateServiceStatus(String id, bool status) async {
    final headers = await _authHeaders();

    return await _request(
      http.put(
        Uri.parse("${ApiConfig.serviceUrl}/$id/status"),
        headers: headers,
        body: jsonEncode({"isActive": status}),
      ),
    );
  }

  // ------------------------------------------------------------
  // ✅ BOOKINGS
  // ------------------------------------------------------------
  static Future<Map<String, dynamic>> createBooking({
    required String serviceId,
    required DateTime date,
    String? notes,
    String paymentMethod = "COD",
    String address = "",
    String location = "",
  }) async {
    final headers = await _authHeaders();

    return await _request(
      http.post(
        Uri.parse(ApiConfig.bookingUrl),
        headers: headers,
        body: jsonEncode({
          "serviceId": serviceId,
          "date": date.toIso8601String(),
          "notes": notes ?? "",
          "paymentMethod": paymentMethod,
          "address": address,
          "location": location,
        }),
      ),
    );
  }

  /// ✅ CUSTOMER BOOKINGS
  static Future<List<dynamic>> getBookings() async {
    final headers = await _authHeaders();

    final res = await _request(
      http.get(
        Uri.parse(ApiConfig.bookingUrl),
        headers: headers,
      ),
    );

    return res is List ? res : [];
  }

  /// ✅ PROVIDER BOOKINGS
  static Future<List<dynamic>> getProviderBookings() async {
    final headers = await _authHeaders();

    final res = await _request(
      http.get(
        Uri.parse("${ApiConfig.bookingUrl}/provider"),
        headers: headers,
      ),
    );

    return res is List ? res : [];
  }

  static Future<Map<String, dynamic>> updateBookingStatus({
    required String bookingId,
    required String status,
  }) async {
    final headers = await _authHeaders();

    return await _request(
      http.put(
        Uri.parse("${ApiConfig.bookingUrl}/$bookingId/status"),
        headers: headers,
        body: jsonEncode({"status": status}),
      ),
    );
  }

  static Future<Map<String, dynamic>> cancelBooking(String bookingId) async {
    final headers = await _authHeaders();

    return await _request(
      http.put(
        Uri.parse("${ApiConfig.bookingUrl}/$bookingId/cancel"),
        headers: headers,
      ),
    );
  }

  // ------------------------------------------------------------
  // ✅ CHAT
  // ------------------------------------------------------------
  static Future<Map<String, dynamic>> sendMessage(
      String receiverId, String message) async {
    final headers = await _authHeaders();

    return await _request(
      http.post(
        Uri.parse("${ApiConfig.baseUrl}/chat"),
        headers: headers,
        body: jsonEncode({
          "receiverId": receiverId,
          "message": message,
        }),
      ),
    );
  }

  static Future<List<dynamic>> getMessages(String roomId) async {
    final headers = await _authHeaders();

    final res = await _request(
      http.get(
        Uri.parse("${ApiConfig.baseUrl}/chat/$roomId"),
        headers: headers,
      ),
    );

    return res is List ? res : [];
  }

  // ------------------------------------------------------------
  // ✅ PROFILE
  // ------------------------------------------------------------
  static Future<Map<String, dynamic>> getProfile() async {
    final headers = await _authHeaders();

    return await _request(
      http.get(
        Uri.parse(ApiConfig.profileUrl),
        headers: headers,
      ),
    );
  }

  // ------------------------------------------------------------
  // ✅ LOGOUT
  // ------------------------------------------------------------
  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}