import 'package:flutter/material.dart';
import 'package:flutter_api/service/api_service.dart';

class CreateGroupPage extends StatefulWidget {
  @override
  _CreateGroupPageState createState() => _CreateGroupPageState();
}

class _CreateGroupPageState extends State<CreateGroupPage> {
  final ApiService _apiService = ApiService();
  final _formKey = GlobalKey<FormState>();
  String _groupName = '';

  void _submit() async {
    if (_formKey.currentState!.validate()) {
      try {
        final newGroup = await _apiService.createGroup(_groupName);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content:
                  Text('Group "${newGroup['name']}" created successfully!')),
        );
        Navigator.pop(context, newGroup); // Returner til den forrige side
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to create group: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Create Group'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                decoration: InputDecoration(labelText: 'Group Name'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a group name';
                  }
                  return null;
                },
                onChanged: (value) {
                  setState(() {
                    _groupName = value;
                  });
                },
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _submit,
                child: Text('Create Group'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
