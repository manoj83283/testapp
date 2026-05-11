import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/provider_model.dart';

class ProviderService {
  Future<Map<String, dynamic>> login(String email, String password) async {
    final url = Uri.parse('${ApiConfig.baseUrl}/providers/login');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );
    final data = jsonDecode(response.body);
    return data;
  }

  Future<ProviderModel> updateProfile({
    required String token,
    required String description,
    required double rating,
    required double pricePerHour,
    required double pricePerDay,
    required String city,
    required String state,
    required String country,
    List<File>? photos,
    List<File>? videos,
  }) async {
    final url = Uri.parse('${ApiConfig.baseUrl}/providers/profile');
    final request = http.MultipartRequest('PUT', url);
    request.headers['Authorization'] = 'Bearer $token';

    request.fields['description'] = description;
    request.fields['rating'] = rating.toString();
    request.fields['pricePerHour'] = pricePerHour.toString();
    request.fields['pricePerDay'] = pricePerDay.toString();
    request.fields['location[city]'] = city;
    request.fields['location[state]'] = state;
    request.fields['location[country]'] = country;

    if (photos != null) {
      for (var photo in photos) {
        request.files.add(await http.MultipartFile.fromPath('photos', photo.path));
      }
    }
    if (videos != null) {
      for (var video in videos) {
        request.files.add(await http.MultipartFile.fromPath('videos', video.path));
      }
    }

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);
    final data = jsonDecode(response.body);
    if (data['success'] == true) {
      return ProviderModel.fromJson(data['provider']);
    } else {
      throw Exception(data['message']);
    }
  }
}