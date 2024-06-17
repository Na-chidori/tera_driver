import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:tera_driver/views/controllers/config.dart';
import 'package:tera_driver/models/warningsmodel.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:intl/intl.dart';

class WarningsPage extends StatefulWidget {
  final String token;
  const WarningsPage({required this.token, Key? key}) : super(key: key);

  @override
  _WarningsPageState createState() => _WarningsPageState();
}

class _WarningsPageState extends State<WarningsPage> {
  List<WarningsModel> warnings = [];
  late String userId;

  @override
  void initState() {
    super.initState();
    Map<String, dynamic> jwtDecodedToken = JwtDecoder.decode(widget.token);
    userId = jwtDecodedToken['_id'];
    fetchWarnings(userId);
  }

  Future<void> fetchWarnings(String userId) async {
    try {
      final response = await http.get(Uri.parse('$getWarnings/$userId'));
      if (response.statusCode == 200) {
        final List<dynamic> responseData = jsonDecode(response.body);
        List<WarningsModel> fetchedWarnings =
            responseData.map((data) => WarningsModel.fromJson(data)).toList();

        setState(() {
          warnings = fetchedWarnings;
        });
      } else {
        print('Failed to load Warnings - ${response.statusCode}');
        print(response.body);
        throw Exception('Failed to load user Warnings');
      }
    } catch (e) {
      print('Error fetching warnings: $e');
      // Handle error gracefully (e.g., show a snackbar)
    }
  }

  String formatDate(DateTime date) {
    return DateFormat('yyyy-MM-dd – kk:mm').format(date);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Warnings'),
        backgroundColor: Colors.deepOrange,
      ),
      body: warnings.isEmpty
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: warnings.length,
              itemBuilder: (context, index) {
                final warning = warnings[index];
                return Card(
                  margin: EdgeInsets.all(10.0),
                  elevation: 5.0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15.0),
                  ),
                  child: ListTile(
                    contentPadding: EdgeInsets.all(10.0),
                    leading: Icon(
                      Icons.warning,
                      color: Colors.deepOrange,
                      size: 40.0,
                    ),
                    title: Text(
                      warning.message,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Text(formatDate(warning.createdAt)),
                    trailing: Icon(
                      Icons.arrow_forward_ios,
                      color: Colors.deepOrange,
                    ),
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20.0),
                            ),
                            title: Text(
                              'Warning Details',
                              style: TextStyle(
                                color: Colors.deepOrange,
                              ),
                            ),
                            content: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  formatDate(warning.createdAt),
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: 10.0),
                                Text(warning.message),
                              ],
                            ),
                            actions: <Widget>[
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                child: Text(
                                  'Close',
                                  style: TextStyle(
                                    color: Colors.deepOrange,
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                      );
                    },
                  ),
                );
              },
            ),
    );
  }
}
