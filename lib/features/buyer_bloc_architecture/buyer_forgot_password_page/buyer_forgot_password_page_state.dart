import 'package:equatable/equatable.dart';

enum BuyerForgotPasswordStatus {
  initial,
  otpSending,
  otpSent,
  otpSendFailure,
  submitting,
  success,
  failure
}

class BuyerForgotPasswordState extends Equatable {
  final BuyerForgotPasswordStatus status;
  final String phoneNumber;
  final String otp;
  final String password;
  final String confirmPassword;
  final String? verificationId;
  final String? phoneError;
  final String? otpError;
  final String? passwordError;
  final String? confirmPasswordError;
  final String? errorMessage;
  final bool isPasswordVisible;
  final bool isConfirmPasswordVisible;

  const BuyerForgotPasswordState({
    this.status = BuyerForgotPasswordStatus.initial,
    this.phoneNumber = '',
    this.otp = '',
    this.password = '',
    this.confirmPassword = '',
    this.verificationId,
    this.phoneError,
    this.otpError,
    this.passwordError,
    this.confirmPasswordError,
    this.errorMessage,
    this.isPasswordVisible = false,
    this.isConfirmPasswordVisible = false,
  });

  BuyerForgotPasswordState copyWith({
    BuyerForgotPasswordStatus? status,
    String? phoneNumber,
    String? otp,
    String? password,
    String? confirmPassword,
    String? verificationId,
    String? phoneError,
    String? otpError,
    String? passwordError,
    String? confirmPasswordError,
    String? errorMessage,
    bool? isPasswordVisible,
    bool? isConfirmPasswordVisible,
    bool clearErrors = false,
  }) {
    return BuyerForgotPasswordState(
      status: status ?? this.status,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      otp: otp ?? this.otp,
      password: password ?? this.password,
      confirmPassword: confirmPassword ?? this.confirmPassword,
      verificationId: verificationId ?? this.verificationId,
      phoneError: clearErrors ? null : (phoneError ?? this.phoneError),
      otpError: clearErrors ? null : (otpError ?? this.otpError),
      passwordError: clearErrors ? null : (passwordError ?? this.passwordError),
      confirmPasswordError: clearErrors ? null : (confirmPasswordError ?? this.confirmPasswordError),
      errorMessage: clearErrors ? null : (errorMessage ?? this.errorMessage),
      isPasswordVisible: isPasswordVisible ?? this.isPasswordVisible,
      isConfirmPasswordVisible: isConfirmPasswordVisible ?? this.isConfirmPasswordVisible,
    );
  }

  @override
  List<Object?> get props => [
        status,
        phoneNumber,
        otp,
        password,
        confirmPassword,
        verificationId,
        phoneError,
        otpError,
        passwordError,
        confirmPasswordError,
        errorMessage,
        isPasswordVisible,
        isConfirmPasswordVisible,
      ];
}

