import 'package:equatable/equatable.dart';

enum BuyerSignUpStatus { initial, loading, otpSent, failure }

class BuyerSignUpState extends Equatable {
  final BuyerSignUpStatus status;
  final String? errorMessage;
  final String? fullName;
  final String? email;
  final String? mobileNumber;
  final String? password;
  final String? verificationId;

  const BuyerSignUpState({
    this.status = BuyerSignUpStatus.initial,
    this.errorMessage,
    this.fullName,
    this.email,
    this.mobileNumber,
    this.password,
    this.verificationId,
  });

  BuyerSignUpState copyWith({
    BuyerSignUpStatus? status,
    String? errorMessage,
    String? fullName,
    String? email,
    String? mobileNumber,
    String? password,
    String? verificationId,
  }) {
    return BuyerSignUpState(
      status: status ?? this.status,
      errorMessage: errorMessage,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      mobileNumber: mobileNumber ?? this.mobileNumber,
      password: password ?? this.password,
      verificationId: verificationId ?? this.verificationId,
    );
  }

  @override
  List<Object?> get props => [
        status,
        errorMessage,
        fullName,
        email,
        mobileNumber,
        password,
        verificationId,
      ];
}
