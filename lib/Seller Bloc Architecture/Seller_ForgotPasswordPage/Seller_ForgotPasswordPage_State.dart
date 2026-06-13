import 'package:equatable/equatable.dart';

/// Represents the current status of the forgot password process.
enum SellerForgotPasswordStatus { initial, loading, success, failure }

/// Represents the state of the Seller ForgotPasswordPage.
class SellerForgotPasswordState extends Equatable {
  final String email;
  final SellerForgotPasswordStatus status;
  final String? errorMessage;

  const SellerForgotPasswordState({
    this.email = '',
    this.status = SellerForgotPasswordStatus.initial,
    this.errorMessage,
  });

  /// Creates a copy of this state but with the given fields replaced with the new values.
  SellerForgotPasswordState copyWith({
    String? email,
    SellerForgotPasswordStatus? status,
    String? errorMessage,
  }) {
    return SellerForgotPasswordState(
      email: email ?? this.email,
      status: status ?? this.status,
      // Clear error message if status is updated to something other than failure
      errorMessage: (status != null && status != SellerForgotPasswordStatus.failure)
          ? null
          : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props => [email, status, errorMessage];
}
