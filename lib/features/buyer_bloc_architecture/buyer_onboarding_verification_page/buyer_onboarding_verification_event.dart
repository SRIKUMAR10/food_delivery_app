import 'package:equatable/equatable.dart';
import 'buyer_onboarding_verification_state.dart';

abstract class BuyerOnboardingVerificationEvent extends Equatable {
  const BuyerOnboardingVerificationEvent();

  @override
  List<Object?> get props => [];
}

/// Step Navigation
class BuyerVerificationStepChanged extends BuyerOnboardingVerificationEvent {
  final BuyerVerificationStep step;
  const BuyerVerificationStepChanged(this.step);

  @override
  List<Object?> get props => [step];
}

class BuyerVerificationNextStepPressed extends BuyerOnboardingVerificationEvent {
  const BuyerVerificationNextStepPressed();
}

class BuyerVerificationPreviousStepPressed extends BuyerOnboardingVerificationEvent {
  const BuyerVerificationPreviousStepPressed();
}

class BuyerVerificationPrefillRequested extends BuyerOnboardingVerificationEvent {
  final String? fullName;
  final String? displayName;
  final String? email;
  final String? phone;
  final String? avatarUrl;
  final bool? isPhoneVerified;

  const BuyerVerificationPrefillRequested({
    this.fullName,
    this.displayName,
    this.email,
    this.phone,
    this.avatarUrl,
    this.isPhoneVerified,
  });

  @override
  List<Object?> get props => [
        fullName,
        displayName,
        email,
        phone,
        avatarUrl,
        isPhoneVerified,
      ];
}

class BuyerVerificationAutoFetchRequested extends BuyerOnboardingVerificationEvent {
  const BuyerVerificationAutoFetchRequested();
}

/// Step 1: Personal Details
class BuyerPersonalDetailsUpdated extends BuyerOnboardingVerificationEvent {
  final String fullName;
  final String displayName;
  final String bio;
  final String? avatarUrl;

  const BuyerPersonalDetailsUpdated({
    required this.fullName,
    required this.displayName,
    required this.bio,
    this.avatarUrl,
  });

  @override
  List<Object?> get props => [fullName, displayName, bio, avatarUrl];
}

/// Step 2: Contact & OTP
class BuyerContactUpdated extends BuyerOnboardingVerificationEvent {
  final String email;
  final String phone;

  const BuyerContactUpdated({
    required this.email,
    required this.phone,
  });

  @override
  List<Object?> get props => [email, phone];
}

class BuyerSendOtpRequested extends BuyerOnboardingVerificationEvent {
  const BuyerSendOtpRequested();
}

class BuyerOtpCodeChanged extends BuyerOnboardingVerificationEvent {
  final String otpCode;
  const BuyerOtpCodeChanged(this.otpCode);

  @override
  List<Object?> get props => [otpCode];
}

class BuyerVerifyOtpPressed extends BuyerOnboardingVerificationEvent {
  const BuyerVerifyOtpPressed();
}

class BuyerOtpTimerTicked extends BuyerOnboardingVerificationEvent {
  const BuyerOtpTimerTicked();
}

/// Step 3: Address & Location
class BuyerAddressUpdated extends BuyerOnboardingVerificationEvent {
  final String formattedAddress;
  final String houseFlatNo;
  final String landmark;
  final String addressTag;
  final double? latitude;
  final double? longitude;

  const BuyerAddressUpdated({
    required this.formattedAddress,
    required this.houseFlatNo,
    required this.landmark,
    required this.addressTag,
    this.latitude,
    this.longitude,
  });

  @override
  List<Object?> get props => [
        formattedAddress,
        houseFlatNo,
        landmark,
        addressTag,
        latitude,
        longitude,
      ];
}

class BuyerCurrentLocationRequested extends BuyerOnboardingVerificationEvent {
  const BuyerCurrentLocationRequested();
}

/// Step 4: Dietary Preferences
class BuyerDietaryPreferenceToggled extends BuyerOnboardingVerificationEvent {
  final String dietaryType;
  const BuyerDietaryPreferenceToggled(this.dietaryType);

  @override
  List<Object?> get props => [dietaryType];
}

class BuyerSpicePreferenceChanged extends BuyerOnboardingVerificationEvent {
  final String spicePreference;
  const BuyerSpicePreferenceChanged(this.spicePreference);

  @override
  List<Object?> get props => [spicePreference];
}

/// Step 5: Food Allergies
class BuyerAllergyToggled extends BuyerOnboardingVerificationEvent {
  final String allergy;
  const BuyerAllergyToggled(this.allergy);

  @override
  List<Object?> get props => [allergy];
}

class BuyerCustomAllergyNotesChanged extends BuyerOnboardingVerificationEvent {
  final String notes;
  const BuyerCustomAllergyNotesChanged(this.notes);

  @override
  List<Object?> get props => [notes];
}

/// Step 6: Payment Setup
class BuyerPaymentPreferenceSelected extends BuyerOnboardingVerificationEvent {
  final String paymentMethod;
  final String? defaultUpiId;
  final bool activateBuyerWallet;

  const BuyerPaymentPreferenceSelected({
    required this.paymentMethod,
    this.defaultUpiId,
    this.activateBuyerWallet = true,
  });

  @override
  List<Object?> get props => [paymentMethod, defaultUpiId, activateBuyerWallet];
}

/// Step 7: Permissions
class BuyerPermissionsUpdated extends BuyerOnboardingVerificationEvent {
  final bool locationGranted;
  final bool notificationsGranted;
  final bool cameraGranted;

  const BuyerPermissionsUpdated({
    required this.locationGranted,
    required this.notificationsGranted,
    required this.cameraGranted,
  });

  @override
  List<Object?> get props => [
        locationGranted,
        notificationsGranted,
        cameraGranted,
      ];
}

/// Step 8: Final Submission & Account Activation
class BuyerCompleteVerificationSubmitted extends BuyerOnboardingVerificationEvent {
  const BuyerCompleteVerificationSubmitted();
}
