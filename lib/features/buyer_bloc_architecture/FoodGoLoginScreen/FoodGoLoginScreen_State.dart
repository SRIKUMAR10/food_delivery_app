import 'package:equatable/equatable.dart';

/// Represents the current status of the login process.
enum LoginStatus { initial, loading, success, failure }

/// Represents the state of the FoodGoLoginScreen.
class FoodGoLoginState extends Equatable {
  final String email;
  final String password;
  final bool obscurePassword;
  final LoginStatus status;
  final String? errorMessage;

  const FoodGoLoginState({
    this.email = '',
    this.password = '',
    this.obscurePassword = true,
    this.status = LoginStatus.initial,
    this.errorMessage,
  });

  /// Creates a copy of this state but with the given fields replaced with the new values.
  FoodGoLoginState copyWith({
    String? email,
    String? password,
    bool? obscurePassword,
    LoginStatus? status,
    String? errorMessage,
  }) {
    return FoodGoLoginState(
      email: email ?? this.email,
      password: password ?? this.password,
      obscurePassword: obscurePassword ?? this.obscurePassword,
      status: status ?? this.status,
      // If a new status is provided and it's not failure, we clear the error message.
      errorMessage: (status != null && status != LoginStatus.failure) 
          ? null 
          : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props => [
        email,
        password,
        obscurePassword,
        status,
        errorMessage,
      ];
}
