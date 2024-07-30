import 'package:flutter/material.dart';
import 'package:flutter_api/service/auth_service.dart';
import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
import 'user_profile_page.dart';
import 'groups_page.dart';
import 'login_page.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final AuthService _authService = AuthService();
  String? _username;

  @override
  void initState() {
    super.initState();
    _checkToken();
  }

  void _checkToken() async {
    String? token = await _authService.getToken();
    if (token == null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginPage()),
      );
    } else {
      _decodeToken(token);
    }
  }

  void _decodeToken(String token) {
    try {
      final jwt = JWT.decode(token);
      setState(() {
        _username = jwt.payload[
                'http://schemas.xmlsoap.org/ws/2005/05/identity/claims/name']
            as String?;
      });
    } catch (e) {
      print('Fejl ved dekodning af JWT: $e');
    }
  }

  void _logout() async {
    await _authService.logout();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home'),
        actions: [
          IconButton(
            icon: Icon(Icons.account_circle),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => UserProfilePage()),
              );
            },
          ),
          IconButton(
            icon: Icon(Icons.group),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => GroupsPage()),
              );
            },
          ),
          IconButton(
            icon: Icon(Icons.exit_to_app),
            onPressed: _logout,
          ),
        ],
      ),
      body: Center(
        child: _username != null
            ? Text('Welcome, $_username!')
            : Text('Loading...'),
      ),
    );
  }
}
