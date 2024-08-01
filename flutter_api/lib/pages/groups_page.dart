import 'package:flutter/material.dart';
import 'package:flutter_api/service/api_service.dart';
import 'group_detail_page.dart';
import 'create_group_page.dart';

class GroupsPage extends StatefulWidget {
  @override
  _GroupsPageState createState() => _GroupsPageState();
}

class _GroupsPageState extends State<GroupsPage> {
  final ApiService _apiService = ApiService();
  List<dynamic>? _groups;

  @override
  void initState() {
    super.initState();
    _fetchGroups();
  }

  void _fetchGroups() async {
    try {
      final groups = await _apiService.getGroups();
      setState(() {
        _groups = groups;
      });
    } catch (e) {
      print('Fejl ved hentning af grupper: $e');
    }
  }

  void _navigateToCreateGroup() async {
    final newGroup = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => CreateGroupPage()),
    );

    if (newGroup != null) {
      _fetchGroups(); // Genindlæs grupperne for at inkludere den nye gruppe
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Groups'),
      ),
      body: Center(
        child: _groups == null
            ? CircularProgressIndicator()
            : Padding(
                padding: const EdgeInsets.all(8.0),
                child: ListView.builder(
                  itemCount: _groups?.length ?? 0,
                  itemBuilder: (context, index) {
                    final group = _groups![index];
                    return Card(
                      margin: EdgeInsets.symmetric(vertical: 8.0),
                      elevation: 5,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: ListTile(
                        contentPadding: EdgeInsets.symmetric(
                          vertical: 10.0,
                          horizontal: 16.0,
                        ),
                        title: Text(
                          group['name'] ?? 'No Name',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        subtitle: Text(
                          'Group ID: ${group['id']}',
                          style: TextStyle(fontSize: 14, color: Colors.grey),
                        ),
                        leading: Icon(
                          Icons.group,
                          color: Theme.of(context).primaryColor,
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  GroupDetailPage(groupId: group['id']),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
              ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToCreateGroup,
        child: Icon(Icons.add),
        tooltip: 'Create Group',
      ),
    );
  }
}
