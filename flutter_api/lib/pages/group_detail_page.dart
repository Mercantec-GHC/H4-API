import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
import 'package:flutter/material.dart';
import 'package:flutter_api/service/api_service.dart';
import 'package:flutter_api/service/auth_service.dart';
import 'user_profile_page.dart';

class GroupDetailPage extends StatefulWidget {
  final String groupId;

  GroupDetailPage({required this.groupId});

  @override
  _GroupDetailPageState createState() => _GroupDetailPageState();
}

class _GroupDetailPageState extends State<GroupDetailPage> {
  final ApiService _apiService = ApiService();
  final AuthService _authService = AuthService();
  Map<String, dynamic>? _groupData;
  String? _currentUserId;
  String? _currentUsername;
  bool _isMember = false;

  @override
  void initState() {
    super.initState();
    _fetchCurrentUser();
  }

  void _fetchGroupDetails() async {
    try {
      final groupData = await _apiService.getGroupById(widget.groupId);
      setState(() {
        _groupData = groupData;
        _checkIfMember();
      });
    } catch (e) {
      print('Fejl ved hentning af gruppedetaljer: $e');
    }
  }

  void _fetchCurrentUser() async {
    try {
      final token = await _authService.getToken();
      if (token != null) {
        final jwt = JWT.decode(token);
        final username = jwt.payload[
                'http://schemas.xmlsoap.org/ws/2005/05/identity/claims/name']
            as String;
        final userData = await _apiService.getUserDataByUsername(username);
        setState(() {
          _currentUserId = userData['id'];
          _currentUsername = username;
        });
        _fetchGroupDetails(); // Fetch group details after getting current user ID
      }
    } catch (e) {
      print('Fejl ved hentning af brugerdata: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to fetch user data. Please try again later.'),
        ),
      );
    }
  }

  void _checkIfMember() {
    if (_groupData != null && _currentUsername != null) {
      setState(() {
        _isMember = _groupData!['members'].contains(_currentUsername);
      });
    }
  }

  void _joinGroup() async {
    if (_currentUserId == null) {
      print('Bruger ID ikke fundet.');
      return;
    }

    try {
      await _apiService.joinGroup(_currentUserId!, widget.groupId);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('You have successfully joined the group')),
      );
      _fetchGroupDetails(); // Opdater gruppedetaljer for at inkludere den nye bruger
    } catch (e) {
      print('Fejl ved at tilmelde sig gruppen: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to join the group')),
      );
    }
  }

  void _leaveGroup() async {
    if (_currentUserId == null) {
      print('Bruger ID ikke fundet.');
      return;
    }

    try {
      await _apiService.leaveGroup(_currentUserId!, widget.groupId);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('You have successfully left the group')),
      );
      _fetchGroupDetails(); // Opdater gruppedetaljer for at fjerne brugeren
    } catch (e) {
      print('Fejl ved at forlade gruppen: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to leave the group')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Group Details'),
      ),
      body: _groupData == null
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      _groupData!['name'] ?? 'No Name',
                                      style: TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    SizedBox(height: 5),
                                    Text(
                                      'Group ID: ${_groupData!['id']}',
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              if (!_isMember)
                                TextButton.icon(
                                  icon: Icon(Icons.add,
                                      color: Theme.of(context).primaryColor),
                                  label: Text(
                                    'Join Group',
                                    style: TextStyle(
                                        color: Theme.of(context).primaryColor),
                                  ),
                                  onPressed: _joinGroup,
                                ),
                              if (_isMember)
                                TextButton.icon(
                                  icon: Icon(Icons.remove,
                                      color: Theme.of(context).primaryColor),
                                  label: Text(
                                    'Leave Group',
                                    style: TextStyle(
                                        color: Theme.of(context).primaryColor),
                                  ),
                                  onPressed: _leaveGroup,
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  Text(
                    'Members',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 10),
                  _groupData!['members'] != null &&
                          _groupData!['members'].isNotEmpty
                      ? ListView.builder(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          itemCount: _groupData!['members'].length,
                          itemBuilder: (context, index) {
                            var username = _groupData!['members'][index];
                            return Card(
                              elevation: 2,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: ListTile(
                                leading: Icon(Icons.person,
                                    color: Theme.of(context).primaryColor),
                                title: Text(username),
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          UserProfilePage(username: username),
                                    ),
                                  );
                                },
                              ),
                            );
                          },
                        )
                      : Text('No members found.'),
                ],
              ),
            ),
    );
  }
}
