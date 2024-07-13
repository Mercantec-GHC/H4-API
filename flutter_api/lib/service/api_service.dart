import 'dart:convert';
import 'package:http/http.dart' as http;
import 'auth_service.dart';

class ApiService {
  final AuthService _authService = AuthService();
  final String baseUrl = 'https://localhost:7105';

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
}
