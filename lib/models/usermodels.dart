import 'dart:convert';

List<UserModels> userModelsFromJson(String str) =>
    List<UserModels>.from(json.decode(str).map((x) => UserModels.fromJson(x)));

String userModelsToJson(List<UserModels> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class UserModels {
  String id; // Change type from int to String
  String name;
  String email;
  String phone;
  String code;
  String licenseplate;
  String licensenumber;
  String Assignedroute;
  String cityDistrict;

  UserModels({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.code,
    required this.licenseplate,
    required this.licensenumber,
    required this.Assignedroute,
    required this.cityDistrict,
  });

  factory UserModels.fromJson(Map<String, dynamic> json) => UserModels(
        id: json["_id"] ?? '', // Parse _id as string
        name: '${json['firstName']} ${json['lastName']}',
        email: json['email'],
        phone: json['phone'],
        code: json['code'],
        licenseplate: json['licenseplate'],
        licensenumber: json['licensenumber'],
        Assignedroute: json['Assignedroute'],
        cityDistrict: json['cityDistrict'],
      );

  Map<String, dynamic> toJson() => {
        "_id": id, // Use _id to match MongoDB document field
        "name": name,
        "email": email,
        "phone": phone,
        "code": code,
        "licenseplate": licenseplate,
        "licensenumber": licensenumber,
        "Assignedroute": Assignedroute,
        "cityDistrict": cityDistrict,
      };
}
