import 'package:flutter/material.dart';
import 'package:flutter_api/service/auth_service.dart';
import 'pages/login_page.dart';
import 'pages/home_page.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final AuthService _authService = AuthService();

  Future<Widget> _getInitialPage() async {
    String? token = await _authService.getToken();
    if (token == null || token.isEmpty) {
      return LoginPage();
    } else {
      return HomePage();
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Widget>(
      future: _getInitialPage(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return MaterialApp(
            home: Scaffold(
              body: Center(child: CircularProgressIndicator()),
            ),
          );
        } else {
          return MaterialApp(
            title: 'Flutter Demo',
            theme: ThemeData(
              primarySwatch: Colors.blue,
            ),
            home: snapshot.data,
            routes: {
              '/login': (context) => LoginPage(),
              '/home': (context) => HomePage(),
            },
          );
        }
      },
    );
  }
}
