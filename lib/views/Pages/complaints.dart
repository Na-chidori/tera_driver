import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:http/http.dart' as http;
import 'package:tera_driver/views/controllers/config.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

class Complaints extends StatefulWidget {
  final token;
  const Complaints({@required this.token, Key? key}) : super(key: key);

  @override
  State<Complaints> createState() => _ComplaintsState();
}

class _ComplaintsState extends State<Complaints> {
  late String userId;
  TextEditingController _ComplaintTitle = TextEditingController();
  TextEditingController _ComplaintDesc = TextEditingController();
  List? items;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    Map<String, dynamic> jwtDecodedToken = JwtDecoder.decode(widget.token);

    userId = jwtDecodedToken['_id'];
    getComplaint(userId);
  }

  void addComplaint() async {
    if (_ComplaintTitle.text.isNotEmpty && _ComplaintDesc.text.isNotEmpty) {
      var regBody = {
        "userId": userId,
        "title": _ComplaintTitle.text,
        "desc": _ComplaintDesc.text
      };

      var response = await http.post(Uri.parse(sendcomplaint),
          headers: {"Content-Type": "application/json"},
          body: jsonEncode(regBody));

      var jsonResponse = jsonDecode(response.body);

      print(jsonResponse['status']);

      if (jsonResponse['status']) {
        _ComplaintDesc.clear();
        _ComplaintTitle.clear();
        Navigator.pop(context);
      } else {
        print("SomeThing Went Wrong");
      }
    }
  }

  void getComplaint(userId) async {
    var regBody = {"userId": userId};
    var response = await http.post(Uri.parse(getcomplaint),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(regBody));
    var jsonResponse = jsonDecode(response.body);
    items = jsonResponse['success'];
    setState(() {});
  }

  void deleteComplaint(id) async {
    var regBody = {"id": id};
    var response = await http.post(Uri.parse(deletecomplaint),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(regBody));
    var jsonResponse = jsonDecode(response.body);
    if (jsonResponse['status']) {
      getComplaint(userId);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: "Complaints".text.make(),
      ),
      backgroundColor: Colors.lightBlueAccent,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20))),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: items == null
                    ? null
                    : ListView.builder(
                        itemCount: items!.length,
                        itemBuilder: (context, int index) {
                          return Slidable(
                            key: const ValueKey(0),
                            endActionPane: ActionPane(
                              motion: const ScrollMotion(),
                              dismissible: DismissiblePane(onDismissed: () {}),
                              children: [
                                SlidableAction(
                                  backgroundColor: Color(0xFFFE4A49),
                                  foregroundColor: Colors.white,
                                  icon: Icons.delete,
                                  label: 'Delete',
                                  onPressed: (BuildContext context) {
                                    print('${items![index]['_id']}');
                                    deleteComplaint('${items![index]['_id']}');
                                  },
                                ),
                              ],
                            ),
                            child: Card(
                              borderOnForeground: false,
                              child: ListTile(
                                leading: Icon(Icons.task),
                                title: Text('${items![index]['title']}'),
                                subtitle: Text('${items![index]['desc']}'),
                                trailing: Icon(Icons.arrow_back),
                              ),
                            ),
                          );
                        }),
              ),
            ),
          )
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _displayTextInputDialog(context),
        child: Icon(Icons.add),
        tooltip: 'Send Complaint',
      ),
    );
  }

  Future<void> _displayTextInputDialog(BuildContext context) async {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
              title: Text('Send Complaint'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: _ComplaintTitle,
                    keyboardType: TextInputType.text,
                    decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        hintText: "Title",
                        border: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(10.0)))),
                  ).p4().px8(),
                  TextField(
                    controller: _ComplaintDesc,
                    keyboardType: TextInputType.text,
                    decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        hintText: "Description",
                        border: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(10.0)))),
                  ).p4().px8(),
                  ElevatedButton(
                      onPressed: () {
                        addComplaint();
                      },
                      child: Text("Send Complaint"))
                ],
              ));
        });
  }
}
