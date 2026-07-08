// ignore_for_file: must_be_immutable

import 'package:equatable/equatable.dart';

/// ─────────────────────────────────────────────────────────────────────────────
/// Seller Login Page – Events
/// Covers all UI screens:
///   1. Login Screen (Email/Phone + Password)
///   2. Enter Email / Phone
///   3. Enter Password
///   4. Email OTP Verification
///   5. Login Successful
///   6. Forgot Password – Enter Email
///   7. Forgot Password Success – Link Sent
/// ─────────────────────────────────────────────────────────────────────────────
abstract class SellerLoginPageEvent extends Equatable {
  const SellerLoginPageEvent();

  @override
  List<Object?> get props => [];
}

// ─────────────────────────────────────────────────────────────────────────────
// Screen 1 & 2 – Field / Credential Changes
// ─────────────────────────────────────────────────────────────────────────────

/// Fired whenever the Email/Phone field value changes.
class SellerLoginFieldChanged extends SellerLoginPageEvent {
  final String emailOrPhone;
  const SellerLoginFieldChanged(this.emailOrPhone);

  @override
  List<Object?> get props => [emailOrPhone];
}

/// Fired whenever the Password field value changes.
class SellerLoginPasswordChanged extends SellerLoginPageEvent {
  final String password;
  const SellerLoginPasswordChanged(this.password);

  @override
  List<Object?> get props => [password];
}

/// Toggles the password visibility (eye icon tap).
class SellerLoginPasswordVisibilityToggled extends SellerLoginPageEvent {}

// ─────────────────────────────────────────────────────────────────────────────
// Screen 1 – Primary Login Submit
// ─────────────────────────────────────────────────────────────────────────────

/// User taps "Login" — triggers Email/Password authentication.
class SellerLoginSubmitted extends SellerLoginPageEvent {
  const SellerLoginSubmitted();
}

/// User taps "Continue" after entering Email/Phone (Step 2 flow).
class SellerLoginEmailPhoneContinued extends SellerLoginPageEvent {
  const SellerLoginEmailPhoneContinued();
}

// ─────────────────────────────────────────────────────────────────────────────
// Screen 3 – Password Step
// ─────────────────────────────────────────────────────────────────────────────

/// User taps "Login" on the Enter Password screen (Step 3).
class SellerLoginPasswordStepSubmitted extends SellerLoginPageEvent {
  const SellerLoginPasswordStepSubmitted();
}

// ─────────────────────────────────────────────────────────────────────────────
// Screen 4 – Email OTP Verification
// ─────────────────────────────────────────────────────────────────────────────

/// Fired as each OTP digit is entered (index 0–5, value 0–9).
class SellerLoginOtpDigitChanged extends SellerLoginPageEvent {
  final int index;
  final String digit;
  const SellerLoginOtpDigitChanged({required this.index, required this.digit});

  @override
  List<Object?> get props => [index, digit];
}

/// User taps "Verify" after entering all 6 OTP digits.
class SellerLoginOtpVerifySubmitted extends SellerLoginPageEvent {
  const SellerLoginOtpVerifySubmitted();
}

/// User taps "Resend OTP".
class SellerLoginOtpResendRequested extends SellerLoginPageEvent {
  const SellerLoginOtpResendRequested();
}

/// OTP countdown timer ticked (1-second intervals).
class SellerLoginOtpTimerTicked extends SellerLoginPageEvent {
  final int secondsRemaining;
  const SellerLoginOtpTimerTicked(this.secondsRemaining);

  @override
  List<Object?> get props => [secondsRemaining];
}

// ─────────────────────────────────────────────────────────────────────────────
// Screen 5 – Login Successful → Navigate to Dashboard
// ─────────────────────────────────────────────────────────────────────────────

/// User taps "Go to Dashboard" after successful login.
class SellerLoginGoToDashboardPressed extends SellerLoginPageEvent {
  const SellerLoginGoToDashboardPressed();
}

// ─────────────────────────────────────────────────────────────────────────────
// Screen 6 – Forgot Password (Enter Email + Send Link)
// ─────────────────────────────────────────────────────────────────────────────

/// Navigate to the Forgot Password screen.
class SellerLoginForgotPasswordNavigated extends SellerLoginPageEvent {
  const SellerLoginForgotPasswordNavigated();
}

/// Fired when the forgot-password email field changes.
class SellerLoginForgotPasswordEmailChanged extends SellerLoginPageEvent {
  final String email;
  const SellerLoginForgotPasswordEmailChanged(this.email);

  @override
  List<Object?> get props => [email];
}

/// User taps "Send Reset Link" on the Forgot Password screen.
class SellerLoginForgotPasswordLinkSent extends SellerLoginPageEvent {
  const SellerLoginForgotPasswordLinkSent();
}

// ─────────────────────────────────────────────────────────────────────────────
// Screen 7 – Forgot Password Success (Link Sent)
// ─────────────────────────────────────────────────────────────────────────────

/// User taps "Back to Login" after link is sent.
class SellerLoginBackToLoginPressed extends SellerLoginPageEvent {
  const SellerLoginBackToLoginPressed();
}

// ─────────────────────────────────────────────────────────────────────────────
// Social Sign-In
// ─────────────────────────────────────────────────────────────────────────────

/// User taps the Google sign-in button.
class SellerLoginGoogleSignInPressed extends SellerLoginPageEvent {
  const SellerLoginGoogleSignInPressed();
}

/// User taps the Apple sign-in button.
class SellerLoginAppleSignInPressed extends SellerLoginPageEvent {
  const SellerLoginAppleSignInPressed();
}

// ─────────────────────────────────────────────────────────────────────────────
// Navigation & Lifecycle
// ─────────────────────────────────────────────────────────────────────────────

/// Navigate back to the previous screen.
class SellerLoginBackPressed extends SellerLoginPageEvent {
  const SellerLoginBackPressed();
}

/// Reset any error state so the user can retry.
class SellerLoginErrorDismissed extends SellerLoginPageEvent {
  const SellerLoginErrorDismissed();
}

/// App resumed from background – re-check auth state.
class SellerLoginAppLifecycleResumed extends SellerLoginPageEvent {
  const SellerLoginAppLifecycleResumed();
}
