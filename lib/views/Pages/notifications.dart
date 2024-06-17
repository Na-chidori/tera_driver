import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart'; // For date formatting
import 'package:tera_driver/views/controllers/config.dart';

class NotificationPage extends StatefulWidget {
  final Function(int) onNotificationCountChanged;

  NotificationPage({required this.onNotificationCountChanged});

  @override
  _NotificationPageState createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  List<NotificationModel> notifications = [];

  @override
  void initState() {
    super.initState();
    fetchNotifications();
  }

  Future<void> fetchNotifications() async {
    try {
      final response = await http.get(Uri.parse(getNotifications));
      if (response.statusCode == 200) {
        final dynamic responseData = json.decode(response.body);
        if (responseData is List<dynamic>) {
          setState(() {
            notifications = responseData
                .map((data) => NotificationModel.fromJson(data))
                .toList();
            widget.onNotificationCountChanged(notifications.length);
          });
        } else if (responseData != null &&
            responseData is Map<String, dynamic> &&
            responseData.containsKey('notifications')) {
          final notificationList =
              responseData['notifications'] as List<dynamic>;
          setState(() {
            notifications = notificationList
                .map((data) => NotificationModel.fromJson(data))
                .toList();
            widget.onNotificationCountChanged(notifications.length);
          });
        } else {
          throw Exception('Invalid response format');
        }
      } else {
        throw Exception('Failed to load notifications');
      }
    } catch (e) {
      print('Error fetching notifications: $e');
      // Handle error gracefully
    }
  }

  String formatDateTime(DateTime dateTime) {
    return DateFormat('dd MMM yyyy, hh:mm a').format(dateTime);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Notifications'),
        backgroundColor: Colors.blueAccent,
      ),
      body: notifications.isEmpty
          ? Center(
              child: Text(
                'No notifications available',
                style: TextStyle(fontSize: 18.0, color: Colors.grey),
              ),
            )
          : ListView.builder(
              padding: EdgeInsets.all(8.0),
              itemCount: notifications.length,
              itemBuilder: (context, index) {
                final notification = notifications[index];
                return Card(
                  margin: EdgeInsets.symmetric(vertical: 8.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  child: ListTile(
                    contentPadding: EdgeInsets.all(16.0),
                    title: Text(
                      notification.message,
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(formatDateTime(notification.createdAt)),
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20.0),
                            ),
                            title:
                                Text(notification.sender ?? 'Unknown Sender'),
                            content: Text(notification.message),
                            actions: <Widget>[
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                child: Text(
                                  'Close',
                                  style: TextStyle(color: Colors.deepOrange),
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

class NotificationModel {
  final String message;
  final DateTime createdAt;
  final String? sender; // Mark sender as nullable

  NotificationModel({
    required this.message,
    required this.createdAt,
    this.sender,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      message: json['message'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      sender: json['sender'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        "message": message,
        "createdAt": createdAt.toIso8601String(),
        "sender": sender,
      };
}
