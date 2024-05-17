//usermodels.dart

import 'dart:convert';

List<WarningsModel> warningsModelFromJson(String str) =>
    List<WarningsModel>.from(
        json.decode(str).map((x) => WarningsModel.fromJson(x)));

String warningsModelToJson(List<WarningsModel> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class WarningsModel {
  int id;
  String message;
  final DateTime createdAt;

  WarningsModel(
      {required this.id, required this.message, required this.createdAt});
// `toJson` converts a UserModels object to a JSON representation.
// `fromJson` creates a UserModels object from a JSON map.

  factory WarningsModel.fromJson(Map<String, dynamic> json) => WarningsModel(
        id: int.tryParse(json["_id"]?.split('').last) ?? 0,
        message: json['message'],
        createdAt: DateTime.parse(json['date'] as String),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "message": message,
        "createdAt": createdAt.toIso8601String(),
      };
}
