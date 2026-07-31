import 'package:equatable/equatable.dart';

enum DeliverySignUpStatus { initial, loading, otpSent, success, failure }

class DeliverySignUpPageState extends Equatable {
  final DeliverySignUpStatus status;
  final String? errorMessage;
  final String? verificationId;

  final String name;
  final String phone;
  final String email;
  final String password;
  final String confirmPassword;
  final bool isPasswordObscured;
  final bool isConfirmPasswordObscured;
  final bool termsAccepted;

  final String? nameError;
  final String? phoneError;
  final String? emailError;
  final String? passwordError;
  final String? confirmPasswordError;

  final bool isSignedUp;

  const DeliverySignUpPageState({
    this.status = DeliverySignUpStatus.initial,
    this.errorMessage,
    this.verificationId,
    this.name = '',
    this.phone = '',
    this.email = '',
    this.password = '',
    this.confirmPassword = '',
    this.isPasswordObscured = true,
    this.isConfirmPasswordObscured = true,
    this.termsAccepted = false,
    this.nameError,
    this.phoneError,
    this.emailError,
    this.passwordError,
    this.confirmPasswordError,
    this.isSignedUp = false,
  });

  bool get isPhoneValid =>
      phone.replaceAll(RegExp(r'\D'), '').length >= 10;
  bool get isEmailValid =>
      RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email.trim());

  DeliverySignUpPageState copyWith({
    DeliverySignUpStatus? status,
    String? errorMessage,
    bool clearError = false,
    String? verificationId,
    String? name,
    String? phone,
    String? email,
    String? password,
    String? confirmPassword,
    bool? isPasswordObscured,
    bool? isConfirmPasswordObscured,
    bool? termsAccepted,
    String? nameError,
    bool clearNameError = false,
    String? phoneError,
    bool clearPhoneError = false,
    String? emailError,
    bool clearEmailError = false,
    String? passwordError,
    bool clearPasswordError = false,
    String? confirmPasswordError,
    bool clearConfirmPasswordError = false,
    bool? isSignedUp,
  }) {
    return DeliverySignUpPageState(
      status: status ?? this.status,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      verificationId: verificationId ?? this.verificationId,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      password: password ?? this.password,
      confirmPassword: confirmPassword ?? this.confirmPassword,
      isPasswordObscured: isPasswordObscured ?? this.isPasswordObscured,
      isConfirmPasswordObscured:
          isConfirmPasswordObscured ?? this.isConfirmPasswordObscured,
      termsAccepted: termsAccepted ?? this.termsAccepted,
      nameError: clearNameError ? null : (nameError ?? this.nameError),
      phoneError: clearPhoneError ? null : (phoneError ?? this.phoneError),
      emailError: clearEmailError ? null : (emailError ?? this.emailError),
      passwordError:
          clearPasswordError ? null : (passwordError ?? this.passwordError),
      confirmPasswordError: clearConfirmPasswordError
          ? null
          : (confirmPasswordError ?? this.confirmPasswordError),
      isSignedUp: isSignedUp ?? this.isSignedUp,
    );
  }

  @override
  List<Object?> get props => [
        status,
        errorMessage,
        verificationId,
        name,
        phone,
        email,
        password,
        confirmPassword,
        isPasswordObscured,
        isConfirmPasswordObscured,
        termsAccepted,
        nameError,
        phoneError,
        emailError,
        passwordError,
        confirmPasswordError,
        isSignedUp,
      ];
}
