import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'Delivery_Forgot_Password_page_event.dart';
import 'Delivery_Forgot_Password_page_repository.dart';
import 'Delivery_Forgot_Password_page_service.dart';
import 'Delivery_Forgot_Password_page_state.dart';

class DeliveryForgotPasswordBloc
    extends Bloc<DeliveryForgotPasswordEvent, DeliveryForgotPasswordState> {
  final DeliveryForgotPasswordRepositoryBase repository;
  final DeliveryForgotPasswordServiceBase service;

  DeliveryForgotPasswordBloc({
    DeliveryForgotPasswordRepositoryBase? repository,
    DeliveryForgotPasswordServiceBase? service,
  })  : repository = repository ?? DeliveryForgotPasswordRepository(),
        service = service ?? DeliveryForgotPasswordService(),
        super(const DeliveryForgotPasswordState()) {
    on<DeliveryForgotPasswordPhoneChanged>(_onPhoneChanged);
    on<DeliveryForgotPasswordOtpChanged>(_onOtpChanged);
    on<DeliveryForgotPasswordPasswordChanged>(_onPasswordChanged);
    on<DeliveryForgotPasswordConfirmPasswordChanged>(_onConfirmPasswordChanged);
    on<DeliveryForgotPasswordTogglePasswordVisibility>(_onTogglePasswordVisibility);
    on<DeliveryForgotPasswordToggleConfirmPasswordVisibility>(_onToggleConfirmPasswordVisibility);
    on<DeliveryForgotPasswordSendOtpRequested>(_onSendOtpRequested);
    on<DeliveryForgotPasswordSubmitted>(_onSubmitted);
  }

  void _onPhoneChanged(
    DeliveryForgotPasswordPhoneChanged event,
    Emitter<DeliveryForgotPasswordState> emit,
  ) {
    emit(state.copyWith(phoneNumber: event.phone, clearErrors: true));
  }

  void _onOtpChanged(
    DeliveryForgotPasswordOtpChanged event,
    Emitter<DeliveryForgotPasswordState> emit,
  ) {
    emit(state.copyWith(otp: event.otp, clearErrors: true));
  }

  void _onPasswordChanged(
    DeliveryForgotPasswordPasswordChanged event,
    Emitter<DeliveryForgotPasswordState> emit,
  ) {
    emit(state.copyWith(password: event.password, clearErrors: true));
  }

  void _onConfirmPasswordChanged(
    DeliveryForgotPasswordConfirmPasswordChanged event,
    Emitter<DeliveryForgotPasswordState> emit,
  ) {
    emit(state.copyWith(confirmPassword: event.confirmPassword, clearErrors: true));
  }

  void _onTogglePasswordVisibility(
    DeliveryForgotPasswordTogglePasswordVisibility event,
    Emitter<DeliveryForgotPasswordState> emit,
  ) {
    emit(state.copyWith(isPasswordVisible: !state.isPasswordVisible));
  }

  void _onToggleConfirmPasswordVisibility(
    DeliveryForgotPasswordToggleConfirmPasswordVisibility event,
    Emitter<DeliveryForgotPasswordState> emit,
  ) {
    emit(state.copyWith(isConfirmPasswordVisible: !state.isConfirmPasswordVisible));
  }

  Future<void> _onSendOtpRequested(
    DeliveryForgotPasswordSendOtpRequested event,
    Emitter<DeliveryForgotPasswordState> emit,
  ) async {
    final phoneError = service.validatePhone(state.phoneNumber);
    if (phoneError != null) {
      emit(state.copyWith(
        status: DeliveryForgotPasswordStatus.otpSendFailure,
        phoneError: phoneError,
        errorMessage: phoneError,
      ));
      return;
    }

    emit(state.copyWith(
      status: DeliveryForgotPasswordStatus.otpSending,
      clearErrors: true,
    ));

    final cleanedPhone = state.phoneNumber.replaceAll(RegExp(r'\s+'), '').replaceAll('-', '');
    final fullPhone = cleanedPhone.startsWith('+') ? cleanedPhone : '+91$cleanedPhone';

    try {
      final completer = Completer<void>();
      String? verificationId;
      String? otpErrorMsg;

      await repository.sendOtp(
        phoneNumber: fullPhone,
        onCodeSent: (verId, forceResendingToken) {
          verificationId = verId;
          if (!completer.isCompleted) completer.complete();
        },
        onVerificationFailed: (e) {
          otpErrorMsg = e.message ?? 'Verification failed';
          if (!completer.isCompleted) completer.complete();
        },
      );

      await completer.future.timeout(
        const Duration(seconds: 15),
        onTimeout: () {
          if (verificationId == null && otpErrorMsg == null) {
            otpErrorMsg = 'OTP request timed out. Please try again.';
          }
        },
      );

      if (otpErrorMsg != null) {
        emit(state.copyWith(
          status: DeliveryForgotPasswordStatus.otpSendFailure,
          errorMessage: otpErrorMsg,
        ));
      } else if (verificationId != null) {
        emit(state.copyWith(
          status: DeliveryForgotPasswordStatus.otpSent,
          verificationId: verificationId,
        ));
      } else {
        emit(state.copyWith(
          status: DeliveryForgotPasswordStatus.otpSendFailure,
          errorMessage: 'Failed to receive OTP verification ID.',
        ));
      }
    } catch (e) {
      emit(state.copyWith(
        status: DeliveryForgotPasswordStatus.otpSendFailure,
        errorMessage: e.toString().replaceAll('Exception: ', ''),
      ));
    }
  }

  Future<void> _onSubmitted(
    DeliveryForgotPasswordSubmitted event,
    Emitter<DeliveryForgotPasswordState> emit,
  ) async {
    final phoneError = service.validatePhone(state.phoneNumber);
    final otpError = service.validateOtp(state.otp);
    final passwordError = service.validatePassword(state.password);
    final confirmPasswordError =
        service.validateConfirmPassword(state.password, state.confirmPassword);

    if (phoneError != null ||
        otpError != null ||
        passwordError != null ||
        confirmPasswordError != null) {
      emit(state.copyWith(
        status: DeliveryForgotPasswordStatus.failure,
        phoneError: phoneError,
        otpError: otpError,
        passwordError: passwordError,
        confirmPasswordError: confirmPasswordError,
        errorMessage: 'Please fix validation errors.',
      ));
      return;
    }

    if (state.verificationId == null) {
      emit(state.copyWith(
        status: DeliveryForgotPasswordStatus.failure,
        errorMessage: 'Please request OTP first.',
      ));
      return;
    }

    emit(state.copyWith(
      status: DeliveryForgotPasswordStatus.submitting,
      clearErrors: true,
    ));

    final cleanedPhone = state.phoneNumber.replaceAll(RegExp(r'\s+'), '').replaceAll('-', '');
    final fullPhone = cleanedPhone.startsWith('+') ? cleanedPhone : '+91$cleanedPhone';

    try {
      await repository.verifyOtpAndUpdatePassword(
        verificationId: state.verificationId!,
        smsCode: state.otp.trim(),
        phoneNumber: fullPhone,
        newPassword: state.password.trim(),
      );

      emit(state.copyWith(
        status: DeliveryForgotPasswordStatus.success,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: DeliveryForgotPasswordStatus.failure,
        errorMessage: e.toString().replaceAll('Exception: ', ''),
      ));
    }
  }
}
