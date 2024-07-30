import 'package:flutter/material.dart';
import 'package:flutter_api/service/auth_service.dart';
import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'login_page.dart';
import 'package:flutter_api/config/api_config.dart';

class UserProfilePage extends StatefulWidget {
  @override
  _UserProfilePageState createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage> {
  final AuthService _authService = AuthService();
  String? _username;
  Map<String, dynamic>? _userData;

  @override
  void initState() {
    super.initState();
    _getUserProfile();
  }

  void _getUserProfile() async {
    String? token = await _authService.getToken();
    if (token == null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginPage()),
      );
    } else {
      _decodeTokenAndFetchUserData(token);
    }
  }

  void _decodeTokenAndFetchUserData(String token) async {
    try {
      final jwt = JWT.decode(token);
      _username = jwt.payload[
              'http://schemas.xmlsoap.org/ws/2005/05/identity/claims/name']
          as String?;
      if (_username != null) {
        _fetchUserData(_username!);
      }
    } catch (e) {
      print('Fejl ved dekodning af JWT: $e');
    }
  }

  void _fetchUserData(String username) async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.apiUrl}/api/Users/byusername/$username'),
        headers: {
          'Authorization': 'Bearer ${await _authService.getToken()}',
        },
      );

      if (response.statusCode == 200) {
        setState(() {
          _userData = jsonDecode(response.body);
        });
      } else {
        print('Fejl ved hentning af brugerdata: ${response.statusCode}');
      }
    } catch (e) {
      print('Fejl: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('User Profile'),
      ),
      body: Center(
        child: _userData != null
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (_userData!['profilePictureURl'] != null)
                    Container(
                      width: 150,
                      height: 150,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        image: DecorationImage(
                          fit: BoxFit.cover,
                          image: NetworkImage(_userData!['profilePictureURl']),
                        ),
                      ),
                    ),
                  SizedBox(height: 20),
                  Text(
                    'Username: ${_userData!['username']}',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Email: ${_userData!['email']}',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey[700],
                    ),
                  ),
                ],
              )
            : CircularProgressIndicator(),
      ),
    );
  }
}
