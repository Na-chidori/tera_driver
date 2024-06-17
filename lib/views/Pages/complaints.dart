import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:tera_driver/views/controllers/config.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:intl/intl.dart';

class Complaints extends StatefulWidget {
  final String token;
  const Complaints({required this.token, Key? key}) : super(key: key);

  @override
  State<Complaints> createState() => _ComplaintsState();
}

class _ComplaintsState extends State<Complaints> {
  List<Map<String, dynamic>> sentComplaints = [];
  late String userId;

  @override
  void initState() {
    super.initState();
    Map<String, dynamic> jwtDecodedToken = JwtDecoder.decode(widget.token);
    userId = jwtDecodedToken['_id'];
    getComplaints(userId);
  }

  void getComplaints(String userId) async {
    var response = await http.get(
      Uri.parse('$getcomplaint/$userId'),
      headers: {"Content-Type": "application/json"},
    );

    if (response.statusCode == 200) {
      try {
        var jsonResponse = jsonDecode(response.body);
        print("Get Complaints Response: $jsonResponse");
        if (jsonResponse['status']) {
          setState(() {
            sentComplaints =
                List<Map<String, dynamic>>.from(jsonResponse['success']);
          });
        } else {
          setState(() {
            sentComplaints = [];
          });
          print("No complaints found");
        }
      } catch (e) {
        print("Error decoding get complaints response: $e");
      }
    } else {
      print("Server returned status code: ${response.statusCode}");
      print("Response body: ${response.body}");
    }
  }

  void deleteComplaint(String id) async {
    var response = await http.delete(
      Uri.parse('$deletecomplaint/$id'),
      headers: {"Content-Type": "application/json"},
    );

    if (response.statusCode == 200) {
      try {
        var jsonResponse = jsonDecode(response.body);
        if (jsonResponse['status']) {
          getComplaints(userId); // Refresh the complaints list
        }
      } catch (e) {
        print("Error decoding delete complaint response: $e");
      }
    } else {
      print("Server returned status code: ${response.statusCode}");
      print("Response body: ${response.body}");
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text("Complaints"),
          backgroundColor: Colors.blueAccent,
          bottom: TabBar(
            tabs: [
              Tab(
                text: "Send Complaint",
              ),
              Tab(text: "View Replies"),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            SendComplaintTab(
                userId: userId,
                token: widget.token,
                onComplaintAdded: () => getComplaints(userId)),
            ViewRepliesTab(
                items: sentComplaints
                    .where((complaint) => complaint['reply'] != null)
                    .toList(),
                onDelete: (id) => deleteComplaint(id)),
          ],
        ),
      ),
    );
  }
}

class SendComplaintTab extends StatefulWidget {
  final String userId;
  final VoidCallback onComplaintAdded;
  final String token;

  const SendComplaintTab(
      {required this.userId,
      required this.token,
      required this.onComplaintAdded,
      Key? key})
      : super(key: key);

  @override
  _SendComplaintTabState createState() => _SendComplaintTabState();
}

class _SendComplaintTabState extends State<SendComplaintTab> {
  List<Map<String, dynamic>> sentComplaints = [];

  @override
  void initState() {
    super.initState();
    fetchSentComplaints();
  }

  void fetchSentComplaints() async {
    var response = await http.get(
      Uri.parse('$getcomplaint/${widget.userId}'),
      headers: {"Content-Type": "application/json"},
    );

    if (response.statusCode == 200) {
      try {
        var jsonResponse = jsonDecode(response.body);
        print("Get Sent Complaints Response: $jsonResponse");
        if (jsonResponse['status']) {
          setState(() {
            sentComplaints =
                List<Map<String, dynamic>>.from(jsonResponse['success']);
          });
        } else {
          print("No complaints found");
        }
      } catch (e) {
        print("Error decoding get sent complaints response: $e");
      }
    } else {
      print("Server returned status code: ${response.statusCode}");
      print("Response body: ${response.body}");
    }
  }

  void addComplaint(String subject, String description) async {
    if (subject.isEmpty || description.isEmpty) {
      print("Subject or Description is empty");
      return;
    }

    var regBody = {
      "userId": widget.userId,
      "subject": subject, // Ensure 'subject' key matches backend expectation
      "description": description
    };

    var response = await http.post(
      Uri.parse(sendcomplaint),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer ${widget.token}"
      },
      body: jsonEncode(regBody),
    );

    if (response.statusCode == 200) {
      try {
        var jsonResponse = jsonDecode(response.body);
        print("Add Complaint Response: $jsonResponse");
        if (jsonResponse['status']) {
          widget.onComplaintAdded();
          fetchSentComplaints();
        } else {
          print("Add Complaint Error: Something went wrong");
        }
      } catch (e) {
        print("Error decoding add complaint response: $e");
      }
    } else {
      print("Server returned status code: ${response.statusCode}");
      print("Response body: ${response.body}");
    }
  }

  void deleteComplaint(String id) async {
    var response = await http.delete(
      Uri.parse('$deletecomplaint/$id'),
      headers: {"Content-Type": "application/json"},
    );

    if (response.statusCode == 200) {
      try {
        var jsonResponse = jsonDecode(response.body);
        print("Delete Complaint Response: $jsonResponse");
        if (jsonResponse['status']) {
          setState(() {
            sentComplaints.removeWhere((complaint) => complaint['_id'] == id);
          });
        } else {
          print("Delete Complaint Error: Something went wrong");
        }
      } catch (e) {
        print("Error decoding delete complaint response: $e");
      }
    } else {
      print("Server returned status code: ${response.statusCode}");
      print("Response body: ${response.body}");
    }
  }

  void _showAddComplaintBottomSheet(BuildContext context) {
    TextEditingController _ComplaintTitle = TextEditingController();
    TextEditingController _ComplaintDesc = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 16,
            right: 16,
            top: 16,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _ComplaintTitle,
                decoration: InputDecoration(labelText: "Subject"),
              ),
              SizedBox(height: 10),
              TextField(
                controller: _ComplaintDesc,
                decoration: InputDecoration(labelText: "Description"),
              ),
              SizedBox(height: 10),
              ElevatedButton(
                onPressed: () {
                  addComplaint(_ComplaintTitle.text, _ComplaintDesc.text);
                  Navigator.pop(context);
                },
                child: Text("Send"),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: sentComplaints.isEmpty
            ? Center(child: Text("No complaints sent yet"))
            : ListView.builder(
                itemCount: sentComplaints.length,
                itemBuilder: (context, index) {
                  final complaint = sentComplaints[index];
                  final formattedDate = DateFormat('yyyy-MM-dd')
                      .format(DateTime.parse(complaint['createdAt']));
                  return Slidable(
                    key: ValueKey(complaint['_id']),
                    endActionPane: ActionPane(
                      motion: const ScrollMotion(),
                      children: [
                        SlidableAction(
                          backgroundColor: Color(0xFFFE4A49),
                          foregroundColor: Colors.white,
                          icon: Icons.delete,
                          label: 'Delete',
                          onPressed: (BuildContext context) {
                            deleteComplaint(complaint['_id']);
                          },
                        ),
                      ],
                    ),
                    child: Card(
                      child: ListTile(
                        title: Text(complaint['subject']),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(complaint['description']),
                            SizedBox(height: 10),
                            Text("Sent on: $formattedDate",
                                style: TextStyle(
                                    fontSize: 12, color: Colors.grey)),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddComplaintBottomSheet(context),
        child: Icon(Icons.add),
      ),
    );
  }
}

class ViewRepliesTab extends StatelessWidget {
  final List<Map<String, dynamic>> items;
  final Function(String) onDelete;

  const ViewRepliesTab({required this.items, required this.onDelete, Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final repliedComplaints =
        items.where((complaint) => complaint['reply'] != null).toList();

    return repliedComplaints.isEmpty
        ? Center(child: Text("No complaints found"))
        : ListView.builder(
            itemCount: repliedComplaints.length,
            itemBuilder: (context, index) {
              var complaint = repliedComplaints[index];
              var reply = complaint['reply'];
              return Slidable(
                key: ValueKey(complaint['_id']),
                endActionPane: ActionPane(
                  motion: const ScrollMotion(),
                  children: [
                    SlidableAction(
                      backgroundColor: Color(0xFFFE4A49),
                      foregroundColor: Colors.white,
                      icon: Icons.delete,
                      label: 'Delete',
                      onPressed: (BuildContext context) {
                        onDelete(complaint['_id']);
                      },
                    ),
                  ],
                ),
                child: Card(
                  child: ListTile(
                    title: Text(complaint['subject']),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(complaint['description']),
                        if (reply != null) ...[
                          SizedBox(height: 10),
                          Text("Reply: $reply",
                              style: TextStyle(fontWeight: FontWeight.bold)),
                        ]
                      ],
                    ),
                  ),
                ),
              );
            },
          );
  }
}
