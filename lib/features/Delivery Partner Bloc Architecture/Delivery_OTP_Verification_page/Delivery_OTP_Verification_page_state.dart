import 'package:equatable/equatable.dart';

enum DeliveryOtpStatus { initial, loading, success, failure }

class DeliveryOtpVerificationState extends Equatable {
  final DeliveryOtpStatus status;
  final String otp;
  final String verificationId;
  final String name;
  final String phone;
  final String email;
  final String password;
  final int resendSeconds;
  final bool isResendEnabled;
  final String? errorMessage;
  final String? otpError;

  const DeliveryOtpVerificationState({
    this.status = DeliveryOtpStatus.initial,
    this.otp = '',
    this.verificationId = '',
    this.name = '',
    this.phone = '',
    this.email = '',
    this.password = '',
    this.resendSeconds = 30,
    this.isResendEnabled = false,
    this.errorMessage,
    this.otpError,
  });

  bool get isOtpValid => otp.trim().length == 6;

  DeliveryOtpVerificationState copyWith({
    DeliveryOtpStatus? status,
    String? otp,
    String? verificationId,
    String? name,
    String? phone,
    String? email,
    String? password,
    int? resendSeconds,
    bool? isResendEnabled,
    String? errorMessage,
    bool clearError = false,
    String? otpError,
    bool clearOtpError = false,
    bool clearPassword = false,
    bool clearOtp = false,
  }) {
    return DeliveryOtpVerificationState(
      status: status ?? this.status,
      otp: clearOtp ? '' : (otp ?? this.otp),
      verificationId: verificationId ?? this.verificationId,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      password: clearPassword ? '' : (password ?? this.password),
      resendSeconds: resendSeconds ?? this.resendSeconds,
      isResendEnabled: isResendEnabled ?? this.isResendEnabled,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      otpError: clearOtpError ? null : (otpError ?? this.otpError),
    );
  }

  @override
  List<Object?> get props => [
        status,
        otp,
        verificationId,
        name,
        phone,
        email,
        password,
        resendSeconds,
        isResendEnabled,
        errorMessage,
        otpError,
      ];
}
