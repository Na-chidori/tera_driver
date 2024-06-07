import 'dart:io';
import 'package:tera_driver/models/punishmentmodel.dart';
import 'package:tera_driver/views/controllers/punishmentrepository.dart';
import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
part 'punishment_event.dart';
part 'punishment_state.dart';

class PunishmentBloc extends Bloc<PunishmentEvent, PunishmentState> {
  final PunishmentRepository _punishmentRepository;

  PunishmentBloc({
    PunishmentRepository? punishmentRepository,
    Dio? dio,
  })  : _punishmentRepository =
            punishmentRepository ?? PunishmentRepository(dio: Dio()),
        super(PunishmentState.initial()) {
    on<GetPunishments>(_onGetPunishments);
    on<PayPunishments>(_onPayPunishment);
    on<PaymentSuccessful>(_onPaymentSuccessful);
  }

  Future<void> _onGetPunishments(
    GetPunishments event,
    Emitter<PunishmentState> emit,
  ) async {
    emit(state.copyWith(status: PunishmentStatus.loading));
    try {
      final punishments =
          await _punishmentRepository.fetchPunishments(event.userId);
      emit(
        state.copyWith(
          status: PunishmentStatus.loaded,
          punishments: punishments,
        ),
      );
    } on DioError catch (e) {
      String errorMessage = e.response?.data['message'] ??
          'Failed to fetch punishments. Please try again later.';
      print('DioError: $errorMessage');
      emit(state.copyWith(
          status: PunishmentStatus.error, errorMessage: errorMessage));
    } catch (e) {
      print('Unknown error: $e'); // Log the exact error message
      emit(
        state.copyWith(
          status: PunishmentStatus.error,
          errorMessage: 'Failed to fetch punishments. Please try again later.',
        ),
      );
    }
  }

  Future<void> _onPayPunishment(
    PayPunishments event,
    Emitter<PunishmentState> emit,
  ) async {
    try {
      emit(state.copyWith(paymentStatus: PaymentStatus.loading));
      final paymentUrl = await _punishmentRepository.payForPunishment(
          punishmentId: event.punishmentId);
      emit(state.copyWith(
        paymentStatus: PaymentStatus.loaded,
        paymentUrl: paymentUrl,
      ));
    } on DioError catch (e) {
      String errorMessage = e.response?.data['message'] ??
          'Failed to process payment. Please try again later.';
      emit(state.copyWith(
          paymentStatus: PaymentStatus.error, errorMessage: errorMessage));
    } catch (e) {
      emit(
        state.copyWith(
          paymentStatus: PaymentStatus.error,
          errorMessage: 'Failed to process payment. Please try again later.',
        ),
      );
    }
  }

  void _onPaymentSuccessful(
    PaymentSuccessful event,
    Emitter<PunishmentState> emit,
  ) async {
    emit(state.copyWith(paymentStatus: PaymentStatus.success));
  }
}

// Utility for parsing errors in case there is one
String getError(e) {
  String errorMessage = 'Something went wrong';
  if (e is DioException) {
    if (e.error is SocketException) {
      errorMessage = "No Internet Connection!";
    } else if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout ||
        e.type == DioExceptionType.sendTimeout) {
      errorMessage = "Request timeout";
    } else if (e.type == DioExceptionType.badResponse) {
      final response = e.response;

      if (response != null && response.data != null) {
        try {
          final Map responseData = response.data as Map;
          errorMessage = responseData['msg'] ?? '';
        } catch (e) {
          errorMessage = 'Something went wrong';
        }
      }
    }
  }
  return errorMessage;
}
