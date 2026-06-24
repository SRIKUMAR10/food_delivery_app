import 'package:equatable/equatable.dart';

/// Represents the current status of the forgot password process.
enum ForgotPasswordStatus { initial, loading, success, failure }

/// Represents the state of the ForgotPasswordPage.
class ForgotPasswordState extends Equatable {
  final String email;
  final ForgotPasswordStatus status;
  final String? errorMessage;

  const ForgotPasswordState({
    this.email = '',
    this.status = ForgotPasswordStatus.initial,
    this.errorMessage,
  });

  /// Creates a copy of this state but with the given fields replaced with the new values.
  ForgotPasswordState copyWith({
    String? email,
    ForgotPasswordStatus? status,
    String? errorMessage,
  }) {
    return ForgotPasswordState(
      email: email ?? this.email,
      status: status ?? this.status,
      // Clear error message if status is updated to something other than failure
      errorMessage: (status != null && status != ForgotPasswordStatus.failure)
          ? null
          : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props => [email, status, errorMessage];
}
