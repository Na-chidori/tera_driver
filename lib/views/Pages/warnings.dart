import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:tera_driver/views/controllers/config.dart';
import 'package:tera_driver/models/warningsmodel.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Warnings'),
      ),
      body: ListView.builder(
        itemCount: warnings.length,
        itemBuilder: (context, index) {
          final warning = warnings[index];
          return ListTile(
            title: Text(warning.message),
            subtitle: Text(warning.createdAt.toString()),
            onTap: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: Text(warning.createdAt.toString()),
                    content: Text(warning.message),
                    actions: <Widget>[
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: Text('Close'),
                      ),
                    ],
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
