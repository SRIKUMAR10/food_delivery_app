import 'package:equatable/equatable.dart';

enum BuyerLoginStatus { initial, loading, success, failure }

class BuyerAuthProfileStatus extends Equatable {
  final bool isKycCompleted;
  final String fullName;
  final String email;
  final String phone;
  final String? imageUrl;
  final bool isPhoneVerified;

  const BuyerAuthProfileStatus({
    this.isKycCompleted = false,
    this.fullName = '',
    this.email = '',
    this.phone = '',
    this.imageUrl,
    this.isPhoneVerified = false,
  });

  @override
  List<Object?> get props => [
        isKycCompleted,
        fullName,
        email,
        phone,
        imageUrl,
        isPhoneVerified,
      ];
}

class BuyerLoginState extends Equatable {
  final String phone;
  final String password;
  final bool isPasswordObscured;
  final BuyerLoginStatus status;
  final String? errorMessage;
  final String? userId;
  final bool isKycCompleted;
  final String? fullName;
  final String? email;
  final String? avatarUrl;
  final bool isPhoneVerified;

  const BuyerLoginState({
    this.phone = '',
    this.password = '',
    this.isPasswordObscured = true,
    this.status = BuyerLoginStatus.initial,
    this.errorMessage,
    this.userId,
    this.isKycCompleted = false,
    this.fullName,
    this.email,
    this.avatarUrl,
    this.isPhoneVerified = false,
  });

  BuyerLoginState copyWith({
    String? phone,
    String? password,
    bool? isPasswordObscured,
    BuyerLoginStatus? status,
    String? errorMessage,
    String? userId,
    bool? isKycCompleted,
    String? fullName,
    String? email,
    String? avatarUrl,
    bool? isPhoneVerified,
  }) {
    return BuyerLoginState(
      phone: phone ?? this.phone,
      password: password ?? this.password,
      isPasswordObscured: isPasswordObscured ?? this.isPasswordObscured,
      status: status ?? this.status,
      errorMessage: errorMessage,
      userId: userId ?? this.userId,
      isKycCompleted: isKycCompleted ?? this.isKycCompleted,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      isPhoneVerified: isPhoneVerified ?? this.isPhoneVerified,
    );
  }

  @override
  List<Object?> get props => [
        phone,
        password,
        isPasswordObscured,
        status,
        errorMessage,
        userId,
        isKycCompleted,
        fullName,
        email,
        avatarUrl,
        isPhoneVerified,
      ];
}
