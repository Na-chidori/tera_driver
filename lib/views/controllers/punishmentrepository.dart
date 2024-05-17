import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tera_driver/models/punishmentmodel.dart';

class PunishmentRepository {
  final Dio _dio;

  PunishmentRepository({Dio? dio}) : _dio = dio ?? Dio();

  final _baseUrl = "http://192.168.18.161:5000";

  Future<List<Punishment>> getPunishments(String userId) async {
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

    response.data['punishments'].forEach((json) {
      punishments.add(Punishment.fromJson(json));
    });

    return punishments;
  }

  Future<String> payPunishment({
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
