import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/event_service_model.dart';

class ApiService {
  Future<List<EventServiceModel>> fetchEventServices(String token) async {
    final url = Uri.parse('${ApiConfig.baseUrl}/event-services');
    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List services = data['services'];
      return services.map((s) => EventServiceModel.fromJson(s)).toList();
    } else {
      throw Exception('Failed to load event services');
    }
  }
}