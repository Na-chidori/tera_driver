//  ignore_for_file: public_member_api_docs, sort_constructors_first
part of 'punishment_bloc.dart';

enum PunishmentStatus { initial, loading, loaded, error }

enum PaymentStatus { initial, loading, loaded, success, error }

class PunishmentState extends Equatable {
  final PunishmentStatus status;
  final PaymentStatus paymentStatus;
  final String errorMessage;
  final List<Punishment> punishments;
  final String paymentUrl;

  const PunishmentState({
    required this.status,
    required this.paymentStatus,
    required this.errorMessage,
    required this.punishments,
    required this.paymentUrl,
  });

  factory PunishmentState.initial() {
    return const PunishmentState(
      status: PunishmentStatus.initial,
      paymentStatus: PaymentStatus.initial,
      errorMessage: '',
      punishments: [],
      paymentUrl: '',
    );
  }
  @override
  List<Object> get props =>
      [status, paymentStatus, errorMessage, punishments, paymentUrl];

  PunishmentState copyWith({
    PunishmentStatus? status,
    PaymentStatus? paymentStatus,
    String? errorMessage,
    List<Punishment>? punishments,
    String? paymentUrl,
  }) {
    return PunishmentState(
      status: status ?? this.status,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      errorMessage: errorMessage ?? this.errorMessage,
      punishments: punishments ?? this.punishments,
      paymentUrl: paymentUrl ?? this.paymentUrl,
    );
  }
}
