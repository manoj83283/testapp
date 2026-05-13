import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';

class ApiService {
  static Future<Map<String, dynamic>> login(String email, String password) async {
    final res = await http.post(
      Uri.parse('${ApiConfig.baseUrl}/api/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );
    return jsonDecode(res.body);
  }

  static Future<Map<String, dynamic>> register(Map<String, dynamic> data) async {
    final res = await http.post(
      Uri.parse('${ApiConfig.baseUrl}/api/auth/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(data),
    );
    return jsonDecode(res.body);
  }

  static Future<List<dynamic>> fetchServices() async {
    final res = await http.get(Uri.parse('${ApiConfig.baseUrl}/api/services'));
    if (res.statusCode == 200) return jsonDecode(res.body);
    throw Exception('Failed to load services');
  }

  static Future<String> postService(Map<String, dynamic> data) async {
  final res = await http.post(
    Uri.parse('${ApiConfig.baseUrl}/api/services'),
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode(data),
  );
  if (res.statusCode == 201) return 'Service created';
  return 'Failed';
  }
}