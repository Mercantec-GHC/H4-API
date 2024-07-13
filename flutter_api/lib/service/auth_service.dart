import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter/foundation.dart'; // Import for console output
import 'package:flutter_api/models/login_model.dart';

class AuthService {
  final String baseUrl = 'https://localhost:7105';
  final storage = FlutterSecureStorage();

  Future<void> login(LoginDTO loginDTO) async {
    final url = Uri.parse('$baseUrl/api/Users/login');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(loginDTO.toJson()),
    );

    if (response.statusCode == 200) {
      final token = jsonDecode(response.body)['token'];
      await storage.write(key: 'jwt', value: token);
      if (kDebugMode) {
        print('JWT Token: $token');
      }
    } else {
      throw Exception('Login failed');
    }
  }

  Future<String?> getToken() async {
    return await storage.read(key: 'jwt');
  }
}
