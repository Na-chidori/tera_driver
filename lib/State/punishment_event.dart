part of 'punishment_bloc.dart';

sealed class PunishmentEvent extends Equatable {
  const PunishmentEvent();

  @override
  List<Object> get props => [];
}

// fetch the products on app start
class GetPunishments extends PunishmentEvent {
  final String userId;

  const GetPunishments({required this.userId});

  @override
  List<Object> get props => [userId];
}

// buy selected product
class PayPunishments extends PunishmentEvent {
  final String punishmentId;
  const PayPunishments({
    required this.punishmentId,
  });
}

// indicate payment has been successfully made
class PaymentSuccessful extends PunishmentEvent {}
