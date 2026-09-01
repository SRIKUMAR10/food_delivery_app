import 'dart:typed_data';
import 'package:equatable/equatable.dart';
import 'delivery_onboarding_verification_state.dart';

abstract class DeliveryOnboardingVerificationEvent extends Equatable {
  const DeliveryOnboardingVerificationEvent();

  @override
  List<Object?> get props => [];
}

class DeliveryVerificationAutoFetchRequested
    extends DeliveryOnboardingVerificationEvent {
  const DeliveryVerificationAutoFetchRequested();
}

class DeliveryVerificationProfileStreamUpdated
    extends DeliveryOnboardingVerificationEvent {
  final Map<String, dynamic> data;

  const DeliveryVerificationProfileStreamUpdated(this.data);

  @override
  List<Object?> get props => [data];
}

class DeliveryVerificationStepChanged
    extends DeliveryOnboardingVerificationEvent {
  final DeliveryVerificationStep step;

  const DeliveryVerificationStepChanged(this.step);

  @override
  List<Object?> get props => [step];
}

class DeliveryPersonalDetailsChanged
    extends DeliveryOnboardingVerificationEvent {
  final String fullName;
  final String displayName;
  final String dob;
  final String gender;
  final String bloodGroup;
  final String emergencyContactName;
  final String emergencyContactPhone;
  final String bio;

  const DeliveryPersonalDetailsChanged({
    required this.fullName,
    required this.displayName,
    required this.dob,
    required this.gender,
    required this.bloodGroup,
    required this.emergencyContactName,
    required this.emergencyContactPhone,
    required this.bio,
  });

  @override
  List<Object?> get props => [
        fullName,
        displayName,
        dob,
        gender,
        bloodGroup,
        emergencyContactName,
        emergencyContactPhone,
        bio,
      ];
}

class DeliveryAvatarPicked extends DeliveryOnboardingVerificationEvent {
  final Uint8List bytes;
  final String fileName;

  const DeliveryAvatarPicked({
    required this.bytes,
    required this.fileName,
  });

  @override
  List<Object?> get props => [bytes, fileName];
}

class DeliveryContactChanged extends DeliveryOnboardingVerificationEvent {
  final String phone;
  final String email;

  const DeliveryContactChanged({
    required this.phone,
    required this.email,
  });

  @override
  List<Object?> get props => [phone, email];
}

class DeliverySendPhoneOtpRequested
    extends DeliveryOnboardingVerificationEvent {
  const DeliverySendPhoneOtpRequested();
}

class DeliveryVerifyPhoneOtpRequested
    extends DeliveryOnboardingVerificationEvent {
  final String otpCode;

  const DeliveryVerifyPhoneOtpRequested(this.otpCode);

  @override
  List<Object?> get props => [otpCode];
}

class DeliveryOtpTimerTick extends DeliveryOnboardingVerificationEvent {
  final int countdown;

  const DeliveryOtpTimerTick(this.countdown);

  @override
  List<Object?> get props => [countdown];
}

class DeliveryVehicleDetailsChanged
    extends DeliveryOnboardingVerificationEvent {
  final String vehicleType;
  final String vehicleNumber;
  final String vehicleModel;
  final String drivingLicenseNumber;
  final String dlExpiryDate;

  const DeliveryVehicleDetailsChanged({
    required this.vehicleType,
    required this.vehicleNumber,
    required this.vehicleModel,
    required this.drivingLicenseNumber,
    required this.dlExpiryDate,
  });

  @override
  List<Object?> get props => [
        vehicleType,
        vehicleNumber,
        vehicleModel,
        drivingLicenseNumber,
        dlExpiryDate,
      ];
}

class DeliveryDlDocumentPicked extends DeliveryOnboardingVerificationEvent {
  final bool isFront;
  final Uint8List bytes;
  final String fileName;

  const DeliveryDlDocumentPicked({
    required this.isFront,
    required this.bytes,
    required this.fileName,
  });

  @override
  List<Object?> get props => [isFront, bytes, fileName];
}

class DeliveryRcDocumentPicked extends DeliveryOnboardingVerificationEvent {
  final Uint8List bytes;
  final String fileName;

  const DeliveryRcDocumentPicked({
    required this.bytes,
    required this.fileName,
  });

  @override
  List<Object?> get props => [bytes, fileName];
}

class DeliveryKycDetailsChanged extends DeliveryOnboardingVerificationEvent {
  final String aadhaarNumber;
  final String panNumber;

  const DeliveryKycDetailsChanged({
    required this.aadhaarNumber,
    required this.panNumber,
  });

  @override
  List<Object?> get props => [aadhaarNumber, panNumber];
}

class DeliveryKycDocumentPicked extends DeliveryOnboardingVerificationEvent {
  final String docType; // 'aadhaar' or 'pan'
  final bool isFront;
  final Uint8List bytes;
  final String fileName;

  const DeliveryKycDocumentPicked({
    required this.docType,
    required this.isFront,
    required this.bytes,
    required this.fileName,
  });

  @override
  List<Object?> get props => [docType, isFront, bytes, fileName];
}

class DeliveryBankDetailsChanged extends DeliveryOnboardingVerificationEvent {
  final String bankAccountNumber;
  final String confirmAccountNumber;
  final String ifscCode;
  final String bankName;
  final String accountHolderName;
  final String upiId;
  final String payoutFrequency;

  const DeliveryBankDetailsChanged({
    required this.bankAccountNumber,
    required this.confirmAccountNumber,
    required this.ifscCode,
    required this.bankName,
    required this.accountHolderName,
    required this.upiId,
    required this.payoutFrequency,
  });

  @override
  List<Object?> get props => [
        bankAccountNumber,
        confirmAccountNumber,
        ifscCode,
        bankName,
        accountHolderName,
        upiId,
        payoutFrequency,
      ];
}

class DeliveryZonePreferencesChanged
    extends DeliveryOnboardingVerificationEvent {
  final String city;
  final String operatingZone;
  final String preferredShift;
  final String workType;
  final double deliveryRadiusKm;
  final String formattedAddress;
  final String houseFlatNo;
  final String landmark;
  final double? latitude;
  final double? longitude;

  const DeliveryZonePreferencesChanged({
    required this.city,
    required this.operatingZone,
    required this.preferredShift,
    required this.workType,
    required this.deliveryRadiusKm,
    required this.formattedAddress,
    required this.houseFlatNo,
    required this.landmark,
    this.latitude,
    this.longitude,
  });

  @override
  List<Object?> get props => [
        city,
        operatingZone,
        preferredShift,
        workType,
        deliveryRadiusKm,
        formattedAddress,
        houseFlatNo,
        landmark,
        latitude,
        longitude,
      ];
}

class DeliveryPermissionsChanged extends DeliveryOnboardingVerificationEvent {
  final bool locationPermissionGranted;
  final bool backgroundLocationGranted;
  final bool pushNotificationsGranted;
  final bool cameraPermissionGranted;
  final bool batteryOptimizationDisabled;

  const DeliveryPermissionsChanged({
    required this.locationPermissionGranted,
    required this.backgroundLocationGranted,
    required this.pushNotificationsGranted,
    required this.cameraPermissionGranted,
    required this.batteryOptimizationDisabled,
  });

  @override
  List<Object?> get props => [
        locationPermissionGranted,
        backgroundLocationGranted,
        pushNotificationsGranted,
        cameraPermissionGranted,
        batteryOptimizationDisabled,
      ];
}

class DeliverySafetyAndKitChanged extends DeliveryOnboardingVerificationEvent {
  final bool hasDeliveryBag;
  final bool hasHelmet;
  final bool acknowledgedCodeOfConduct;

  const DeliverySafetyAndKitChanged({
    required this.hasDeliveryBag,
    required this.hasHelmet,
    required this.acknowledgedCodeOfConduct,
  });

  @override
  List<Object?> get props => [
        hasDeliveryBag,
        hasHelmet,
        acknowledgedCodeOfConduct,
      ];
}

class DeliverySubmitVerificationApplication
    extends DeliveryOnboardingVerificationEvent {
  const DeliverySubmitVerificationApplication();
}
