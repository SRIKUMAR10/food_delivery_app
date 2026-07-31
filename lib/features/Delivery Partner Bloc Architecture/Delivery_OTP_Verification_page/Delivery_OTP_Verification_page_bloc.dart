import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'Delivery_OTP_Verification_page_event.dart';
import 'Delivery_OTP_Verification_page_repository.dart';
import 'Delivery_OTP_Verification_page_state.dart';

class DeliveryOtpVerificationBloc
    extends Bloc<DeliveryOtpVerificationEvent, DeliveryOtpVerificationState> {
  final DeliveryOtpVerificationRepositoryBase repository;
  Timer? _timer;

  DeliveryOtpVerificationBloc({
    required this.repository,
    required String verificationId,
    required String name,
    required String phone,
    required String email,
    required String password,
  }) : super(DeliveryOtpVerificationState(
          verificationId: verificationId,
          name: name,
          phone: phone,
          email: email,
          password: password,
          resendSeconds: 30,
          isResendEnabled: false,
        )) {
    on<DeliveryOtpChangedEvent>(_onOtpChanged);
    on<DeliveryOtpVerifySubmittedEvent>(_onVerifySubmitted);
    on<DeliveryOtpResendRequestedEvent>(_onResendRequested);
    on<DeliveryOtpTimerTickedEvent>(_onTimerTicked);

    _startResendTimer();
  }

  void _startResendTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      final currentSeconds = state.resendSeconds;
      if (currentSeconds > 1) {
        add(DeliveryOtpTimerTickedEvent(currentSeconds - 1));
      } else {
        _timer?.cancel();
        add(const DeliveryOtpTimerTickedEvent(0));
      }
    });
  }

  void _onTimerTicked(
    DeliveryOtpTimerTickedEvent event,
    Emitter<DeliveryOtpVerificationState> emit,
  ) {
    emit(state.copyWith(
      resendSeconds: event.duration,
      isResendEnabled: event.duration == 0,
    ));
  }

  void _onOtpChanged(
    DeliveryOtpChangedEvent event,
    Emitter<DeliveryOtpVerificationState> emit,
  ) {
    emit(state.copyWith(
      otp: event.otp,
      clearOtpError: true,
      clearError: true,
    ));
  }

  Future<void> _onVerifySubmitted(
    DeliveryOtpVerifySubmittedEvent event,
    Emitter<DeliveryOtpVerificationState> emit,
  ) async {
    if (!state.isOtpValid) {
      emit(state.copyWith(
        status: DeliveryOtpStatus.failure,
        otpError: 'Please enter a valid 6-digit OTP code',
        errorMessage: 'Please enter a valid 6-digit OTP code',
      ));
      return;
    }

    emit(state.copyWith(
      status: DeliveryOtpStatus.loading,
      clearError: true,
      clearOtpError: true,
    ));

    try {
      await repository.verifyOtpAndCreateAccount(
        verificationId: state.verificationId,
        smsCode: state.otp.trim(),
        name: state.name,
        phone: state.phone,
        email: state.email,
        password: state.password,
      );

      emit(state.copyWith(
        status: DeliveryOtpStatus.success,
        errorMessage: null,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: DeliveryOtpStatus.failure,
        errorMessage: e.toString().replaceAll('Exception: ', ''),
      ));
    }
  }

  Future<void> _onResendRequested(
    DeliveryOtpResendRequestedEvent event,
    Emitter<DeliveryOtpVerificationState> emit,
  ) async {
    if (!state.isResendEnabled) return;

    emit(state.copyWith(
      status: DeliveryOtpStatus.loading,
      isResendEnabled: false,
      resendSeconds: 30,
      clearError: true,
    ));

    try {
      final newVerificationId = await repository.resendOtp(phone: state.phone);
      emit(state.copyWith(
        status: DeliveryOtpStatus.initial,
        verificationId: newVerificationId.isNotEmpty
            ? newVerificationId
            : state.verificationId,
        resendSeconds: 30,
        isResendEnabled: false,
        errorMessage: null,
      ));
      _startResendTimer();
    } catch (e) {
      emit(state.copyWith(
        status: DeliveryOtpStatus.failure,
        isResendEnabled: true,
        errorMessage: e.toString().replaceAll('Exception: ', ''),
      ));
    }
  }

  @override
  Future<void> close() {
    _timer?.cancel();
    return super.close();
  }
}
