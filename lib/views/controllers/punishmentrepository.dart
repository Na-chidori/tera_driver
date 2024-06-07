import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tera_driver/models/punishmentmodel.dart';

class PunishmentRepository {
  final Dio _dio;

  PunishmentRepository({Dio? dio}) : _dio = dio ?? Dio();

  final _baseUrl = "http://192.168.43.161:5000";

  Future<List<Punishment>> fetchPunishments(String userId) async {
    List<Punishment> punishments = [];
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    var response = await _dio.get(
      '$_baseUrl/mobileApp/api/punishment/punishments/$userId',
      options: Options(
        headers: {
          'Authorization': 'Bearer $token',
        },
      ),
    );

    print('Response data: ${response.data}'); // Log the entire response data

    if (response.data['punishments'] is List) {
      List<dynamic> punishmentList = response.data['punishments'];
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
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    final response = await _dio.post(
      '$_baseUrl/api/driver/payment/punishment',
      data: {'punishmentId': punishmentId},
      options: Options(
        headers: {
          'Authorization': 'Bearer $token',
        },
      ),
    );

    return response.data['paymentUrl'];
  }
}
