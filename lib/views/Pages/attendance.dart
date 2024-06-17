import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:intl/intl.dart';
import 'package:web_socket_channel/web_socket_channel.dart'; // Added for WebSocket integration
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
  late WebSocketChannel channel; // WebSocket channel

  @override
  void initState() {
    super.initState();
    Map<String, dynamic> decodedToken = JwtDecoder.decode(widget.token);
    driverId = decodedToken['_id'];
    fetchAttendanceData(driverId);

    // Initialize WebSocket connection
    channel = WebSocketChannel.connect(
      Uri.parse(
          'ws://192.168.0.39:5000'), // Replace with your WebSocket server address
    );

    // Listen for updates from the WebSocket server
    channel.stream.listen((data) {
      final newAttendanceData = json.decode(data);
      setState(() {
        attendanceData = newAttendanceData;
      });
    });
  }

  @override
  void dispose() {
    // Close the WebSocket connection when the widget is disposed
    channel.sink.close();
    super.dispose();
  }

  Future<void> fetchAttendanceData(String driverId) async {
    try {
      final response = await http.get(
        Uri.parse('$driverAttendance/$driverId'),
      );
      print(response.statusCode);
      if (response.statusCode == 200) {
        setState(() {
          attendanceData = json.decode(response.body);
          isLoading = false;
        });
      } else {
        // Handle the error
        print('Failed to load attendance data');
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      // Handle exceptions
      print('Exception occurred while fetching attendance data: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  String formatDate(String date) {
    return DateFormat('yyyy-MM-dd').format(DateTime.parse(date));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Attendance'),
        backgroundColor: Colors.blueAccent,
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : attendanceData.isEmpty
              ? Center(
                  child: Text(
                    'No attendance history yet',
                    style: TextStyle(fontSize: 18.0, color: Colors.grey),
                  ),
                )
              : ListView.builder(
                  padding: EdgeInsets.all(8.0),
                  itemCount: attendanceData.length,
                  itemBuilder: (context, index) {
                    final attendance = attendanceData[index];
                    final rounds = attendance['rounds'] as List<dynamic>;
                    final overallStatus = attendance['overallStatus'];
                    final date = attendance['date'] != null
                        ? formatDate(attendance['date'])
                        : '';

                    return Card(
                      color: overallStatus == 'Completed'
                          ? Colors.lightGreen[100]
                          : Colors.red[100],
                      margin: EdgeInsets.symmetric(vertical: 8.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15.0),
                      ),
                      child: Padding(
                        padding: EdgeInsets.all(12.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            GridView.builder(
                              physics: NeverScrollableScrollPhysics(),
                              shrinkWrap: true,
                              gridDelegate:
                                  SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 4,
                                mainAxisSpacing: 8.0,
                                crossAxisSpacing: 8.0,
                              ),
                              itemCount: rounds.length,
                              itemBuilder: (context, roundIndex) {
                                final round = rounds[roundIndex];
                                return Container(
                                  width: 40,
                                  height: 40,
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    color: round['status'] == 'Complete'
                                        ? Colors.green
                                        : const Color.fromARGB(
                                            255, 255, 123, 0),
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
