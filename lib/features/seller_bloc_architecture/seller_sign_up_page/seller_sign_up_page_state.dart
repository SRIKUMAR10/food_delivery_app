// ignore_for_file: lines_longer_than_80_chars

import 'package:equatable/equatable.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Step Enum – mirrors the 5 wizard screens
// ─────────────────────────────────────────────────────────────────────────────

/// Each value maps to one visible screen in the sign-up wizard.
enum SellerSignUpStep {
  /// Screen 1 – Welcome screen with "Create Account" CTA.
  welcome,

  /// Screen 2 – Personal details: name, shop name, business details.
  personalDetails,

  /// Screen 3 – Contact + password: phone, email, password, confirm.
  contactPassword,

  /// Screen 4 – OTP verification (6-digit code sent to phone).
  otpVerification,

  /// Screen 5 – Email verification sent screen.
  emailVerification,

  /// Screen 6 – Registration success.
  signUpSuccess,
}

// ─────────────────────────────────────────────────────────────────────────────
// Status Enum
// ─────────────────────────────────────────────────────────────────────────────

enum SellerSignUpStatus {
  initial,
  loading,
  otpSent,
  otpVerified,
  success,
  failure,
}

// ─────────────────────────────────────────────────────────────────────────────
// State
// ─────────────────────────────────────────────────────────────────────────────

/// Immutable, Equatable state for the seller sign-up wizard.
class SellerSignUpPageState extends Equatable {
  // ── Wizard position ────────────────────────────────────────────────────────
  final SellerSignUpStep step;
  final SellerSignUpStatus status;

  // ── Error messaging ────────────────────────────────────────────────────────
  final String? errorMessage;

  // ── Screen 2 – Personal details ────────────────────────────────────────────
  final String name;
  final String shopName;
  final String businessDetails;

  // ── Field-level validation errors (Screen 2) ───────────────────────────────
  final String? nameError;
  final String? shopNameError;
  final String? businessDetailsError;

  // ── Screen 3 – Contact & Password ──────────────────────────────────────────
  final String phone;
  final String email;
  final String password;
  final String confirmPassword;
  final bool isPasswordObscured;
  final bool isConfirmPasswordObscured;

  // ── Field-level validation errors (Screen 3) ───────────────────────────────
  final String? phoneError;
  final String? emailError;
  final String? passwordError;
  final String? confirmPasswordError;

  // ── Terms & Conditions ─────────────────────────────────────────────────────
  final bool termsAccepted;

  // ── Screen 4 – OTP ─────────────────────────────────────────────────────────
  final List<String> otpDigits; // length 6
  final int otpCountdown; // seconds remaining (starts at 25)
  final bool isOtpResendAvailable;

  // ── Field-level validation error (Screen 4) ────────────────────────────────
  final String? otpError;

  const SellerSignUpPageState({
    this.step = SellerSignUpStep.welcome,
    this.status = SellerSignUpStatus.initial,
    this.errorMessage,
    // Screen 2
    this.name = '',
    this.shopName = '',
    this.businessDetails = '',
    this.nameError,
    this.shopNameError,
    this.businessDetailsError,
    // Screen 3
    this.phone = '',
    this.email = '',
    this.password = '',
    this.confirmPassword = '',
    this.isPasswordObscured = true,
    this.isConfirmPasswordObscured = true,
    this.phoneError,
    this.emailError,
    this.passwordError,
    this.confirmPasswordError,
    this.termsAccepted = false,
    // Screen 4
    List<String>? otpDigits,
    this.otpCountdown = 25,
    this.isOtpResendAvailable = false,
    this.otpError,
  }) : otpDigits = otpDigits ?? const ['', '', '', '', '', ''];

  // ── Derived Properties ─────────────────────────────────────────────────────

  /// Joined 6-digit OTP string.
  String get otpCode => otpDigits.join();

  /// True when all 6 OTP boxes are filled.
  bool get isOtpComplete => otpDigits.every((d) => d.isNotEmpty);

  /// True when all personal detail fields are non-empty.
  bool get isPersonalDetailsValid =>
      name.trim().length >= 2 &&
      shopName.trim().length >= 2 &&
      businessDetails.trim().isNotEmpty;

  /// True when password and confirmPassword match and meet min length.
  bool get isPasswordValid =>
      password.length >= 6 && password == confirmPassword;

  /// True when the phone is in E.164 format (starts with +).
  bool get isPhoneValid => phone.trim().startsWith('+') && phone.trim().length >= 10;

  /// True when email has basic valid format.
  bool get isEmailValid =>
      RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(email.trim());

  /// True when all screen-3 fields are ready and terms accepted.
  bool get isContactPasswordValid =>
      isPhoneValid &&
      isEmailValid &&
      isPasswordValid &&
      termsAccepted;

  // ── copyWith ───────────────────────────────────────────────────────────────

  SellerSignUpPageState copyWith({
    SellerSignUpStep? step,
    SellerSignUpStatus? status,
    String? errorMessage,
    bool clearError = false,
    // Screen 2
    String? name,
    String? shopName,
    String? businessDetails,
    String? nameError,
    bool clearNameError = false,
    String? shopNameError,
    bool clearShopNameError = false,
    String? businessDetailsError,
    bool clearBusinessDetailsError = false,
    // Screen 3
    String? phone,
    String? email,
    String? password,
    String? confirmPassword,
    bool? isPasswordObscured,
    bool? isConfirmPasswordObscured,
    String? phoneError,
    bool clearPhoneError = false,
    String? emailError,
    bool clearEmailError = false,
    String? passwordError,
    bool clearPasswordError = false,
    String? confirmPasswordError,
    bool clearConfirmPasswordError = false,
    bool? termsAccepted,
    // Screen 4
    List<String>? otpDigits,
    int? otpCountdown,
    bool? isOtpResendAvailable,
    String? otpError,
    bool clearOtpError = false,
  }) {
    return SellerSignUpPageState(
      step: step ?? this.step,
      status: status ?? this.status,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      // Screen 2
      name: name ?? this.name,
      shopName: shopName ?? this.shopName,
      businessDetails: businessDetails ?? this.businessDetails,
      nameError: clearNameError ? null : (nameError ?? this.nameError),
      shopNameError: clearShopNameError ? null : (shopNameError ?? this.shopNameError),
      businessDetailsError: clearBusinessDetailsError
          ? null
          : (businessDetailsError ?? this.businessDetailsError),
      // Screen 3
      phone: phone ?? this.phone,
      email: email ?? this.email,
      password: password ?? this.password,
      confirmPassword: confirmPassword ?? this.confirmPassword,
      isPasswordObscured: isPasswordObscured ?? this.isPasswordObscured,
      isConfirmPasswordObscured:
          isConfirmPasswordObscured ?? this.isConfirmPasswordObscured,
      phoneError: clearPhoneError ? null : (phoneError ?? this.phoneError),
      emailError: clearEmailError ? null : (emailError ?? this.emailError),
      passwordError:
          clearPasswordError ? null : (passwordError ?? this.passwordError),
      confirmPasswordError: clearConfirmPasswordError
          ? null
          : (confirmPasswordError ?? this.confirmPasswordError),
      termsAccepted: termsAccepted ?? this.termsAccepted,
      // Screen 4
      otpDigits: otpDigits ?? List<String>.from(this.otpDigits),
      otpCountdown: otpCountdown ?? this.otpCountdown,
      isOtpResendAvailable: isOtpResendAvailable ?? this.isOtpResendAvailable,
      otpError: clearOtpError ? null : (otpError ?? this.otpError),
    );
  }

  // ── Equatable ──────────────────────────────────────────────────────────────

  @override
  List<Object?> get props => [
        step,
        status,
        errorMessage,
        name,
        shopName,
        businessDetails,
        nameError,
        shopNameError,
        businessDetailsError,
        phone,
        email,
        password,
        confirmPassword,
        isPasswordObscured,
        isConfirmPasswordObscured,
        phoneError,
        emailError,
        passwordError,
        confirmPasswordError,
        termsAccepted,
        otpDigits,
        otpCountdown,
        isOtpResendAvailable,
        otpError,
      ];

  @override
  String toString() =>
      'SellerSignUpPageState(step: $step, status: $status, '
      'name: $name, phone: $phone, email: $email, '
      'otpComplete: $isOtpComplete, termsAccepted: $termsAccepted)';
}
