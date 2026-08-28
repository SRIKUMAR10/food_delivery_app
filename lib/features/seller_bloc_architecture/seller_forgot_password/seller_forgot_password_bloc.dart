import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:food_delivery_app/core/utils/app_exception_formatter.dart';
import 'package:food_delivery_app/repositories/seller_repository.dart';
import 'seller_forgot_password_event.dart';
import 'seller_forgot_password_state.dart';

class SellerForgotPasswordBloc
    extends Bloc<SellerForgotPasswordEvent, SellerForgotPasswordState> {
  final SellerRepository _authRepository;

  SellerForgotPasswordBloc({required SellerRepository authRepository})
      : _authRepository = authRepository,
        super(const SellerForgotPasswordState()) {
    on<SellerForgotPasswordPhoneChanged>(_onPhoneChanged);
    on<SellerForgotPasswordOtpChanged>(_onOtpChanged);
    on<SellerForgotPasswordPasswordChanged>(_onPasswordChanged);
    on<SellerForgotPasswordConfirmPasswordChanged>(_onConfirmPasswordChanged);
    on<SellerForgotPasswordTogglePasswordVisibility>(_onTogglePasswordVisibility);
    on<SellerForgotPasswordToggleConfirmPasswordVisibility>(_onToggleConfirmPasswordVisibility);
    on<SellerForgotPasswordSendOtpRequested>(_onSendOtpRequested);
    on<SellerForgotPasswordSubmitted>(_onSubmitted);
  }

  void _onPhoneChanged(
    SellerForgotPasswordPhoneChanged event,
    Emitter<SellerForgotPasswordState> emit,
  ) {
    emit(state.copyWith(phoneNumber: event.phone, clearErrors: true));
  }

  void _onOtpChanged(
    SellerForgotPasswordOtpChanged event,
    Emitter<SellerForgotPasswordState> emit,
  ) {
    emit(state.copyWith(otp: event.otp, clearErrors: true));
  }

  void _onPasswordChanged(
    SellerForgotPasswordPasswordChanged event,
    Emitter<SellerForgotPasswordState> emit,
  ) {
    emit(state.copyWith(password: event.password, clearErrors: true));
  }

  void _onConfirmPasswordChanged(
    SellerForgotPasswordConfirmPasswordChanged event,
    Emitter<SellerForgotPasswordState> emit,
  ) {
    emit(state.copyWith(confirmPassword: event.confirmPassword, clearErrors: true));
  }

  void _onTogglePasswordVisibility(
    SellerForgotPasswordTogglePasswordVisibility event,
    Emitter<SellerForgotPasswordState> emit,
  ) {
    emit(state.copyWith(isPasswordVisible: !state.isPasswordVisible));
  }

  void _onToggleConfirmPasswordVisibility(
    SellerForgotPasswordToggleConfirmPasswordVisibility event,
    Emitter<SellerForgotPasswordState> emit,
  ) {
    emit(state.copyWith(isConfirmPasswordVisible: !state.isConfirmPasswordVisible));
  }

  String? _validatePhone(String phone) {
    final cleaned = phone.replaceAll(RegExp(r'\s+'), '').replaceAll('-', '');
    final digits = cleaned.replaceAll(RegExp(r'\D'), '');
    if (cleaned.isEmpty) {
      return 'Please enter your mobile number';
    }
    if (digits.length < 10) {
      return 'Please enter a valid 10-digit mobile number';
    }
    return null;
  }

  String? _validateOtp(String otp) {
    final clean = otp.trim();
    if (clean.isEmpty) {
      return 'Please enter the 6-digit OTP code';
    }
    if (clean.length != 6 || int.tryParse(clean) == null) {
      return 'OTP must be exactly 6 digits';
    }
    return null;
  }

  String? _validatePassword(String password) {
    final clean = password.trim();
    if (clean.isEmpty) {
      return 'Please enter a new password';
    }
    if (clean.length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }

  String? _validateConfirmPassword(String password, String confirmPassword) {
    if (confirmPassword.trim().isEmpty) {
      return 'Please confirm your new password';
    }
    if (password.trim() != confirmPassword.trim()) {
      return 'Passwords do not match';
    }
    return null;
  }

  Future<void> _onSendOtpRequested(
    SellerForgotPasswordSendOtpRequested event,
    Emitter<SellerForgotPasswordState> emit,
  ) async {
    final phoneError = _validatePhone(state.phoneNumber);
    if (phoneError != null) {
      emit(state.copyWith(
        status: SellerForgotPasswordStatus.otpSendFailure,
        phoneError: phoneError,
        errorMessage: phoneError,
      ));
      return;
    }

    emit(state.copyWith(
      status: SellerForgotPasswordStatus.otpSending,
      clearErrors: true,
    ));

    final cleanedPhone =
        state.phoneNumber.replaceAll(RegExp(r'\s+'), '').replaceAll('-', '');
    final fullPhone =
        cleanedPhone.startsWith('+') ? cleanedPhone : '+91$cleanedPhone';

    try {
      final verificationId = await _authRepository.sendOtp(fullPhone);
      emit(state.copyWith(
        status: SellerForgotPasswordStatus.otpSent,
        verificationId: verificationId,
      ));
    } catch (e) {
      final errorMsg = AppExceptionFormatter.toUserFriendlyMessage(e);
      emit(state.copyWith(
        status: SellerForgotPasswordStatus.otpSendFailure,
        errorMessage: errorMsg,
      ));
    }
  }

  Future<void> _onSubmitted(
    SellerForgotPasswordSubmitted event,
    Emitter<SellerForgotPasswordState> emit,
  ) async {
    final phoneError = _validatePhone(state.phoneNumber);
    final otpError = _validateOtp(state.otp);
    final passwordError = _validatePassword(state.password);
    final confirmPasswordError =
        _validateConfirmPassword(state.password, state.confirmPassword);

    if (phoneError != null ||
        otpError != null ||
        passwordError != null ||
        confirmPasswordError != null) {
      emit(state.copyWith(
        status: SellerForgotPasswordStatus.failure,
        phoneError: phoneError,
        otpError: otpError,
        passwordError: passwordError,
        confirmPasswordError: confirmPasswordError,
        errorMessage: phoneError ?? otpError ?? passwordError ?? confirmPasswordError,
      ));
      return;
    }

    if (state.verificationId == null) {
      emit(state.copyWith(
        status: SellerForgotPasswordStatus.failure,
        errorMessage: 'Please request OTP first',
      ));
      return;
    }

    emit(state.copyWith(
      status: SellerForgotPasswordStatus.submitting,
      clearErrors: true,
    ));

    final cleanedPhone =
        state.phoneNumber.replaceAll(RegExp(r'\s+'), '').replaceAll('-', '');
    final fullPhone =
        cleanedPhone.startsWith('+') ? cleanedPhone : '+91$cleanedPhone';

    try {
      await _authRepository.resetPasswordWithPhoneOtp(
        verificationId: state.verificationId!,
        smsCode: state.otp.trim(),
        phoneNumber: fullPhone,
        newPassword: state.password.trim(),
      );

      emit(state.copyWith(
        status: SellerForgotPasswordStatus.success,
      ));
    } catch (e) {
      final errorMsg = AppExceptionFormatter.toUserFriendlyMessage(e);
      emit(state.copyWith(
        status: SellerForgotPasswordStatus.failure,
        errorMessage: errorMsg,
      ));
    }
  }
}
