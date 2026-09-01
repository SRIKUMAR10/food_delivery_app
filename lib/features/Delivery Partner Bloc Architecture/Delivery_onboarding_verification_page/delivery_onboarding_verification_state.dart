import 'dart:typed_data';
import 'package:equatable/equatable.dart';

/// 8 Chronological Steps in the Delivery Partner Onboarding & Verification Lifecycle.
enum DeliveryVerificationStep {
  personalDetails, // Step 1: Name, Avatar/Selfie, DOB, Gender, Emergency Contact
  contactVerification, // Step 2: Phone OTP, Email confirmation
  vehicleAndLicense, // Step 3: Vehicle Type, Plate No, Driving License & RC copy
  kycDocuments, // Step 4: Aadhaar / National ID, PAN Card with photos
  bankAndPayouts, // Step 5: Bank Account, IFSC, UPI ID, Payout Frequency
  zoneAndPreferences, // Step 6: Operating City/Zone, Shifts, GPS Base Location
  hardwarePermissions, // Step 7: GPS Location, Background Tracking, Push Notifications, Camera
  safetyKitAndActivation, // Step 8: Bag/Helmet verification, Code of Conduct & Final Submit
}

enum DeliveryVerificationStatus {
  initial,
  loading,
  inProgress,
  otpSent,
  otpVerified,
  uploadingFiles,
  success,
  failure,
}

class DeliveryOnboardingVerificationState extends Equatable {
  final DeliveryVerificationStep currentStep;
  final DeliveryVerificationStatus status;
  final String? errorMessage;
  final String? successMessage;
  final bool isDataFetched;

  // ───────────────────────────────────────────────────────────────────────────
  // Step 1: Personal Details & Live Photo/Avatar
  // ───────────────────────────────────────────────────────────────────────────
  final String fullName;
  final String displayName;
  final String dob;
  final String gender;
  final String bloodGroup;
  final String emergencyContactName;
  final String emergencyContactPhone;
  final String? avatarUrl;
  final Uint8List? localAvatarBytes;
  final String? avatarFileName;
  final bool isUploadingAvatar;
  final String bio;

  // ───────────────────────────────────────────────────────────────────────────
  // Step 2: Contact & Phone/OTP Verification
  // ───────────────────────────────────────────────────────────────────────────
  final String email;
  final String phone;
  final String otpCode;
  final bool isPhoneVerified;
  final int otpCountdown;
  final bool isOtpResendAvailable;

  // ───────────────────────────────────────────────────────────────────────────
  // Step 3: Vehicle & Driving License Details
  // ───────────────────────────────────────────────────────────────────────────
  final String vehicleType; // Motorcycle, Scooter, Electric Vehicle, Bicycle
  final String vehicleNumber;
  final String vehicleModel;
  final String drivingLicenseNumber;
  final String dlExpiryDate;
  final Uint8List? dlFrontBytes;
  final String? dlFrontUrl;
  final Uint8List? dlBackBytes;
  final String? dlBackUrl;
  final Uint8List? rcBookBytes;
  final String? rcBookUrl;

  // ───────────────────────────────────────────────────────────────────────────
  // Step 4: Identity & KYC Documents (Aadhaar / PAN)
  // ───────────────────────────────────────────────────────────────────────────
  final String aadhaarNumber;
  final String panNumber;
  final Uint8List? aadhaarFrontBytes;
  final String? aadhaarFrontUrl;
  final Uint8List? aadhaarBackBytes;
  final String? aadhaarBackUrl;
  final Uint8List? panCardBytes;
  final String? panCardUrl;

  // ───────────────────────────────────────────────────────────────────────────
  // Step 5: Bank Details & Instant Payout Settings
  // ───────────────────────────────────────────────────────────────────────────
  final String bankAccountNumber;
  final String confirmAccountNumber;
  final String ifscCode;
  final String bankName;
  final String accountHolderName;
  final String upiId;
  final String payoutFrequency; // Daily, Weekly

  // ───────────────────────────────────────────────────────────────────────────
  // Step 6: Operating Zone & Work Preferences
  // ───────────────────────────────────────────────────────────────────────────
  final String city;
  final String operatingZone;
  final String preferredShift; // Morning, Evening, Night, Flexible
  final String workType; // Full-Time, Part-Time, Weekend
  final double deliveryRadiusKm;
  final String formattedAddress;
  final String houseFlatNo;
  final String landmark;
  final double? latitude;
  final double? longitude;
  final bool isLocatingGps;

  // ───────────────────────────────────────────────────────────────────────────
  // Step 7: Permissions & Hardware Telemetry
  // ───────────────────────────────────────────────────────────────────────────
  final bool locationPermissionGranted;
  final bool backgroundLocationGranted;
  final bool pushNotificationsGranted;
  final bool cameraPermissionGranted;
  final bool batteryOptimizationDisabled;

  // ───────────────────────────────────────────────────────────────────────────
  // Step 8: Safety Gear, Guidelines & Activation
  // ───────────────────────────────────────────────────────────────────────────
  final bool hasDeliveryBag;
  final bool hasHelmet;
  final bool acknowledgedCodeOfConduct;
  final String welcomeBonusCode;
  final double welcomeBonusAmount;

  const DeliveryOnboardingVerificationState({
    this.currentStep = DeliveryVerificationStep.personalDetails,
    this.status = DeliveryVerificationStatus.initial,
    this.errorMessage,
    this.successMessage,
    this.isDataFetched = false,
    // Step 1
    this.fullName = '',
    this.displayName = '',
    this.dob = '',
    this.gender = 'Male',
    this.bloodGroup = 'O+',
    this.emergencyContactName = '',
    this.emergencyContactPhone = '',
    this.avatarUrl,
    this.localAvatarBytes,
    this.avatarFileName,
    this.isUploadingAvatar = false,
    this.bio = '',
    // Step 2
    this.email = '',
    this.phone = '',
    this.otpCode = '',
    this.isPhoneVerified = false,
    this.otpCountdown = 30,
    this.isOtpResendAvailable = false,
    // Step 3
    this.vehicleType = 'Motorcycle',
    this.vehicleNumber = '',
    this.vehicleModel = '',
    this.drivingLicenseNumber = '',
    this.dlExpiryDate = '',
    this.dlFrontBytes,
    this.dlFrontUrl,
    this.dlBackBytes,
    this.dlBackUrl,
    this.rcBookBytes,
    this.rcBookUrl,
    // Step 4
    this.aadhaarNumber = '',
    this.panNumber = '',
    this.aadhaarFrontBytes,
    this.aadhaarFrontUrl,
    this.aadhaarBackBytes,
    this.aadhaarBackUrl,
    this.panCardBytes,
    this.panCardUrl,
    // Step 5
    this.bankAccountNumber = '',
    this.confirmAccountNumber = '',
    this.ifscCode = '',
    this.bankName = '',
    this.accountHolderName = '',
    this.upiId = '',
    this.payoutFrequency = 'Daily',
    // Step 6
    this.city = 'Chennai',
    this.operatingZone = 'Central Zone',
    this.preferredShift = 'Flexible',
    this.workType = 'Full-Time',
    this.deliveryRadiusKm = 10.0,
    this.formattedAddress = '',
    this.houseFlatNo = '',
    this.landmark = '',
    this.latitude,
    this.longitude,
    this.isLocatingGps = false,
    // Step 7
    this.locationPermissionGranted = true,
    this.backgroundLocationGranted = true,
    this.pushNotificationsGranted = true,
    this.cameraPermissionGranted = true,
    this.batteryOptimizationDisabled = true,
    // Step 8
    this.hasDeliveryBag = true,
    this.hasHelmet = true,
    this.acknowledgedCodeOfConduct = true,
    this.welcomeBonusCode = 'RIDERBONUS500',
    this.welcomeBonusAmount = 500.0,
  });

  // ───────────────────────────────────────────────────────────────────────────
  // Rigorous Per-Step Validation Helpers
  // ───────────────────────────────────────────────────────────────────────────

  String? validateStep(DeliveryVerificationStep step) {
    switch (step) {
      case DeliveryVerificationStep.personalDetails:
        return validateStep1();
      case DeliveryVerificationStep.contactVerification:
        return validateStep2();
      case DeliveryVerificationStep.vehicleAndLicense:
        return validateStep3();
      case DeliveryVerificationStep.kycDocuments:
        return validateStep4();
      case DeliveryVerificationStep.bankAndPayouts:
        return validateStep5();
      case DeliveryVerificationStep.zoneAndPreferences:
        return validateStep6();
      case DeliveryVerificationStep.hardwarePermissions:
        return validateStep7();
      case DeliveryVerificationStep.safetyKitAndActivation:
        return validateStep8();
    }
  }

  String? validateStep1() {
    if (fullName.trim().length < 3) {
      return 'Please enter your Full Name (at least 3 characters)';
    }
    if (dob.trim().isEmpty) {
      return 'Please enter your Date of Birth (DD/MM/YYYY)';
    }
    if (emergencyContactName.trim().length < 2) {
      return 'Please enter Emergency Contact Person Name';
    }
    final cleanEmerPhone = emergencyContactPhone.replaceAll(RegExp(r'\D'), '');
    if (cleanEmerPhone.length < 10) {
      return 'Please enter a valid 10-digit Emergency Contact Phone Number';
    }
    if (localAvatarBytes == null && (avatarUrl == null || avatarUrl!.isEmpty)) {
      return 'Please capture or upload your live Driver Selfie/Photo';
    }
    return null;
  }

  String? validateStep2() {
    final cleanPhone = phone.replaceAll(RegExp(r'\D'), '');
    if (cleanPhone.length < 10) {
      return 'Please enter a valid 10-digit mobile number';
    }
    if (!email.contains('@') || !email.contains('.')) {
      return 'Please enter a valid email address';
    }
    if (!isPhoneVerified) {
      return 'Please verify your mobile number with 6-digit OTP code';
    }
    return null;
  }

  String? validateStep3() {
    if (vehicleType != 'Bicycle') {
      if (vehicleNumber.trim().isEmpty) {
        return 'Please enter Vehicle Registration Plate Number';
      }
      if (vehicleModel.trim().isEmpty) {
        return 'Please enter Vehicle Make and Model';
      }
      if (drivingLicenseNumber.trim().length < 6) {
        return 'Please enter a valid Driving License Number';
      }
      if (dlExpiryDate.trim().isEmpty) {
        return 'Please enter Driving License Expiry Date';
      }
      if (dlFrontBytes == null && (dlFrontUrl == null || dlFrontUrl!.isEmpty)) {
        return 'Please upload Driving License Front Side photo';
      }
      if (dlBackBytes == null && (dlBackUrl == null || dlBackUrl!.isEmpty)) {
        return 'Please upload Driving License Back Side photo';
      }
    }
    return null;
  }

  String? validateStep4() {
    final cleanAadhaar = aadhaarNumber.replaceAll(RegExp(r'\D'), '');
    final cleanPan = panNumber.trim().toUpperCase();
    final hasAadhaar = cleanAadhaar.length == 12;
    final hasPan = cleanPan.length == 10;

    if (!hasAadhaar && !hasPan) {
      return 'Please enter either 12-digit Aadhaar Number or 10-character PAN Number';
    }

    final hasAadhaarImg = (aadhaarFrontBytes != null ||
            (aadhaarFrontUrl != null && aadhaarFrontUrl!.isNotEmpty)) &&
        (aadhaarBackBytes != null ||
            (aadhaarBackUrl != null && aadhaarBackUrl!.isNotEmpty));
    final hasPanImg = panCardBytes != null ||
        (panCardUrl != null && panCardUrl!.isNotEmpty);

    if (!hasAadhaarImg && !hasPanImg) {
      return 'Please upload government ID document photos (Aadhaar Front/Back or PAN Card)';
    }
    return null;
  }

  String? validateStep5() {
    if (accountHolderName.trim().isEmpty) {
      return 'Please enter Bank Account Holder Name';
    }
    if (bankAccountNumber.trim().length < 8) {
      return 'Please enter a valid Bank Account Number';
    }
    if (bankAccountNumber.trim() != confirmAccountNumber.trim()) {
      return 'Bank Account Number and Confirm Account Number do not match';
    }
    if (ifscCode.trim().length != 11) {
      return 'Please enter a valid 11-character IFSC Code (e.g. SBIN0001234)';
    }
    if (upiId.trim().isEmpty || !upiId.contains('@')) {
      return 'Please enter a valid UPI ID (e.g. name@okhdfcbank)';
    }
    return null;
  }

  String? validateStep6() {
    if (city.trim().isEmpty) {
      return 'Please enter your Delivery City';
    }
    if (operatingZone.trim().isEmpty) {
      return 'Please enter your Operating Zone / Hub';
    }
    if (formattedAddress.trim().isEmpty) {
      return 'Please locate or enter your base delivery address';
    }
    if (houseFlatNo.trim().isEmpty) {
      return 'Please enter House / Door / Flat Number';
    }
    return null;
  }

  String? validateStep7() {
    if (!locationPermissionGranted) {
      return 'High-Accuracy GPS Location permission is mandatory';
    }
    if (!cameraPermissionGranted) {
      return 'Camera Access permission is mandatory for doorstep delivery photos';
    }
    return null;
  }

  String? validateStep8() {
    if (!hasDeliveryBag) {
      return 'Insulated Food Delivery Bag is required for food safety';
    }
    if (!hasHelmet) {
      return 'Certified Safety Helmet is mandatory for all riders';
    }
    if (!acknowledgedCodeOfConduct) {
      return 'You must accept the Partner Code of Conduct & Guidelines';
    }
    return null;
  }

  bool get isStep1Valid => validateStep1() == null;
  bool get isStep2Valid => validateStep2() == null;
  bool get isStep3Valid => validateStep3() == null;
  bool get isStep4Valid => validateStep4() == null;
  bool get isStep5Valid => validateStep5() == null;
  bool get isStep6Valid => validateStep6() == null;
  bool get isStep7Valid => validateStep7() == null;
  bool get isStep8Valid => validateStep8() == null;

  bool isStepValid(DeliveryVerificationStep step) {
    return validateStep(step) == null;
  }

  int get completedStepsCount {
    int count = 0;
    if (isStep1Valid) count++;
    if (isStep2Valid) count++;
    if (isStep3Valid) count++;
    if (isStep4Valid) count++;
    if (isStep5Valid) count++;
    if (isStep6Valid) count++;
    if (isStep7Valid) count++;
    if (isStep8Valid) count++;
    return count;
  }

  double get overallProgressPercentage => completedStepsCount / 8.0;

  DeliveryOnboardingVerificationState copyWith({
    DeliveryVerificationStep? currentStep,
    DeliveryVerificationStatus? status,
    String? errorMessage,
    String? successMessage,
    bool? isDataFetched,
    String? fullName,
    String? displayName,
    String? dob,
    String? gender,
    String? bloodGroup,
    String? emergencyContactName,
    String? emergencyContactPhone,
    String? avatarUrl,
    Uint8List? localAvatarBytes,
    String? avatarFileName,
    bool? isUploadingAvatar,
    String? bio,
    String? email,
    String? phone,
    String? otpCode,
    bool? isPhoneVerified,
    int? otpCountdown,
    bool? isOtpResendAvailable,
    String? vehicleType,
    String? vehicleNumber,
    String? vehicleModel,
    String? drivingLicenseNumber,
    String? dlExpiryDate,
    Uint8List? dlFrontBytes,
    String? dlFrontUrl,
    Uint8List? dlBackBytes,
    String? dlBackUrl,
    Uint8List? rcBookBytes,
    String? rcBookUrl,
    String? aadhaarNumber,
    String? panNumber,
    Uint8List? aadhaarFrontBytes,
    String? aadhaarFrontUrl,
    Uint8List? aadhaarBackBytes,
    String? aadhaarBackUrl,
    Uint8List? panCardBytes,
    String? panCardUrl,
    String? bankAccountNumber,
    String? confirmAccountNumber,
    String? ifscCode,
    String? bankName,
    String? accountHolderName,
    String? upiId,
    String? payoutFrequency,
    String? city,
    String? operatingZone,
    String? preferredShift,
    String? workType,
    double? deliveryRadiusKm,
    String? formattedAddress,
    String? houseFlatNo,
    String? landmark,
    double? latitude,
    double? longitude,
    bool? isLocatingGps,
    bool? locationPermissionGranted,
    bool? backgroundLocationGranted,
    bool? pushNotificationsGranted,
    cameraPermissionGranted,
    bool? batteryOptimizationDisabled,
    bool? hasDeliveryBag,
    bool? hasHelmet,
    bool? acknowledgedCodeOfConduct,
    String? welcomeBonusCode,
    double? welcomeBonusAmount,
  }) {
    return DeliveryOnboardingVerificationState(
      currentStep: currentStep ?? this.currentStep,
      status: status ?? this.status,
      errorMessage: errorMessage,
      successMessage: successMessage,
      isDataFetched: isDataFetched ?? this.isDataFetched,
      fullName: fullName ?? this.fullName,
      displayName: displayName ?? this.displayName,
      dob: dob ?? this.dob,
      gender: gender ?? this.gender,
      bloodGroup: bloodGroup ?? this.bloodGroup,
      emergencyContactName: emergencyContactName ?? this.emergencyContactName,
      emergencyContactPhone:
          emergencyContactPhone ?? this.emergencyContactPhone,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      localAvatarBytes: localAvatarBytes ?? this.localAvatarBytes,
      avatarFileName: avatarFileName ?? this.avatarFileName,
      isUploadingAvatar: isUploadingAvatar ?? this.isUploadingAvatar,
      bio: bio ?? this.bio,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      otpCode: otpCode ?? this.otpCode,
      isPhoneVerified: isPhoneVerified ?? this.isPhoneVerified,
      otpCountdown: otpCountdown ?? this.otpCountdown,
      isOtpResendAvailable: isOtpResendAvailable ?? this.isOtpResendAvailable,
      vehicleType: vehicleType ?? this.vehicleType,
      vehicleNumber: vehicleNumber ?? this.vehicleNumber,
      vehicleModel: vehicleModel ?? this.vehicleModel,
      drivingLicenseNumber: drivingLicenseNumber ?? this.drivingLicenseNumber,
      dlExpiryDate: dlExpiryDate ?? this.dlExpiryDate,
      dlFrontBytes: dlFrontBytes ?? this.dlFrontBytes,
      dlFrontUrl: dlFrontUrl ?? this.dlFrontUrl,
      dlBackBytes: dlBackBytes ?? this.dlBackBytes,
      dlBackUrl: dlBackUrl ?? this.dlBackUrl,
      rcBookBytes: rcBookBytes ?? this.rcBookBytes,
      rcBookUrl: rcBookUrl ?? this.rcBookUrl,
      aadhaarNumber: aadhaarNumber ?? this.aadhaarNumber,
      panNumber: panNumber ?? this.panNumber,
      aadhaarFrontBytes: aadhaarFrontBytes ?? this.aadhaarFrontBytes,
      aadhaarFrontUrl: aadhaarFrontUrl ?? this.aadhaarFrontUrl,
      aadhaarBackBytes: aadhaarBackBytes ?? this.aadhaarBackBytes,
      aadhaarBackUrl: aadhaarBackUrl ?? this.aadhaarBackUrl,
      panCardBytes: panCardBytes ?? this.panCardBytes,
      panCardUrl: panCardUrl ?? this.panCardUrl,
      bankAccountNumber: bankAccountNumber ?? this.bankAccountNumber,
      confirmAccountNumber: confirmAccountNumber ?? this.confirmAccountNumber,
      ifscCode: ifscCode ?? this.ifscCode,
      bankName: bankName ?? this.bankName,
      accountHolderName: accountHolderName ?? this.accountHolderName,
      upiId: upiId ?? this.upiId,
      payoutFrequency: payoutFrequency ?? this.payoutFrequency,
      city: city ?? this.city,
      operatingZone: operatingZone ?? this.operatingZone,
      preferredShift: preferredShift ?? this.preferredShift,
      workType: workType ?? this.workType,
      deliveryRadiusKm: deliveryRadiusKm ?? this.deliveryRadiusKm,
      formattedAddress: formattedAddress ?? this.formattedAddress,
      houseFlatNo: houseFlatNo ?? this.houseFlatNo,
      landmark: landmark ?? this.landmark,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      isLocatingGps: isLocatingGps ?? this.isLocatingGps,
      locationPermissionGranted:
          locationPermissionGranted ?? this.locationPermissionGranted,
      backgroundLocationGranted:
          backgroundLocationGranted ?? this.backgroundLocationGranted,
      pushNotificationsGranted:
          pushNotificationsGranted ?? this.pushNotificationsGranted,
      cameraPermissionGranted:
          cameraPermissionGranted ?? this.cameraPermissionGranted,
      batteryOptimizationDisabled:
          batteryOptimizationDisabled ?? this.batteryOptimizationDisabled,
      hasDeliveryBag: hasDeliveryBag ?? this.hasDeliveryBag,
      hasHelmet: hasHelmet ?? this.hasHelmet,
      acknowledgedCodeOfConduct:
          acknowledgedCodeOfConduct ?? this.acknowledgedCodeOfConduct,
      welcomeBonusCode: welcomeBonusCode ?? this.welcomeBonusCode,
      welcomeBonusAmount: welcomeBonusAmount ?? this.welcomeBonusAmount,
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
        dob,
        gender,
        bloodGroup,
        emergencyContactName,
        emergencyContactPhone,
        avatarUrl,
        localAvatarBytes,
        avatarFileName,
        isUploadingAvatar,
        bio,
        email,
        phone,
        otpCode,
        isPhoneVerified,
        otpCountdown,
        isOtpResendAvailable,
        vehicleType,
        vehicleNumber,
        vehicleModel,
        drivingLicenseNumber,
        dlExpiryDate,
        dlFrontBytes,
        dlFrontUrl,
        dlBackBytes,
        dlBackUrl,
        rcBookBytes,
        rcBookUrl,
        aadhaarNumber,
        panNumber,
        aadhaarFrontBytes,
        aadhaarFrontUrl,
        aadhaarBackBytes,
        aadhaarBackUrl,
        panCardBytes,
        panCardUrl,
        bankAccountNumber,
        confirmAccountNumber,
        ifscCode,
        bankName,
        accountHolderName,
        upiId,
        payoutFrequency,
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
        isLocatingGps,
        locationPermissionGranted,
        backgroundLocationGranted,
        pushNotificationsGranted,
        cameraPermissionGranted,
        batteryOptimizationDisabled,
        hasDeliveryBag,
        hasHelmet,
        acknowledgedCodeOfConduct,
        welcomeBonusCode,
        welcomeBonusAmount,
      ];
}
