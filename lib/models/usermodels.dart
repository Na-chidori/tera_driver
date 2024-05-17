//usermodels.dart

import 'dart:convert';

List<UserModels> userModelsFromJson(String str) =>
    List<UserModels>.from(json.decode(str).map((x) => UserModels.fromJson(x)));

String userModelsToJson(List<UserModels> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class UserModels {
  int id;
  String name;
  String email;
  String phone;
  String code;
  String licenseplate;
  String licensenumber;
  String Assignedroute;
  String cityDistrict;
  String assignedEmployeeFullName;
  String assignedEmployeeId;

  UserModels(
      {required this.id,
      required this.name,
      required this.email,
      required this.phone,
      required this.code,
      required this.licenseplate,
      required this.licensenumber,
      required this.Assignedroute,
      required this.cityDistrict,
      required this.assignedEmployeeFullName,
      required this.assignedEmployeeId});
// `toJson` converts a UserModels object to a JSON representation.
// `fromJson` creates a UserModels object from a JSON map.

  factory UserModels.fromJson(Map<String, dynamic> json) => UserModels(
        id: int.tryParse(json["_id"]?.split('').last) ?? 0,
        name: '${json['firstName']} ${json['lastName']}',
        email: json['email'],
        phone: json['phone'],
        code: json['code'],
        licenseplate: json['licenseplate'],
        licensenumber: json['licensenumber'],
        Assignedroute: json['Assignedroute'],
        cityDistrict: json['cityDistrict'],
        assignedEmployeeFullName: json['AssignedTransportEmployee']['fullName'],
        assignedEmployeeId: json['AssignedTransportEmployee']['employeeId'],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "email": email,
        "phone": phone,
        "code": code,
        "licenseplate": licenseplate,
        "licensenumber": licensenumber,
        "Assignedroute": Assignedroute,
        "cityDistrict": cityDistrict,
        "assignedEmployeeFullName": assignedEmployeeFullName,
        "assignedEmployeeId": assignedEmployeeId
      };
}
