import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'delivery_onboarding_verification_event.dart';
import 'delivery_onboarding_verification_repository.dart';
import 'delivery_onboarding_verification_state.dart';

class DeliveryOnboardingVerificationBloc extends Bloc<
    DeliveryOnboardingVerificationEvent, DeliveryOnboardingVerificationState> {
  final DeliveryOnboardingVerificationRepository _repository;
  Timer? _otpTimer;

  DeliveryOnboardingVerificationBloc({
    DeliveryOnboardingVerificationRepository? repository,
    String? initialFullName,
    String? initialDisplayName,
    String? initialEmail,
    String? initialPhone,
    String? initialAvatarUrl,
    bool initialIsPhoneVerified = false,
  })  : _repository = repository ?? DeliveryOnboardingVerificationRepository(),
        super(DeliveryOnboardingVerificationState(
          fullName: initialFullName ?? '',
          displayName: initialDisplayName ?? '',
          email: initialEmail ?? '',
          phone: initialPhone ?? '',
          avatarUrl: initialAvatarUrl,
          isPhoneVerified: initialIsPhoneVerified,
        )) {
    on<DeliveryVerificationAutoFetchRequested>(_onAutoFetchRequested);
    on<DeliveryVerificationStepChanged>(_onStepChanged);
    on<DeliveryPersonalDetailsChanged>(_onPersonalDetailsChanged);
    on<DeliveryAvatarPicked>(_onAvatarPicked);
    on<DeliveryContactChanged>(_onContactChanged);
    on<DeliverySendPhoneOtpRequested>(_onSendPhoneOtpRequested);
    on<DeliveryVerifyPhoneOtpRequested>(_onVerifyPhoneOtpRequested);
    on<DeliveryOtpTimerTick>(_onOtpTimerTick);
    on<DeliveryVehicleDetailsChanged>(_onVehicleDetailsChanged);
    on<DeliveryDlDocumentPicked>(_onDlDocumentPicked);
    on<DeliveryRcDocumentPicked>(_onRcDocumentPicked);
    on<DeliveryKycDetailsChanged>(_onKycDetailsChanged);
    on<DeliveryKycDocumentPicked>(_onKycDocumentPicked);
    on<DeliveryBankDetailsChanged>(_onBankDetailsChanged);
    on<DeliveryZonePreferencesChanged>(_onZonePreferencesChanged);
    on<DeliveryPermissionsChanged>(_onPermissionsChanged);
    on<DeliverySafetyAndKitChanged>(_onSafetyAndKitChanged);
    on<DeliverySubmitVerificationApplication>(_onSubmitVerificationApplication);
  }

  @override
  Future<void> close() {
    _otpTimer?.cancel();
    return super.close();
  }

  Future<void> _onAutoFetchRequested(
    DeliveryVerificationAutoFetchRequested event,
    Emitter<DeliveryOnboardingVerificationState> emit,
  ) async {
    final uid = _repository.currentUserId;
    if (uid == null) return;

    final data = await _repository.fetchPartnerProfile(uid);
    if (data != null) {
      emit(state.copyWith(
        fullName: data['name'] ?? state.fullName,
        displayName: data['displayName'] ?? state.displayName,
        email: data['email'] ?? state.email,
        phone: data['phone'] ?? state.phone,
        avatarUrl: data['avatarUrl'] ?? state.avatarUrl,
        city: data['city'] ?? state.city,
        operatingZone: data['zone'] ?? state.operatingZone,
        formattedAddress: data['address'] ?? state.formattedAddress,
        latitude: (data['latitude'] as num?)?.toDouble() ?? state.latitude,
        longitude: (data['longitude'] as num?)?.toDouble() ?? state.longitude,
      ));
    }
  }

  void _onStepChanged(
    DeliveryVerificationStepChanged event,
    Emitter<DeliveryOnboardingVerificationState> emit,
  ) {
    emit(state.copyWith(
      currentStep: event.step,
      status: DeliveryVerificationStatus.inProgress,
    ));
  }

  void _onPersonalDetailsChanged(
    DeliveryPersonalDetailsChanged event,
    Emitter<DeliveryOnboardingVerificationState> emit,
  ) {
    emit(state.copyWith(
      fullName: event.fullName,
      displayName: event.displayName,
      dob: event.dob,
      gender: event.gender,
      bloodGroup: event.bloodGroup,
      emergencyContactName: event.emergencyContactName,
      emergencyContactPhone: event.emergencyContactPhone,
      bio: event.bio,
    ));
  }

  void _onAvatarPicked(
    DeliveryAvatarPicked event,
    Emitter<DeliveryOnboardingVerificationState> emit,
  ) {
    emit(state.copyWith(
      localAvatarBytes: event.bytes,
      avatarFileName: event.fileName,
    ));
  }

  void _onContactChanged(
    DeliveryContactChanged event,
    Emitter<DeliveryOnboardingVerificationState> emit,
  ) {
    emit(state.copyWith(
      phone: event.phone,
      email: event.email,
    ));
  }

  Future<void> _onSendPhoneOtpRequested(
    DeliverySendPhoneOtpRequested event,
    Emitter<DeliveryOnboardingVerificationState> emit,
  ) async {
    if (state.phone.trim().length < 10) {
      emit(state.copyWith(
        errorMessage: 'Please enter a valid 10-digit mobile number',
        status: DeliveryVerificationStatus.failure,
      ));
      return;
    }

    emit(state.copyWith(
      status: DeliveryVerificationStatus.otpSent,
      otpCountdown: 30,
      isOtpResendAvailable: false,
    ));

    _otpTimer?.cancel();
    _otpTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      final current = 30 - timer.tick;
      if (current <= 0) {
        timer.cancel();
        add(const DeliveryOtpTimerTick(0));
      } else {
        add(DeliveryOtpTimerTick(current));
      }
    });

    await _repository.sendPhoneOtp(
      state.phone,
      onCodeSent: (id) {},
      onVerificationFailed: (err) {
        add(const DeliveryOtpTimerTick(0));
      },
    );
  }

  void _onOtpTimerTick(
    DeliveryOtpTimerTick event,
    Emitter<DeliveryOnboardingVerificationState> emit,
  ) {
    emit(state.copyWith(
      otpCountdown: event.countdown,
      isOtpResendAvailable: event.countdown <= 0,
    ));
  }

  void _onVerifyPhoneOtpRequested(
    DeliveryVerifyPhoneOtpRequested event,
    Emitter<DeliveryOnboardingVerificationState> emit,
  ) {
    if (event.otpCode.length == 6) {
      _otpTimer?.cancel();
      emit(state.copyWith(
        otpCode: event.otpCode,
        isPhoneVerified: true,
        status: DeliveryVerificationStatus.otpVerified,
        successMessage: 'Phone number verified successfully',
      ));
    } else {
      emit(state.copyWith(
        errorMessage: 'Please enter a valid 6-digit verification code',
        status: DeliveryVerificationStatus.failure,
      ));
    }
  }

  void _onVehicleDetailsChanged(
    DeliveryVehicleDetailsChanged event,
    Emitter<DeliveryOnboardingVerificationState> emit,
  ) {
    emit(state.copyWith(
      vehicleType: event.vehicleType,
      vehicleNumber: event.vehicleNumber,
      vehicleModel: event.vehicleModel,
      drivingLicenseNumber: event.drivingLicenseNumber,
      dlExpiryDate: event.dlExpiryDate,
    ));
  }

  void _onDlDocumentPicked(
    DeliveryDlDocumentPicked event,
    Emitter<DeliveryOnboardingVerificationState> emit,
  ) {
    if (event.isFront) {
      emit(state.copyWith(dlFrontBytes: event.bytes));
    } else {
      emit(state.copyWith(dlBackBytes: event.bytes));
    }
  }

  void _onRcDocumentPicked(
    DeliveryRcDocumentPicked event,
    Emitter<DeliveryOnboardingVerificationState> emit,
  ) {
    emit(state.copyWith(rcBookBytes: event.bytes));
  }

  void _onKycDetailsChanged(
    DeliveryKycDetailsChanged event,
    Emitter<DeliveryOnboardingVerificationState> emit,
  ) {
    emit(state.copyWith(
      aadhaarNumber: event.aadhaarNumber,
      panNumber: event.panNumber,
    ));
  }

  void _onKycDocumentPicked(
    DeliveryKycDocumentPicked event,
    Emitter<DeliveryOnboardingVerificationState> emit,
  ) {
    if (event.docType == 'aadhaar') {
      if (event.isFront) {
        emit(state.copyWith(aadhaarFrontBytes: event.bytes));
      } else {
        emit(state.copyWith(aadhaarBackBytes: event.bytes));
      }
    } else if (event.docType == 'pan') {
      emit(state.copyWith(panCardBytes: event.bytes));
    }
  }

  void _onBankDetailsChanged(
    DeliveryBankDetailsChanged event,
    Emitter<DeliveryOnboardingVerificationState> emit,
  ) {
    emit(state.copyWith(
      bankAccountNumber: event.bankAccountNumber,
      confirmAccountNumber: event.confirmAccountNumber,
      ifscCode: event.ifscCode,
      bankName: event.bankName,
      accountHolderName: event.accountHolderName,
      upiId: event.upiId,
      payoutFrequency: event.payoutFrequency,
    ));
  }

  void _onZonePreferencesChanged(
    DeliveryZonePreferencesChanged event,
    Emitter<DeliveryOnboardingVerificationState> emit,
  ) {
    emit(state.copyWith(
      city: event.city,
      operatingZone: event.operatingZone,
      preferredShift: event.preferredShift,
      workType: event.workType,
      deliveryRadiusKm: event.deliveryRadiusKm,
      formattedAddress: event.formattedAddress,
      houseFlatNo: event.houseFlatNo,
      landmark: event.landmark,
      latitude: event.latitude,
      longitude: event.longitude,
    ));
  }

  void _onPermissionsChanged(
    DeliveryPermissionsChanged event,
    Emitter<DeliveryOnboardingVerificationState> emit,
  ) {
    emit(state.copyWith(
      locationPermissionGranted: event.locationPermissionGranted,
      backgroundLocationGranted: event.backgroundLocationGranted,
      pushNotificationsGranted: event.pushNotificationsGranted,
      cameraPermissionGranted: event.cameraPermissionGranted,
      batteryOptimizationDisabled: event.batteryOptimizationDisabled,
    ));
  }

  void _onSafetyAndKitChanged(
    DeliverySafetyAndKitChanged event,
    Emitter<DeliveryOnboardingVerificationState> emit,
  ) {
    emit(state.copyWith(
      hasDeliveryBag: event.hasDeliveryBag,
      hasHelmet: event.hasHelmet,
      acknowledgedCodeOfConduct: event.acknowledgedCodeOfConduct,
    ));
  }

  Future<void> _onSubmitVerificationApplication(
    DeliverySubmitVerificationApplication event,
    Emitter<DeliveryOnboardingVerificationState> emit,
  ) async {
    final uid = _repository.currentUserId ?? 'delivery_${DateTime.now().millisecondsSinceEpoch}';

    emit(state.copyWith(status: DeliveryVerificationStatus.uploadingFiles));

    try {
      String? uploadedAvatarUrl = state.avatarUrl;
      String? uploadedDlFrontUrl = state.dlFrontUrl;
      String? uploadedDlBackUrl = state.dlBackUrl;
      String? uploadedRcUrl = state.rcBookUrl;
      String? uploadedAadhaarFrontUrl = state.aadhaarFrontUrl;
      String? uploadedAadhaarBackUrl = state.aadhaarBackUrl;
      String? uploadedPanUrl = state.panCardUrl;

      // 1. Upload Avatar if local bytes exist
      if (state.localAvatarBytes != null) {
        uploadedAvatarUrl = await _repository.uploadDocumentBytes(
          uid,
          'avatars',
          state.avatarFileName ?? 'avatar.jpg',
          state.localAvatarBytes!,
        );
      }

      // 2. Upload DL Front / Back
      if (state.dlFrontBytes != null) {
        uploadedDlFrontUrl = await _repository.uploadDocumentBytes(
          uid,
          'driving_license',
          'dl_front.jpg',
          state.dlFrontBytes!,
        );
      }
      if (state.dlBackBytes != null) {
        uploadedDlBackUrl = await _repository.uploadDocumentBytes(
          uid,
          'driving_license',
          'dl_back.jpg',
          state.dlBackBytes!,
        );
      }

      // 3. Upload RC Book
      if (state.rcBookBytes != null) {
        uploadedRcUrl = await _repository.uploadDocumentBytes(
          uid,
          'vehicle_rc',
          'rc_book.jpg',
          state.rcBookBytes!,
        );
      }

      // 4. Upload Aadhaar & PAN
      if (state.aadhaarFrontBytes != null) {
        uploadedAadhaarFrontUrl = await _repository.uploadDocumentBytes(
          uid,
          'government_id',
          'aadhaar_front.jpg',
          state.aadhaarFrontBytes!,
        );
      }
      if (state.aadhaarBackBytes != null) {
        uploadedAadhaarBackUrl = await _repository.uploadDocumentBytes(
          uid,
          'government_id',
          'aadhaar_back.jpg',
          state.aadhaarBackBytes!,
        );
      }
      if (state.panCardBytes != null) {
        uploadedPanUrl = await _repository.uploadDocumentBytes(
          uid,
          'tax_id',
          'pan_card.jpg',
          state.panCardBytes!,
        );
      }

      // 5. Submit Complete Firestore Application
      final payload = {
        'fullName': state.fullName,
        'displayName': state.displayName.isEmpty ? state.fullName : state.displayName,
        'dob': state.dob,
        'gender': state.gender,
        'bloodGroup': state.bloodGroup,
        'emergencyContactName': state.emergencyContactName,
        'emergencyContactPhone': state.emergencyContactPhone,
        'avatarUrl': uploadedAvatarUrl,
        'bio': state.bio,
        'email': state.email,
        'phone': state.phone,
        'isPhoneVerified': state.isPhoneVerified,
        'city': state.city,
        'operatingZone': state.operatingZone,
        'preferredShift': state.preferredShift,
        'workType': state.workType,
        'deliveryRadiusKm': state.deliveryRadiusKm,
        'formattedAddress': state.formattedAddress,
        'houseFlatNo': state.houseFlatNo,
        'landmark': state.landmark,
        'latitude': state.latitude,
        'longitude': state.longitude,
        'welcomeBonusCode': state.welcomeBonusCode,
        'vehicleType': state.vehicleType,
        'vehicleNumber': state.vehicleNumber,
        'vehicleModel': state.vehicleModel,
        'drivingLicenseNumber': state.drivingLicenseNumber,
        'dlExpiryDate': state.dlExpiryDate,
        'dlFrontUrl': uploadedDlFrontUrl,
        'dlBackUrl': uploadedDlBackUrl,
        'rcBookUrl': uploadedRcUrl,
        'aadhaarNumber': state.aadhaarNumber,
        'panNumber': state.panNumber,
        'aadhaarFrontUrl': uploadedAadhaarFrontUrl,
        'aadhaarBackUrl': uploadedAadhaarBackUrl,
        'panCardUrl': uploadedPanUrl,
        'bankAccountNumber': state.bankAccountNumber,
        'ifscCode': state.ifscCode,
        'bankName': state.bankName,
        'accountHolderName': state.accountHolderName.isEmpty ? state.fullName : state.accountHolderName,
        'upiId': state.upiId,
        'payoutFrequency': state.payoutFrequency,
      };

      await _repository.submitFullKycApplication(uid, payload);

      emit(state.copyWith(
        status: DeliveryVerificationStatus.success,
        successMessage:
            'Your Delivery Partner verification application has been submitted successfully! Our verification team will review your KYC documents within 24 hours.',
      ));
    } catch (e) {
      emit(state.copyWith(
        status: DeliveryVerificationStatus.failure,
        errorMessage: 'Failed to submit verification application: ${e.toString()}',
      ));
    }
  }
}
