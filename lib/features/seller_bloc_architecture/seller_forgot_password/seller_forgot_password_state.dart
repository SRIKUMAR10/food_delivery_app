import 'package:equatable/equatable.dart';

enum SellerForgotPasswordStatus {
  initial,
  otpSending,
  otpSent,
  otpSendFailure,
  submitting,
  success,
  failure,
}

class SellerForgotPasswordState extends Equatable {
  final SellerForgotPasswordStatus status;
  final String phoneNumber;
  final String otp;
  final String password;
  final String confirmPassword;
  final String? verificationId;
  final bool isPasswordVisible;
  final bool isConfirmPasswordVisible;
  final String? phoneError;
  final String? otpError;
  final String? passwordError;
  final String? confirmPasswordError;
  final String? errorMessage;

  const SellerForgotPasswordState({
    this.status = SellerForgotPasswordStatus.initial,
    this.phoneNumber = '',
    this.otp = '',
    this.password = '',
    this.confirmPassword = '',
    this.verificationId,
    this.isPasswordVisible = false,
    this.isConfirmPasswordVisible = false,
    this.phoneError,
    this.otpError,
    this.passwordError,
    this.confirmPasswordError,
    this.errorMessage,
  });

  SellerForgotPasswordState copyWith({
    SellerForgotPasswordStatus? status,
    String? phoneNumber,
    String? otp,
    String? password,
    String? confirmPassword,
    String? verificationId,
    bool? isPasswordVisible,
    bool? isConfirmPasswordVisible,
    String? phoneError,
    String? otpError,
    String? passwordError,
    String? confirmPasswordError,
    String? errorMessage,
    bool clearErrors = false,
  }) {
    return SellerForgotPasswordState(
      status: status ?? this.status,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      otp: otp ?? this.otp,
      password: password ?? this.password,
      confirmPassword: confirmPassword ?? this.confirmPassword,
      verificationId: verificationId ?? this.verificationId,
      isPasswordVisible: isPasswordVisible ?? this.isPasswordVisible,
      isConfirmPasswordVisible:
          isConfirmPasswordVisible ?? this.isConfirmPasswordVisible,
      phoneError: clearErrors ? null : (phoneError ?? this.phoneError),
      otpError: clearErrors ? null : (otpError ?? this.otpError),
      passwordError: clearErrors ? null : (passwordError ?? this.passwordError),
      confirmPasswordError: clearErrors
          ? null
          : (confirmPasswordError ?? this.confirmPasswordError),
      errorMessage: clearErrors ? null : (errorMessage ?? this.errorMessage),
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
        isPasswordVisible,
        isConfirmPasswordVisible,
        phoneError,
        otpError,
        passwordError,
        confirmPasswordError,
        errorMessage,
      ];
}
