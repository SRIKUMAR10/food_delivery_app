import 'package:equatable/equatable.dart';

enum BuyerLoginStatus { initial, loading, success, failure }

class BuyerLoginState extends Equatable {
  final String phone;
  final String password;
  final bool isPasswordObscured;
  final BuyerLoginStatus status;
  final String? errorMessage;
  final String? userId;

  const BuyerLoginState({
    this.phone = '',
    this.password = '',
    this.isPasswordObscured = true,
    this.status = BuyerLoginStatus.initial,
    this.errorMessage,
    this.userId,
  });

  BuyerLoginState copyWith({
    String? phone,
    String? password,
    bool? isPasswordObscured,
    BuyerLoginStatus? status,
    String? errorMessage,
    String? userId,
  }) {
    return BuyerLoginState(
      phone: phone ?? this.phone,
      password: password ?? this.password,
      isPasswordObscured: isPasswordObscured ?? this.isPasswordObscured,
      status: status ?? this.status,
      errorMessage: errorMessage,
      userId: userId ?? this.userId,
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
      ];
}
