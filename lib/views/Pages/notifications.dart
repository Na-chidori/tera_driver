import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:tera_driver/views/controllers/config.dart';

class NotificationPage extends StatefulWidget {
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
    final response = await http.get(Uri.parse(getNotifications));
    if (response.statusCode == 200) {
      final dynamic responseData = json.decode(response.body);
      if (responseData is List<dynamic>) {
        setState(() {
          notifications = responseData
              .map((data) => NotificationModel.fromJson(data))
              .toList();
        });
      } else if (responseData != null &&
          responseData is Map<String, dynamic> &&
          responseData.containsKey('notifications')) {
        // Handle the case where there's a map with a 'notifications' key
        final notificationList = responseData['notifications'] as List<dynamic>;
        setState(() {
          notifications = notificationList
              .map((data) => NotificationModel.fromJson(data))
              .toList();
        });
      } else {
        throw Exception('Invalid response format');
      }
    } else {
      throw Exception('Failed to load notifications');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Notifications'),
      ),
      body: ListView.builder(
        itemCount: notifications.length,
        itemBuilder: (context, index) {
          final notification = notifications[index];
          return ListTile(
            title: Text(notification.message),
            subtitle: Text(notification.createdAt.toString()),
            onTap: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: Text(notification.sender ?? 'Unknown Sender'),
                    content: Text(notification.message),
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
