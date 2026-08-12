import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'buyer_forgot_password_page_event.dart';
import 'buyer_forgot_password_page_repository.dart';
import 'buyer_forgot_password_page_service.dart';
import 'buyer_forgot_password_page_state.dart';

class BuyerForgotPasswordBloc
    extends Bloc<BuyerForgotPasswordEvent, BuyerForgotPasswordState> {
  final BuyerForgotPasswordRepositoryBase repository;
  final BuyerForgotPasswordServiceBase service;

  BuyerForgotPasswordBloc({
    BuyerForgotPasswordRepositoryBase? repository,
    BuyerForgotPasswordServiceBase? service,
  })  : repository = repository ?? BuyerForgotPasswordRepository(),
        service = service ?? BuyerForgotPasswordService(),
        super(const BuyerForgotPasswordState()) {
    on<BuyerForgotPasswordPhoneChanged>(_onPhoneChanged);
    on<BuyerForgotPasswordOtpChanged>(_onOtpChanged);
    on<BuyerForgotPasswordPasswordChanged>(_onPasswordChanged);
    on<BuyerForgotPasswordConfirmPasswordChanged>(_onConfirmPasswordChanged);
    on<BuyerForgotPasswordTogglePasswordVisibility>(_onTogglePasswordVisibility);
    on<BuyerForgotPasswordToggleConfirmPasswordVisibility>(_onToggleConfirmPasswordVisibility);
    on<BuyerForgotPasswordSendOtpRequested>(_onSendOtpRequested);
    on<BuyerForgotPasswordSubmitted>(_onSubmitted);
  }

  void _onPhoneChanged(
    BuyerForgotPasswordPhoneChanged event,
    Emitter<BuyerForgotPasswordState> emit,
  ) {
    emit(state.copyWith(phoneNumber: event.phone, clearErrors: true));
  }

  void _onOtpChanged(
    BuyerForgotPasswordOtpChanged event,
    Emitter<BuyerForgotPasswordState> emit,
  ) {
    emit(state.copyWith(otp: event.otp, clearErrors: true));
  }

  void _onPasswordChanged(
    BuyerForgotPasswordPasswordChanged event,
    Emitter<BuyerForgotPasswordState> emit,
  ) {
    emit(state.copyWith(password: event.password, clearErrors: true));
  }

  void _onConfirmPasswordChanged(
    BuyerForgotPasswordConfirmPasswordChanged event,
    Emitter<BuyerForgotPasswordState> emit,
  ) {
    emit(state.copyWith(confirmPassword: event.confirmPassword, clearErrors: true));
  }

  void _onTogglePasswordVisibility(
    BuyerForgotPasswordTogglePasswordVisibility event,
    Emitter<BuyerForgotPasswordState> emit,
  ) {
    emit(state.copyWith(isPasswordVisible: !state.isPasswordVisible));
  }

  void _onToggleConfirmPasswordVisibility(
    BuyerForgotPasswordToggleConfirmPasswordVisibility event,
    Emitter<BuyerForgotPasswordState> emit,
  ) {
    emit(state.copyWith(isConfirmPasswordVisible: !state.isConfirmPasswordVisible));
  }

  Future<void> _onSendOtpRequested(
    BuyerForgotPasswordSendOtpRequested event,
    Emitter<BuyerForgotPasswordState> emit,
  ) async {
    final phoneError = service.validatePhone(state.phoneNumber);
    if (phoneError != null) {
      emit(state.copyWith(
        status: BuyerForgotPasswordStatus.otpSendFailure,
        phoneError: phoneError,
        errorMessage: phoneError,
      ));
      return;
    }

    emit(state.copyWith(
      status: BuyerForgotPasswordStatus.otpSending,
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
          status: BuyerForgotPasswordStatus.otpSendFailure,
          errorMessage: otpErrorMsg,
        ));
      } else if (verificationId != null) {
        emit(state.copyWith(
          status: BuyerForgotPasswordStatus.otpSent,
          verificationId: verificationId,
        ));
      } else {
        emit(state.copyWith(
          status: BuyerForgotPasswordStatus.otpSendFailure,
          errorMessage: 'Failed to receive OTP verification ID.',
        ));
      }
    } catch (e) {
      emit(state.copyWith(
        status: BuyerForgotPasswordStatus.otpSendFailure,
        errorMessage: e.toString().replaceAll('Exception: ', ''),
      ));
    }
  }

  Future<void> _onSubmitted(
    BuyerForgotPasswordSubmitted event,
    Emitter<BuyerForgotPasswordState> emit,
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
        status: BuyerForgotPasswordStatus.failure,
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
        status: BuyerForgotPasswordStatus.failure,
        errorMessage: 'Please request OTP first.',
      ));
      return;
    }

    emit(state.copyWith(
      status: BuyerForgotPasswordStatus.submitting,
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
        status: BuyerForgotPasswordStatus.success,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: BuyerForgotPasswordStatus.failure,
        errorMessage: e.toString().replaceAll('Exception: ', ''),
      ));
    }
  }
}

