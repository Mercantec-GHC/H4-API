import 'package:flutter/material.dart';
import 'package:flutter_api/service/auth_service.dart';
import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'login_page.dart';

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
        Uri.parse('https://h4-jwt.onrender.com/api/Users/byusername/$username'),
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
                  Text('Username: ${_userData!['username']}'),
                  Text('Email: ${_userData!['email']}'),
                  if (_userData!['profilePictureURl'] != null)
                    Image.network(_userData!['profilePictureURl']),
                  // Tilføj flere felter efter behov
                ],
              )
            : CircularProgressIndicator(),
      ),
    );
  }
}
