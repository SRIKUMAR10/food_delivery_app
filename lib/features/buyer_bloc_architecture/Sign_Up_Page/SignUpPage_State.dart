import 'package:equatable/equatable.dart';

enum SignUpStatus { initial, loading, success, failure }

class SignUpState extends Equatable {
  final SignUpStatus status;
  final String? errorMessage;
  final bool isPasswordObscured;

  const SignUpState({
    this.status = SignUpStatus.initial,
    this.errorMessage,
    this.isPasswordObscured = true,
  });

  SignUpState copyWith({
    SignUpStatus? status,
    String? errorMessage,
    bool? isPasswordObscured,
  }) {
    return SignUpState(
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
      isPasswordObscured: isPasswordObscured ?? this.isPasswordObscured,
    );
  }

  @override
  List<Object?> get props => [status, errorMessage, isPasswordObscured];
}
