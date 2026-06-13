import 'package:equatable/equatable.dart';

/// Represents the current status of the login process.
enum SellerLoginStatus { initial, loading, success, failure }

/// Represents the state of the Seller LoginScreen.
class SellerLoginState extends Equatable {
  final String email;
  final String password;
  final bool obscurePassword;
  final SellerLoginStatus status;
  final String? errorMessage;

  const SellerLoginState({
    this.email = '',
    this.password = '',
    this.obscurePassword = true,
    this.status = SellerLoginStatus.initial,
    this.errorMessage,
  });

  /// Creates a copy of this state but with the given fields replaced with the new values.
  SellerLoginState copyWith({
    String? email,
    String? password,
    bool? obscurePassword,
    SellerLoginStatus? status,
    String? errorMessage,
  }) {
    return SellerLoginState(
      email: email ?? this.email,
      password: password ?? this.password,
      obscurePassword: obscurePassword ?? this.obscurePassword,
      status: status ?? this.status,
      // Clear error message if status is updated to something other than failure
      errorMessage: (status != null && status != SellerLoginStatus.failure)
          ? null
          : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props => [email, password, obscurePassword, status, errorMessage];
}
