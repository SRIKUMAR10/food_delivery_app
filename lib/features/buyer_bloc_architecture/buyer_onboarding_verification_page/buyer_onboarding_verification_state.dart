import 'dart:typed_data';
import 'package:equatable/equatable.dart';

/// 6 Chronological Steps in the Buyer Onboarding & Verification Lifecycle.
enum BuyerVerificationStep {
  personalDetails, // Step 1: Name, Avatar, Bio
  contactVerification, // Step 2: Email, Phone, OTP confirmation
  addressSelection, // Step 3: Google Places geocoding & GPS map pin
  paymentSetup, // Step 4: Default UPI/Card/COD, Wallet Activation
  permissionsSetup, // Step 5: GPS Location, FCM Push Notifications
  completionSuccess, // Step 6: Welcome coupon and final activation
}

enum BuyerVerificationStatus {
  initial,
  loading,
  inProgress,
  otpSent,
  otpVerified,
  success,
  failure,
}

class BuyerOnboardingVerificationState extends Equatable {
  final BuyerVerificationStep currentStep;
  final BuyerVerificationStatus status;
  final String? errorMessage;
  final String? successMessage;
  final bool isDataFetched;

  // Step 1: Personal Details & Avatar
  final String fullName;
  final String displayName;
  final String? avatarUrl;
  final Uint8List? localAvatarBytes;
  final bool isUploadingAvatar;
  final String bio;

  // Step 2: Contact & Phone Verification
  final String email;
  final String phone;
  final String otpCode;
  final bool isPhoneVerified;
  final int otpCountdown;
  final bool isOtpResendAvailable;

  // Step 3: Address & Location
  final String formattedAddress;
  final String houseFlatNo;
  final String landmark;
  final String addressTag; // Home, Work, Other
  final double? latitude;
  final double? longitude;
  final bool isLocatingGps;

  // Step 4: Payment Preference & Wallet Setup
  final String preferredPaymentMethod; // UPI, Card, NetBanking, COD, Wallet
  final String? defaultUpiId;
  final bool activateBuyerWallet;

  // Step 5: Permissions
  final bool locationPermissionGranted;
  final bool pushNotificationsGranted;
  final bool cameraPermissionGranted;

  // Step 6: Welcome & First Order Discount
  final String welcomeCouponCode;
  final double welcomeDiscountAmount;

  const BuyerOnboardingVerificationState({
    this.currentStep = BuyerVerificationStep.personalDetails,
    this.status = BuyerVerificationStatus.initial,
    this.errorMessage,
    this.successMessage,
    this.isDataFetched = false,
    this.fullName = '',
    this.displayName = '',
    this.avatarUrl,
    this.localAvatarBytes,
    this.isUploadingAvatar = false,
    this.bio = '',
    this.email = '',
    this.phone = '',
    this.otpCode = '',
    this.isPhoneVerified = false,
    this.otpCountdown = 30,
    this.isOtpResendAvailable = false,
    this.formattedAddress = '',
    this.houseFlatNo = '',
    this.landmark = '',
    this.addressTag = 'Home',
    this.latitude,
    this.longitude,
    this.isLocatingGps = false,
    this.preferredPaymentMethod = 'UPI',
    this.defaultUpiId,
    this.activateBuyerWallet = true,
    this.locationPermissionGranted = true,
    this.pushNotificationsGranted = true,
    this.cameraPermissionGranted = true,
    this.welcomeCouponCode = 'WELCOME100',
    this.welcomeDiscountAmount = 100.0,
  });

  BuyerOnboardingVerificationState copyWith({
    BuyerVerificationStep? currentStep,
    BuyerVerificationStatus? status,
    String? errorMessage,
    String? successMessage,
    bool? isDataFetched,
    String? fullName,
    String? displayName,
    String? avatarUrl,
    Uint8List? localAvatarBytes,
    bool? isUploadingAvatar,
    bool clearAvatar = false,
    String? bio,
    String? email,
    String? phone,
    String? otpCode,
    bool? isPhoneVerified,
    int? otpCountdown,
    bool? isOtpResendAvailable,
    String? formattedAddress,
    String? houseFlatNo,
    String? landmark,
    String? addressTag,
    double? latitude,
    double? longitude,
    bool? isLocatingGps,
    String? preferredPaymentMethod,
    String? defaultUpiId,
    bool? activateBuyerWallet,
    bool? locationPermissionGranted,
    bool? pushNotificationsGranted,
    bool? cameraPermissionGranted,
    String? welcomeCouponCode,
    double? welcomeDiscountAmount,
  }) {
    return BuyerOnboardingVerificationState(
      currentStep: currentStep ?? this.currentStep,
      status: status ?? this.status,
      errorMessage: errorMessage,
      successMessage: successMessage,
      isDataFetched: isDataFetched ?? this.isDataFetched,
      fullName: fullName ?? this.fullName,
      displayName: displayName ?? this.displayName,
      avatarUrl: clearAvatar ? null : (avatarUrl ?? this.avatarUrl),
      localAvatarBytes: clearAvatar ? null : (localAvatarBytes ?? this.localAvatarBytes),
      isUploadingAvatar: isUploadingAvatar ?? this.isUploadingAvatar,
      bio: bio ?? this.bio,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      otpCode: otpCode ?? this.otpCode,
      isPhoneVerified: isPhoneVerified ?? this.isPhoneVerified,
      otpCountdown: otpCountdown ?? this.otpCountdown,
      isOtpResendAvailable: isOtpResendAvailable ?? this.isOtpResendAvailable,
      formattedAddress: formattedAddress ?? this.formattedAddress,
      houseFlatNo: houseFlatNo ?? this.houseFlatNo,
      landmark: landmark ?? this.landmark,
      addressTag: addressTag ?? this.addressTag,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      isLocatingGps: isLocatingGps ?? this.isLocatingGps,
      preferredPaymentMethod: preferredPaymentMethod ?? this.preferredPaymentMethod,
      defaultUpiId: defaultUpiId ?? this.defaultUpiId,
      activateBuyerWallet: activateBuyerWallet ?? this.activateBuyerWallet,
      locationPermissionGranted: locationPermissionGranted ?? this.locationPermissionGranted,
      pushNotificationsGranted: pushNotificationsGranted ?? this.pushNotificationsGranted,
      cameraPermissionGranted: cameraPermissionGranted ?? this.cameraPermissionGranted,
      welcomeCouponCode: welcomeCouponCode ?? this.welcomeCouponCode,
      welcomeDiscountAmount: welcomeDiscountAmount ?? this.welcomeDiscountAmount,
    );
  }

  @override
  List<Object?> get props => [
        currentStep,
        status,
        errorMessage,
        successMessage,
        isDataFetched,
        fullName,
        displayName,
        avatarUrl,
        localAvatarBytes,
        isUploadingAvatar,
        bio,
        email,
        phone,
        otpCode,
        isPhoneVerified,
        otpCountdown,
        isOtpResendAvailable,
        formattedAddress,
        houseFlatNo,
        landmark,
        addressTag,
        latitude,
        longitude,
        isLocatingGps,
        preferredPaymentMethod,
        defaultUpiId,
        activateBuyerWallet,
        locationPermissionGranted,
        pushNotificationsGranted,
        cameraPermissionGranted,
        welcomeCouponCode,
        welcomeDiscountAmount,
      ];
}
