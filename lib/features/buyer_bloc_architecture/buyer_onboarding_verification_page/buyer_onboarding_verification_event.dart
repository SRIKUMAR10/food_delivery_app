import 'dart:typed_data';
import 'package:equatable/equatable.dart';
import 'package:image_picker/image_picker.dart';
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

/// Real-time User Data Synchronization
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

/// Step 1: Personal Details & Avatar
class BuyerAvatarPickRequested extends BuyerOnboardingVerificationEvent {
  final ImageSource? source;
  final Uint8List? directBytes;
  final String? fileName;

  const BuyerAvatarPickRequested({
    this.source,
    this.directBytes,
    this.fileName,
  });

  @override
  List<Object?> get props => [source, directBytes, fileName];
}

class BuyerAvatarRemoved extends BuyerOnboardingVerificationEvent {
  const BuyerAvatarRemoved();
}

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

class BuyerAddressTagChanged extends BuyerOnboardingVerificationEvent {
  final String addressTag;
  const BuyerAddressTagChanged(this.addressTag);

  @override
  List<Object?> get props => [addressTag];
}

class BuyerAddressLocationSelected extends BuyerOnboardingVerificationEvent {
  final String formattedAddress;
  final double latitude;
  final double longitude;
  final String? houseFlatNo;
  final String? landmark;
  final String? addressTag;

  const BuyerAddressLocationSelected({
    required this.formattedAddress,
    required this.latitude,
    required this.longitude,
    this.houseFlatNo,
    this.landmark,
    this.addressTag,
  });

  @override
  List<Object?> get props => [
        formattedAddress,
        latitude,
        longitude,
        houseFlatNo,
        landmark,
        addressTag,
      ];
}

/// Step 4: Payment Setup
class BuyerPaymentMethodChanged extends BuyerOnboardingVerificationEvent {
  final String paymentMethod;
  const BuyerPaymentMethodChanged(this.paymentMethod);

  @override
  List<Object?> get props => [paymentMethod];
}

class BuyerWalletToggled extends BuyerOnboardingVerificationEvent {
  final bool activate;
  const BuyerWalletToggled(this.activate);

  @override
  List<Object?> get props => [activate];
}

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

/// Step 5: Permissions
class BuyerSinglePermissionToggled extends BuyerOnboardingVerificationEvent {
  final String permissionType;
  final bool isGranted;

  const BuyerSinglePermissionToggled({
    required this.permissionType,
    required this.isGranted,
  });

  @override
  List<Object?> get props => [permissionType, isGranted];
}

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

/// Step 6: Final Submission & Account Activation
class BuyerCompleteVerificationSubmitted extends BuyerOnboardingVerificationEvent {
  const BuyerCompleteVerificationSubmitted();
}
