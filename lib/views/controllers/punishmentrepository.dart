import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tera_driver/models/punishmentmodel.dart';
import 'package:http/http.dart' as http;

class PunishmentRepository {
  final _baseUrl = "http://192.168.0.39:5000";

  Future<List<Punishment>> fetchPunishments(String userId) async {
    List<Punishment> punishments = [];

    var response = await http.get(
        Uri.parse('$_baseUrl/mobileApp/api/punishment/punishments/$userId'));

    print('Response data: ${response.body}'); // Log the entire response data

    var body = jsonDecode(response.body);
    if (body['punishments'] is List) {
      List<dynamic> punishmentList = body['punishments'];
      for (var json in punishmentList) {
        print('Punishment JSON: $json'); // Log each punishment JSON object
        if (json is Map<String, dynamic>) {
          punishments.add(Punishment.fromJson(json));
        } else {
          throw FormatException("Invalid punishment data format");
        }
      }
    } else {
      throw FormatException("Invalid response format");
    }

    return punishments;
  }

  Future<String> payForPunishment({
    required String punishmentId,
  }) async {
    final response = await http.post(
      Uri.parse(
        '$_baseUrl/api/driver/payment/punishment',
      ),
      body: {'punishmentId': punishmentId},
    );
    debugPrint('Punishment ID: $punishmentId');
    var body = jsonDecode(response.body);
    print('Response data: ${response.body}');

    debugPrint('Payment URL: ${body['paymentUrl']}');

    return body['paymentUrl'];
  }
}
