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

  Future<String?> getAuthToken() async {
    return _authService.getToken();
  }

  Future<Map<String, dynamic>> getUserDataByUsername(String username) async {
    String? token = await getAuthToken();
    if (token == null) {
      throw Exception('Authentication token is not available');
    }

    final response = await http.get(
      Uri.parse('${ApiConfig.apiUrl}/api/Users/byusername/$username'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      print('Fejl ved hentning af brugerdata: ${response.statusCode}');
      throw Exception('Failed to fetch user data');
    }
  }

  Future<void> joinGroup(String userId, String groupId) async {
    final token = await _authService.getToken();
    final url = Uri.parse('$baseUrl/api/UserGroups/JoinGroup');

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'userId': userId,
        'groupId': groupId,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to join group');
    }
  }

  Future<void> leaveGroup(String userId, String groupId) async {
    final token = await _authService.getToken();
    final url = Uri.parse('$baseUrl/api/UserGroups/LeaveGroup');

    final response = await http.delete(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'userId': userId,
        'groupId': groupId,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to leave group');
    }
  }

  Future<Map<String, dynamic>> createGroup(String name) async {
    final token = await _authService.getToken();
    final url = Uri.parse('$baseUrl/api/Groups');

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'name': name,
      }),
    );

    if (response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to create group');
    }
  }
}
