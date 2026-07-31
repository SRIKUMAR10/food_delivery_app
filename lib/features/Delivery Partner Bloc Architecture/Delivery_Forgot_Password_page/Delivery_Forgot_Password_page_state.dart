import 'package:equatable/equatable.dart';

enum DeliveryForgotPasswordStatus { initial, loading, success, failure }

class DeliveryForgotPasswordState extends Equatable {
  final DeliveryForgotPasswordStatus status;
  final String email;
  final String? errorMessage;

  const DeliveryForgotPasswordState({
    this.status = DeliveryForgotPasswordStatus.initial,
    this.email = '',
    this.errorMessage,
  });

  DeliveryForgotPasswordState copyWith({
    DeliveryForgotPasswordStatus? status,
    String? email,
    String? errorMessage,
    bool clearError = false,
  }) {
    return DeliveryForgotPasswordState(
      status: status ?? this.status,
      email: email ?? this.email,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props => [status, email, errorMessage];
}
