import 'package:equatable/equatable.dart';

enum SellerForgotPasswordStatus { initial, loading, success, failure }

class SellerForgotPasswordState extends Equatable {
  final SellerForgotPasswordStatus status;
  final String email;
  final String errorMessage;

  const SellerForgotPasswordState({
    this.status = SellerForgotPasswordStatus.initial,
    this.email = '',
    this.errorMessage = '',
  });

  SellerForgotPasswordState copyWith({
    SellerForgotPasswordStatus? status,
    String? email,
    String? errorMessage,
  }) {
    return SellerForgotPasswordState(
      status: status ?? this.status,
      email: email ?? this.email,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object> get props => [status, email, errorMessage];
}
