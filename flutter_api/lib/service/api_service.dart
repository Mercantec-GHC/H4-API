import 'dart:convert';
import 'package:http/http.dart' as http;
import 'auth_service.dart';
import 'package:flutter_api/config/api_config.dart';

class ApiService {
  final AuthService _authService = AuthService();
  final String baseUrl = ApiConfig.apiUrl;

  Future<List<dynamic>> getActivityLogs() async {
    final token = await _authService.getToken();
    final url = Uri.parse('$baseUrl/api/ActivityLogs');

    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load activity logs');
    }
  }

  Future<List<dynamic>> getGroups() async {
    final token = await _authService.getToken();
    final url = Uri.parse('$baseUrl/api/Groups');

    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load groups');
    }
  }

  Future<Map<String, dynamic>> getGroupById(String groupId) async {
    final token = await _authService.getToken();
    final url = Uri.parse('$baseUrl/api/Groups/$groupId');

    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load group details');
    }
  }
}
