import 'package:equatable/equatable.dart';

/// ─────────────────────────────────────────────────────────────────────────────
/// Seller Login Page Flow Steps (multi-step wizard)
/// ─────────────────────────────────────────────────────────────────────────────
enum SellerLoginStep {
  /// Screen 1 – Standard login (email + password combined)
  loginForm,

  /// Screen 2 – Enter Email / Phone only
  enterEmailPhone,

  /// Screen 3 – Enter Password (after email step)
  enterPassword,

  /// Screen 4 – Email OTP Verification
  otpVerification,

  /// Screen 5 – Login Successful
  loginSuccess,

  /// Screen 6 – Forgot Password (enter email)
  forgotPassword,

  /// Screen 7 – Forgot Password Success (link sent)
  forgotPasswordSuccess,
}

/// ─────────────────────────────────────────────────────────────────────────────
/// Request / async status
/// ─────────────────────────────────────────────────────────────────────────────
enum SellerLoginStatus {
  initial,
  loading,
  success,
  failure,
  otpSent,
  otpVerified,
  passwordResetSent,
}

/// ─────────────────────────────────────────────────────────────────────────────
/// SellerLoginPageState
/// Immutable, Equatable – holds everything needed for all screens.
/// ─────────────────────────────────────────────────────────────────────────────
class SellerLoginPageState extends Equatable {
  // ── Current wizard step ────────────────────────────────────────────────────
  final SellerLoginStep step;

  // ── Async status + error ───────────────────────────────────────────────────
  final SellerLoginStatus status;
  final String? errorMessage;

  // ── Screen 1/2 – Primary credentials ──────────────────────────────────────
  final String emailOrPhone;
  final String password;
  final bool isPasswordObscured;

  // ── Phone login flag ───────────────────────────────────────────────────────
  final bool isPhoneLogin;

  // ── KYC Status flag ────────────────────────────────────────────────────────
  final bool isKycCompleted;

  // ── Screen 4 – Email/Phone OTP digits (6-digit) ────────────────────────────
  final List<String> otpDigits;
  final int otpCountdown; // seconds remaining (00:25 countdown)
  final bool isOtpResendAvailable;

  // ── Screen 6 – Forgot Password email ──────────────────────────────────────
  final String forgotPasswordEmail;

  // ── Validation helpers ─────────────────────────────────────────────────────
  final String? emailPhoneError;
  final String? passwordError;

  const SellerLoginPageState({
    this.step = SellerLoginStep.loginForm,
    this.status = SellerLoginStatus.initial,
    this.errorMessage,
    this.emailOrPhone = '',
    this.password = '',
    this.isPasswordObscured = true,
    this.isPhoneLogin = false,
    this.isKycCompleted = false,
    this.otpDigits = const ['', '', '', '', '', ''],
    this.otpCountdown = 25,
    this.isOtpResendAvailable = false,
    this.forgotPasswordEmail = '',
    this.emailPhoneError,
    this.passwordError,
  });

  // ─────────────────────────────────────────────────────────────────────────
  // Derived helpers
  // ─────────────────────────────────────────────────────────────────────────

  /// Returns the concatenated 6-digit OTP string for login OTP.
  String get otpCode => otpDigits.join();

  /// True when all 6 OTP digits are filled for login.
  bool get isOtpComplete => otpDigits.every((d) => d.isNotEmpty);

  /// True when the form is valid for direct login submission.
  bool get isLoginFormValid =>
      emailOrPhone.isNotEmpty && password.isNotEmpty;

  // ─────────────────────────────────────────────────────────────────────────
  // copyWith
  // ─────────────────────────────────────────────────────────────────────────
  SellerLoginPageState copyWith({
    SellerLoginStep? step,
    SellerLoginStatus? status,
    String? errorMessage,
    bool clearError = false,
    String? emailOrPhone,
    String? password,
    bool? isPasswordObscured,
    bool? isPhoneLogin,
    bool? isKycCompleted,
    List<String>? otpDigits,
    int? otpCountdown,
    bool? isOtpResendAvailable,
    String? forgotPasswordEmail,
    String? emailPhoneError,
    bool clearEmailPhoneError = false,
    String? passwordError,
    bool clearPasswordError = false,
  }) {
    return SellerLoginPageState(
      step: step ?? this.step,
      status: status ?? this.status,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      emailOrPhone: emailOrPhone ?? this.emailOrPhone,
      password: password ?? this.password,
      isPasswordObscured: isPasswordObscured ?? this.isPasswordObscured,
      isPhoneLogin: isPhoneLogin ?? this.isPhoneLogin,
      isKycCompleted: isKycCompleted ?? this.isKycCompleted,
      otpDigits: otpDigits ?? this.otpDigits,
      otpCountdown: otpCountdown ?? this.otpCountdown,
      isOtpResendAvailable: isOtpResendAvailable ?? this.isOtpResendAvailable,
      forgotPasswordEmail: forgotPasswordEmail ?? this.forgotPasswordEmail,
      emailPhoneError:
          clearEmailPhoneError ? null : (emailPhoneError ?? this.emailPhoneError),
      passwordError:
          clearPasswordError ? null : (passwordError ?? this.passwordError),
    );
  }

  @override
  List<Object?> get props => [
        step,
        status,
        errorMessage,
        emailOrPhone,
        password,
        isPasswordObscured,
        isPhoneLogin,
        isKycCompleted,
        otpDigits,
        otpCountdown,
        isOtpResendAvailable,
        forgotPasswordEmail,
        emailPhoneError,
        passwordError,
      ];

  @override
  String toString() =>
      'SellerLoginPageState(step: $step, status: $status, email: $emailOrPhone, kycCompleted: $isKycCompleted)';
}
