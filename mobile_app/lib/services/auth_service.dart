import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/api_config.dart';

class AuthService {
  static Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final res = await http.post(
        Uri.parse("${ApiConfig.baseUrl}/login"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"email": email, "password": password}),
      );

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString("token", data["token"]);
        await prefs.setString("userName", data["user"]["name"]);
        return {"success": true, "message": "Login successful"};
      } else {
        final data = jsonDecode(res.body);
        return {"success": false, "message": data["message"] ?? "Login failed"};
      }
    } catch (e) {
      return {"success": false, "message": "Server error: $e"};
    }
  }

  static Future<Map<String, dynamic>> signup(String name, String email, String password) async {
    try {
      final res = await http.post(
        Uri.parse("${ApiConfig.baseUrl}/signup"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"name": name, "email": email, "password": password}),
      );

      if (res.statusCode == 201) {
        return {"success": true, "message": "Signup successful"};
      } else {
        final data = jsonDecode(res.body);
        return {"success": false, "message": data["message"] ?? "Signup failed"};
      }
    } catch (e) {
      return {"success": false, "message": "Server error: $e"};
    }
  }
}