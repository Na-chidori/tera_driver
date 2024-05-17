import 'package:equatable/equatable.dart';

class Punishment extends Equatable {
  final String id;
  final String name;
  final double price;
  const Punishment({
    required this.name,
    required this.price,
    required this.id,
  });

  //
  factory Punishment.fromJson(Map<String, dynamic> json) {
    return Punishment(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      price: (json['price'] ?? 0).toDouble(),
    );
  }

  @override
  List<Object> get props => [id, name, price];
}
