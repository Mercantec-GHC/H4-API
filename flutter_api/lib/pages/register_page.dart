import 'package:flutter/material.dart';
import 'package:flutter_api/service/auth_service.dart';
import 'package:image_picker_web/image_picker_web.dart'; // Importer image_picker_web
import 'dart:typed_data'; // For at håndtere binære data
import 'home_page.dart';

class RegisterPage extends StatefulWidget {
  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final AuthService _authService = AuthService();
  Uint8List? _selectedImageData;
  String? _fileName;

  bool _isLoading = false;

  Future<void> _pickImage() async {
    final MediaInfo? mediaInfo = await ImagePickerWeb.getImageInfo();

    if (mediaInfo != null) {
      setState(() {
        _selectedImageData = mediaInfo.data;
        _fileName = mediaInfo.fileName;
      });
    }
  }

  void _register() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      final email = _emailController.text;
      final username = _usernameController.text;
      final password = _passwordController.text;

      try {
        await _authService.register(
            email, username, password, _selectedImageData, _fileName);
        // Navigate to HomePage on successful registration
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomePage()),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Registration failed: $e')),
        );
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Create Account')),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(labelText: 'Email'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your email';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _usernameController,
                decoration: InputDecoration(labelText: 'Username'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your username';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _passwordController,
                decoration: InputDecoration(labelText: 'Password'),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your password';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              _selectedImageData != null
                  ? Image.memory(
                      _selectedImageData!,
                      height: 150,
                      width: 150,
                    )
                  : Text('No image selected'),
              TextButton(
                onPressed: _pickImage,
                child: Text('Select Profile Picture'),
              ),
              SizedBox(height: 20),
              _isLoading
                  ? CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: _register,
                      child: Text('Register'),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
