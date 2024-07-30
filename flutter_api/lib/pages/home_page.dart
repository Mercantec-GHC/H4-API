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
      ),
      body: Center(
        child: _username != null
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Welcome, $_username!'),
                  SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildCard(
                        icon: Icons.account_circle,
                        label: 'Profile',
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => UserProfilePage()),
                          );
                        },
                      ),
                      _buildCard(
                        icon: Icons.group,
                        label: 'Groups',
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => GroupsPage()),
                          );
                        },
                      ),
                      _buildCard(
                        icon: Icons.exit_to_app,
                        label: 'Logout',
                        onTap: _logout,
                      ),
                    ],
                  ),
                ],
              )
            : CircularProgressIndicator(),
      ),
    );
  }

  Widget _buildCard(
      {required IconData icon,
      required String label,
      required VoidCallback onTap}) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 50),
              SizedBox(height: 12),
              Text(label, style: TextStyle(fontSize: 16)),
            ],
          ),
        ),
      ),
    );
  }
}
