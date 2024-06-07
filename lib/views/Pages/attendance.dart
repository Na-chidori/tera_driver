import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:intl/intl.dart';
import 'package:tera_driver/views/controllers/config.dart';

class Attendance extends StatefulWidget {
  final String token;
  const Attendance({required this.token, Key? key}) : super(key: key);

  @override
  State<Attendance> createState() => _AttendanceState();
}

class _AttendanceState extends State<Attendance> {
  late String driverId;
  List<dynamic> attendanceData = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchAttendanceData();
  }

  Future<void> fetchAttendanceData() async {
    try {
      Map<String, dynamic> decodedToken = JwtDecoder.decode(widget.token);
      driverId = decodedToken['driverId'] ?? '';
      final response = await http.get(
        Uri.parse('$driverAttendance/$driverId'),
        headers: {'Authorization': 'Bearer ${widget.token}'},
      );

      if (response.statusCode == 200) {
        setState(() {
          attendanceData = json.decode(response.body);
          isLoading = false;
        });
      } else {
        // Handle the error
        print('Failed to load attendance data');
      }
    } catch (e) {
      // Handle exceptions
      print('Exception occurred while fetching attendance data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Attendance'),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : attendanceData.isEmpty
              ? Center(child: Text('No attendance history yet'))
              : ListView.builder(
                  itemCount: attendanceData.length,
                  itemBuilder: (context, index) {
                    final attendance = attendanceData[index];
                    final rounds = attendance['rounds'] as List<dynamic>;
                    final overallStatus = attendance['overallStatus'];
                    final date = attendance['date'] != null
                        ? DateFormat('yyyy-MM-dd')
                            .format(DateTime.parse(attendance['date']))
                        : '';

                    return Card(
                      color: overallStatus == 'Completed'
                          ? Colors.lightGreen[100]
                          : Colors.red[100],
                      margin: EdgeInsets.all(10.0),
                      child: Padding(
                        padding: EdgeInsets.all(10.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            GridView.builder(
                              shrinkWrap: true,
                              gridDelegate:
                                  SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 4,
                                mainAxisSpacing: 8.0,
                                crossAxisSpacing: 8.0,
                              ),
                              itemCount: rounds.length,
                              itemBuilder: (context, index) {
                                final round = rounds[index];
                                return Container(
                                  width: 40,
                                  height: 40,
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    color: round['status'] == 'Complete'
                                        ? Colors.green
                                        : Colors.red,
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                  child: Text(
                                    round['roundNumber']?.toString() ?? '',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                );
                              },
                            ),
                            SizedBox(height: 10),
                            Align(
                              alignment: Alignment.bottomLeft,
                              child: Text(
                                'Date: $date',
                                style: TextStyle(color: Colors.black54),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
