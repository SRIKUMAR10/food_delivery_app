// ignore_for_file: lines_longer_than_80_chars

import 'package:equatable/equatable.dart';

/// Base class for all seller sign-up events.
abstract class SellerSignUpPageEvent extends Equatable {
  const SellerSignUpPageEvent();

  @override
  List<Object?> get props => [];
}

// ─────────────────────────────────────────────────────────────────────────────
// Screen 1 – Welcome / Role Select
// ─────────────────────────────────────────────────────────────────────────────

/// User taps "Get Started" / "Create Account" on the welcome screen.
class SellerSignUpGetStartedPressed extends SellerSignUpPageEvent {
  const SellerSignUpGetStartedPressed();
}

/// User taps "Already have an account? Login".
class SellerSignUpLoginNavigated extends SellerSignUpPageEvent {
  const SellerSignUpLoginNavigated();
}

// ─────────────────────────────────────────────────────────────────────────────
// Screen 2 – Personal Details (Name, Shop Name, Business Details)
// ─────────────────────────────────────────────────────────────────────────────

/// Full name field changed.
class SellerSignUpNameChanged extends SellerSignUpPageEvent {
  final String name;
  const SellerSignUpNameChanged(this.name);
  @override
  List<Object?> get props => [name];
}

/// Shop name field changed.
class SellerSignUpShopNameChanged extends SellerSignUpPageEvent {
  final String shopName;
  const SellerSignUpShopNameChanged(this.shopName);
  @override
  List<Object?> get props => [shopName];
}

/// Business details / description field changed.
class SellerSignUpBusinessDetailsChanged extends SellerSignUpPageEvent {
  final String businessDetails;
  const SellerSignUpBusinessDetailsChanged(this.businessDetails);
  @override
  List<Object?> get props => [businessDetails];
}

/// Address field changed manually or through search.
class SellerSignUpAddressChanged extends SellerSignUpPageEvent {
  final String address;
  const SellerSignUpAddressChanged(this.address);
  @override
  List<Object?> get props => [address];
}

/// GPS coordinates or address picked via map search.
class SellerSignUpCoordinatesChanged extends SellerSignUpPageEvent {
  final double? latitude;
  final double? longitude;
  final String? googleMapsUrl;
  final String? address;

  const SellerSignUpCoordinatesChanged({
    this.latitude,
    this.longitude,
    this.googleMapsUrl,
    this.address,
  });

  @override
  List<Object?> get props => [latitude, longitude, googleMapsUrl, address];
}

/// User tapped GPS auto-detect button to get current location.
class SellerSignUpGpsLocationRequested extends SellerSignUpPageEvent {
  const SellerSignUpGpsLocationRequested();
}

/// FSSAI license number field changed.
class SellerSignUpFssaiChanged extends SellerSignUpPageEvent {
  final String fssai;
  const SellerSignUpFssaiChanged(this.fssai);
  @override
  List<Object?> get props => [fssai];
}

/// GST number field changed.
class SellerSignUpGstChanged extends SellerSignUpPageEvent {
  final String gst;
  const SellerSignUpGstChanged(this.gst);
  @override
  List<Object?> get props => [gst];
}

/// User taps "Next" on screen 2 to proceed to screen 3.
class SellerSignUpPersonalDetailsSubmitted extends SellerSignUpPageEvent {
  const SellerSignUpPersonalDetailsSubmitted();
}

// ─────────────────────────────────────────────────────────────────────────────
// Screen 3 – Contact & Password
// ─────────────────────────────────────────────────────────────────────────────

/// Phone number field changed (e.g. "+919876543210").
class SellerSignUpPhoneChanged extends SellerSignUpPageEvent {
  final String phone;
  const SellerSignUpPhoneChanged(this.phone);
  @override
  List<Object?> get props => [phone];
}

/// Email field changed.
class SellerSignUpEmailChanged extends SellerSignUpPageEvent {
  final String email;
  const SellerSignUpEmailChanged(this.email);
  @override
  List<Object?> get props => [email];
}

/// Password field changed.
class SellerSignUpPasswordChanged extends SellerSignUpPageEvent {
  final String password;
  const SellerSignUpPasswordChanged(this.password);
  @override
  List<Object?> get props => [password];
}

/// Confirm password field changed.
class SellerSignUpConfirmPasswordChanged extends SellerSignUpPageEvent {
  final String confirmPassword;
  const SellerSignUpConfirmPasswordChanged(this.confirmPassword);
  @override
  List<Object?> get props => [confirmPassword];
}

/// Toggle password visibility.
class SellerSignUpPasswordVisibilityToggled extends SellerSignUpPageEvent {
  const SellerSignUpPasswordVisibilityToggled();
}

/// Toggle confirm password visibility.
class SellerSignUpConfirmPasswordVisibilityToggled extends SellerSignUpPageEvent {
  const SellerSignUpConfirmPasswordVisibilityToggled();
}

/// User taps "Create Account" / "Send OTP" on screen 3.
/// Initiates the sign-up process: validation → duplicate checks → OTP send.
class SellerSignUpContactSubmitted extends SellerSignUpPageEvent {
  const SellerSignUpContactSubmitted();
}

// ─────────────────────────────────────────────────────────────────────────────
// Screen 4 – OTP Verification
// ─────────────────────────────────────────────────────────────────────────────

/// One OTP digit changed at [index].
class SellerSignUpOtpDigitChanged extends SellerSignUpPageEvent {
  final int index;
  final String digit;
  const SellerSignUpOtpDigitChanged({required this.index, required this.digit});
  @override
  List<Object?> get props => [index, digit];
}

/// User taps "Verify" to confirm OTP and complete registration.
class SellerSignUpOtpVerifySubmitted extends SellerSignUpPageEvent {
  const SellerSignUpOtpVerifySubmitted();
}

/// OTP countdown timer ticked.
class SellerSignUpOtpTimerTicked extends SellerSignUpPageEvent {
  final int remaining;
  const SellerSignUpOtpTimerTicked(this.remaining);
  @override
  List<Object?> get props => [remaining];
}

/// User taps "Resend OTP".
class SellerSignUpOtpResendRequested extends SellerSignUpPageEvent {
  const SellerSignUpOtpResendRequested();
}

// ─────────────────────────────────────────────────────────────────────────────
// Screen 5 – Email Verification Sent
// ─────────────────────────────────────────────────────────────────────────────

/// User taps "I have verified" after receiving the email link.
class SellerSignUpEmailVerifyCheckPressed extends SellerSignUpPageEvent {
  const SellerSignUpEmailVerifyCheckPressed();
}

// ─────────────────────────────────────────────────────────────────────────────
// Screen 6 – Sign-Up Success
// ─────────────────────────────────────────────────────────────────────────────

/// User taps "Go to Dashboard" on the success screen.
class SellerSignUpGoToDashboardPressed extends SellerSignUpPageEvent {
  const SellerSignUpGoToDashboardPressed();
}

// ─────────────────────────────────────────────────────────────────────────────
// Global / Cross-Screen Events
// ─────────────────────────────────────────────────────────────────────────────

/// User taps the back button (system or AppBar).
class SellerSignUpBackPressed extends SellerSignUpPageEvent {
  const SellerSignUpBackPressed();
}

/// Dismiss an error snack/dialog and return to initial status.
class SellerSignUpErrorDismissed extends SellerSignUpPageEvent {
  const SellerSignUpErrorDismissed();
}

/// App resumed from background; check auth state.
class SellerSignUpAppLifecycleResumed extends SellerSignUpPageEvent {
  const SellerSignUpAppLifecycleResumed();
}

// ─────────────────────────────────────────────────────────────────────────────
// Social Sign-Up
// ─────────────────────────────────────────────────────────────────────────────

/// User taps "Sign up with Google".
class SellerSignUpGooglePressed extends SellerSignUpPageEvent {
  const SellerSignUpGooglePressed();
}

/// User taps "Sign up with Apple".
class SellerSignUpApplePressed extends SellerSignUpPageEvent {
  const SellerSignUpApplePressed();
}

// ─────────────────────────────────────────────────────────────────────────────
// Terms & Conditions
// ─────────────────────────────────────────────────────────────────────────────

/// Terms checkbox toggled.
class SellerSignUpTermsToggled extends SellerSignUpPageEvent {
  const SellerSignUpTermsToggled();
}
