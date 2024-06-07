//  ignore_for_file: public_member_api_docs, sort_constructors_first
part of 'punishment_bloc.dart';

enum PunishmentStatus { initial, loading, loaded, error }

enum PaymentStatus { initial, loading, loaded, success, error }

class PunishmentState extends Equatable {
  final PunishmentStatus status;
  final PaymentStatus paymentStatus;
  final List<Punishment> punishments;
  final String paymentUrl;
  final String errorMessage;

  const PunishmentState({
    required this.status,
    required this.paymentStatus,
    required this.punishments,
    required this.paymentUrl,
    required this.errorMessage,
  });

  factory PunishmentState.initial() {
    return const PunishmentState(
      status: PunishmentStatus.initial,
      paymentStatus: PaymentStatus.initial,
      punishments: [],
      paymentUrl: '',
      errorMessage: '',
    );
  }

  PunishmentState copyWith({
    PunishmentStatus? status,
    PaymentStatus? paymentStatus,
    List<Punishment>? punishments,
    String? paymentUrl,
    String? errorMessage,
  }) {
    return PunishmentState(
      status: status ?? this.status,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      punishments: punishments ?? this.punishments,
      paymentUrl: paymentUrl ?? this.paymentUrl,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object> get props =>
      [status, paymentStatus, punishments, paymentUrl, errorMessage];
}
