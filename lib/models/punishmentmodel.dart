import 'package:equatable/equatable.dart';

class Punishment extends Equatable {
  final String id;
  final String name;
  final double fine;
  const Punishment({
    required this.name,
    required this.fine,
    required this.id,
  });

  //
  factory Punishment.fromJson(Map<String, dynamic> json) {
    print('Parsing punishment JSON: $json');
    return Punishment(
      id: json['_id'] ?? '',
      name: json['punishmentType'] ?? '',
      fine: (json['fine'] ?? 0).toDouble(),
    );
  }

  @override
  List<Object> get props => [id, name, fine];
}
