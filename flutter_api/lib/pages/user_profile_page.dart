import 'package:flutter/material.dart';
import 'package:flutter_api/service/api_service.dart'; // Correct the import path as necessary
import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart'; // Import to handle JWT

class UserProfilePage extends StatefulWidget {
  final String? username; // Can be null if "me" is meant to fetch current user

  UserProfilePage({this.username});

  @override
  _UserProfilePageState createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage> {
  final ApiService _apiService = ApiService();
  Map<String, dynamic>? _userData;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  void _fetchUserData() async {
    try {
      if (widget.username == "me") {
        String? token = await _apiService.getAuthToken();
        if (token != null) {
          final jwt = JWT.decode(token);
          // Extracting username from the JWT custom claim
          final currentUsername = jwt.payload[
                  'http://schemas.xmlsoap.org/ws/2005/05/identity/claims/name']
              as String;
          _fetchUserProfile(currentUsername);
        } else {
          throw Exception('No token found');
        }
      } else if (widget.username != null) {
        // Fetch user data for a given username
        _fetchUserProfile(widget.username!);
      }
    } catch (e) {
      print('Error fetching user data: $e');
    }
  }

  void _fetchUserProfile(String username) async {
    final userData = await _apiService.getUserDataByUsername(username);
    setState(() {
      _userData = userData;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('User Profile'),
      ),
      body: Center(
        child: _userData == null
            ? CircularProgressIndicator()
            : Column(
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
              ),
      ),
    );
  }
}
