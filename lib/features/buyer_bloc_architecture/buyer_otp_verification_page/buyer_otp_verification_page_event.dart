import 'package:equatable/equatable.dart';

abstract class BuyerOtpEvent extends Equatable {
  const BuyerOtpEvent();

  @override
  List<Object?> get props => [];
}

class BuyerVerifyOtpSubmitted extends BuyerOtpEvent {
  final String fullName;
  final String email;
  final String mobileNumber;
  final String password;
  final String otpCode;
  final String verificationId;

  const BuyerVerifyOtpSubmitted({
    required this.fullName,
    required this.email,
    required this.mobileNumber,
    required this.password,
    required this.otpCode,
    this.verificationId = '',
  });

  @override
  List<Object?> get props => [
        fullName,
        email,
        mobileNumber,
        password,
        otpCode,
        verificationId,
      ];
}
