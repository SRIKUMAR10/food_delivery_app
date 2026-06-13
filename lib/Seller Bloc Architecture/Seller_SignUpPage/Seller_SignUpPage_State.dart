import 'package:equatable/equatable.dart';

/// Represents the current status of the sign-up process.
enum SellerSignUpStatus { initial, loading, success, failure }

/// Represents the state of the Seller SignUpPage.
class SellerSignUpState extends Equatable {
  final String name;
  final String email;
  final String password;
  final bool obscurePassword;
  final SellerSignUpStatus status;
  final String? errorMessage;

  const SellerSignUpState({
    this.name = '',
    this.email = '',
    this.password = '',
    this.obscurePassword = true,
    this.status = SellerSignUpStatus.initial,
    this.errorMessage,
  });

  /// Creates a copy of this state but with the given fields replaced with the new values.
  SellerSignUpState copyWith({
    String? name,
    String? email,
    String? password,
    bool? obscurePassword,
    SellerSignUpStatus? status,
    String? errorMessage,
  }) {
    return SellerSignUpState(
      name: name ?? this.name,
      email: email ?? this.email,
      password: password ?? this.password,
      obscurePassword: obscurePassword ?? this.obscurePassword,
      status: status ?? this.status,
      // Clear error message if status is updated to something other than failure
      errorMessage: (status != null && status != SellerSignUpStatus.failure)
          ? null
          : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props => [name, email, password, obscurePassword, status, errorMessage];
}
