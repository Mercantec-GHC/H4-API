import 'package:flutter/material.dart';
import 'package:flutter_api/service/api_service.dart';

class GroupDetailPage extends StatefulWidget {
  final String groupId;

  GroupDetailPage({required this.groupId});

  @override
  _GroupDetailPageState createState() => _GroupDetailPageState();
}

class _GroupDetailPageState extends State<GroupDetailPage> {
  final ApiService _apiService = ApiService();
  Map<String, dynamic>? _groupData;

  @override
  void initState() {
    super.initState();
    _fetchGroupDetails();
  }

  void _fetchGroupDetails() async {
    try {
      final groupData = await _apiService.getGroupById(widget.groupId);
      setState(() {
        _groupData = groupData;
      });
    } catch (e) {
      print('Fejl ved hentning af gruppedetaljer: $e');
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
                            children: [
                              Icon(Icons.group,
                                  size: 40,
                                  color: Theme.of(context).primaryColor),
                              SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  _groupData!['name'] ?? 'No Name',
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 20),
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
                            return Card(
                              elevation: 2,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: ListTile(
                                leading: Icon(Icons.person,
                                    color: Theme.of(context).primaryColor),
                                title: Text(_groupData!['members'][index]),
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
