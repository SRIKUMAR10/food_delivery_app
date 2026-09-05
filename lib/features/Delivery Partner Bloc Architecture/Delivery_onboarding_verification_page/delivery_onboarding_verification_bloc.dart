import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'delivery_onboarding_verification_event.dart';
import 'delivery_onboarding_verification_repository.dart';
import 'delivery_onboarding_verification_state.dart';

class DeliveryOnboardingVerificationBloc extends Bloc<
    DeliveryOnboardingVerificationEvent, DeliveryOnboardingVerificationState> {
  final DeliveryOnboardingVerificationRepository _repository;
  Timer? _otpTimer;
  StreamSubscription<Map<String, dynamic>>? _profileSubscription;

  DeliveryOnboardingVerificationBloc({
    DeliveryOnboardingVerificationRepository? repository,
    DeliveryVerificationStep? initialStep,
    String? initialFullName,
    String? initialDisplayName,
    String? initialEmail,
    String? initialPhone,
    String? initialAvatarUrl,
    bool initialIsPhoneVerified = false,
  })  : _repository = repository ?? DeliveryOnboardingVerificationRepository(),
        super(DeliveryOnboardingVerificationState(
          currentStep: initialStep ?? DeliveryVerificationStep.personalDetails,
          fullName: initialFullName ?? '',
          displayName: initialDisplayName ?? '',
          email: initialEmail ?? '',
          phone: initialPhone ?? '',
          avatarUrl: initialAvatarUrl,
          isPhoneVerified: initialIsPhoneVerified,
        )) {
    on<DeliveryVerificationAutoFetchRequested>(_onAutoFetchRequested);
    on<DeliveryVerificationProfileStreamUpdated>(_onProfileStreamUpdated);
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
    _profileSubscription?.cancel();
    return super.close();
  }

  void _onProfileStreamUpdated(
    DeliveryVerificationProfileStreamUpdated event,
    Emitter<DeliveryOnboardingVerificationState> emit,
  ) {
    final data = event.data;
    if (data.isEmpty) return;

    final rawName = data['name'] ?? data['fullName'] ?? data['displayName'] ?? '';
    final rawDisplay = data['displayName'] ?? data['name'] ?? data['fullName'] ?? '';

    final newFullName = rawName.toString().trim().isNotEmpty
        ? rawName.toString().trim()
        : state.fullName;
    final newDisplayName = rawDisplay.toString().trim().isNotEmpty
        ? rawDisplay.toString().trim()
        : (newFullName.isNotEmpty ? newFullName : state.displayName);

    emit(state.copyWith(
      fullName: newFullName,
      displayName: newDisplayName,
      email: (data['email'] as String?)?.isNotEmpty == true
          ? data['email']
          : state.email,
      phone: (data['phone'] as String?)?.isNotEmpty == true
          ? data['phone']
          : ((data['phoneNumber'] as String?)?.isNotEmpty == true
              ? data['phoneNumber']
              : state.phone),
      avatarUrl: data['avatarUrl'] ?? data['photoUrl'] ?? state.avatarUrl,
      dob: data['dob'] ?? state.dob,
      gender: data['gender'] ?? state.gender,
      bloodGroup: data['bloodGroup'] ?? state.bloodGroup,
      emergencyContactName: data['emergencyContactName'] ??
          (data['emergencyContact'] is Map ? data['emergencyContact']['name'] : null) ??
          state.emergencyContactName,
      emergencyContactPhone: data['emergencyContactPhone'] ??
          (data['emergencyContact'] is Map ? data['emergencyContact']['phone'] : null) ??
          state.emergencyContactPhone,
      bio: data['bio'] ?? state.bio,
      city: data['city'] ?? state.city,
      operatingZone: data['zone'] ?? data['operatingZone'] ?? state.operatingZone,
      vehicleType: data['vehicleType'] ?? state.vehicleType,
      vehicleNumber: data['vehicleNumber'] ?? state.vehicleNumber,
      vehicleModel: data['vehicleModel'] ?? state.vehicleModel,
      drivingLicenseNumber: data['drivingLicenseNumber'] ??
          data['drivingLicense'] ??
          state.drivingLicenseNumber,
      dlExpiryDate: data['dlExpiryDate'] ??
          data['licenseValidTill'] ??
          data['drivingLicenseExpiry'] ??
          data['licenseExpiryDate'] ??
          data['licenseExpiry'] ??
          data['dlExpiry'] ??
          data['expiryDate'] ??
          data['validTill'] ??
          state.dlExpiryDate,
      dlFrontUrl: data['dlFrontUrl'] ?? state.dlFrontUrl,
      dlBackUrl: data['dlBackUrl'] ?? state.dlBackUrl,
      rcBookUrl: data['rcBookUrl'] ?? data['vehicleRcUrl'] ?? state.rcBookUrl,
      aadhaarNumber: data['aadhaarNumber'] ?? state.aadhaarNumber,
      panNumber: data['panNumber'] ?? state.panNumber,
      aadhaarFrontUrl: data['aadhaarFrontUrl'] ??
          data['aadhaarUrl'] ??
          data['idProofUrl'] ??
          state.aadhaarFrontUrl,
      aadhaarBackUrl: data['aadhaarBackUrl'] ?? state.aadhaarBackUrl,
      panCardUrl: data['panCardUrl'] ?? state.panCardUrl,
      bankAccountNumber: data['bankAccountNumber'] ?? state.bankAccountNumber,
      confirmAccountNumber: data['confirmAccountNumber'] ??
          data['bankAccountNumber'] ??
          state.confirmAccountNumber,
      ifscCode: data['ifscCode'] ?? state.ifscCode,
      bankName: data['bankName'] ?? state.bankName,
      accountHolderName: data['accountHolderName'] ?? state.accountHolderName,
      upiId: data['upiId'] ?? state.upiId,
      payoutFrequency: data['payoutFrequency'] ?? state.payoutFrequency,
    ));
  }

  Future<void> _onAutoFetchRequested(
    DeliveryVerificationAutoFetchRequested event,
    Emitter<DeliveryOnboardingVerificationState> emit,
  ) async {
    var uid = _repository.currentUserId;
    if (uid == null) {
      final user = await _repository.waitForCurrentUser();
      uid = user?.uid;
    }
    if (uid == null) {
      emit(state.copyWith(isDataFetched: true));
      return;
    }

    final data = await _repository.fetchPartnerProfile(uid);
    if (data != null) {
      final rawName = data['name'] ?? data['fullName'] ?? data['displayName'] ?? '';
      final rawDisplay = data['displayName'] ?? data['name'] ?? data['fullName'] ?? '';

      final newFullName = rawName.toString().trim().isNotEmpty
          ? rawName.toString().trim()
          : state.fullName;
      final newDisplayName = rawDisplay.toString().trim().isNotEmpty
          ? rawDisplay.toString().trim()
          : (newFullName.isNotEmpty ? newFullName : state.displayName);

      emit(state.copyWith(
        isDataFetched: true,
        fullName: newFullName,
        displayName: newDisplayName,
        email: (data['email'] as String?)?.isNotEmpty == true
            ? data['email']
            : state.email,
        phone: (data['phone'] as String?)?.isNotEmpty == true
            ? data['phone']
            : ((data['phoneNumber'] as String?)?.isNotEmpty == true
                ? data['phoneNumber']
                : state.phone),
        avatarUrl: data['avatarUrl'] ?? data['photoUrl'] ?? state.avatarUrl,
        dob: data['dob'] ?? state.dob,
        gender: data['gender'] ?? state.gender,
        bloodGroup: data['bloodGroup'] ?? state.bloodGroup,
        emergencyContactName: data['emergencyContactName'] ?? state.emergencyContactName,
        emergencyContactPhone: data['emergencyContactPhone'] ?? state.emergencyContactPhone,
        bio: data['bio'] ?? state.bio,
        vehicleType: data['vehicleType'] ?? state.vehicleType,
        vehicleNumber: data['vehicleNumber'] ?? state.vehicleNumber,
        vehicleModel: data['vehicleModel'] ?? state.vehicleModel,
        drivingLicenseNumber: data['drivingLicenseNumber'] ?? data['drivingLicense'] ?? state.drivingLicenseNumber,
        dlExpiryDate: data['dlExpiryDate'] ??
            data['licenseValidTill'] ??
            data['drivingLicenseExpiry'] ??
            data['licenseExpiryDate'] ??
            data['licenseExpiry'] ??
            data['dlExpiry'] ??
            data['expiryDate'] ??
            data['validTill'] ??
            state.dlExpiryDate,
        dlFrontUrl: data['dlFrontUrl'] ?? state.dlFrontUrl,
        dlBackUrl: data['dlBackUrl'] ?? state.dlBackUrl,
        rcBookUrl: data['rcBookUrl'] ?? state.rcBookUrl,
        aadhaarNumber: data['aadhaarNumber'] ?? state.aadhaarNumber,
        panNumber: data['panNumber'] ?? state.panNumber,
        aadhaarFrontUrl: data['aadhaarFrontUrl'] ?? state.aadhaarFrontUrl,
        aadhaarBackUrl: data['aadhaarBackUrl'] ?? state.aadhaarBackUrl,
        panCardUrl: data['panCardUrl'] ?? state.panCardUrl,
        bankAccountNumber: data['bankAccountNumber'] ?? state.bankAccountNumber,
        confirmAccountNumber: data['confirmAccountNumber'] ?? data['bankAccountNumber'] ?? state.confirmAccountNumber,
        ifscCode: data['ifscCode'] ?? state.ifscCode,
        bankName: data['bankName'] ?? state.bankName,
        accountHolderName: data['accountHolderName'] ?? state.accountHolderName,
        upiId: data['upiId'] ?? state.upiId,
        payoutFrequency: data['payoutFrequency'] ?? state.payoutFrequency,
        city: data['city'] ?? state.city,
        operatingZone: data['zone'] ?? data['operatingZone'] ?? state.operatingZone,
        preferredShift: data['preferredShift'] ?? state.preferredShift,
        workType: data['workType'] ?? state.workType,
        deliveryRadiusKm: (data['deliveryRadiusKm'] as num?)?.toDouble() ?? state.deliveryRadiusKm,
        formattedAddress: data['address'] ?? data['formattedAddress'] ?? state.formattedAddress,
        houseFlatNo: data['houseFlatNo'] ?? state.houseFlatNo,
        landmark: data['landmark'] ?? state.landmark,
        latitude: (data['latitude'] as num?)?.toDouble() ?? state.latitude,
        longitude: (data['longitude'] as num?)?.toDouble() ?? state.longitude,
        isPhoneVerified: data['isPhoneVerified'] == true ? true : (data['phone'] != null && (data['phone'] as String).isNotEmpty ? true : state.isPhoneVerified),
      ));
    } else {
      emit(state.copyWith(isDataFetched: true));
    }

    _profileSubscription?.cancel();
    _profileSubscription = _repository.watchPartnerProfile(uid).listen((liveData) {
      if (liveData.isNotEmpty) {
        add(DeliveryVerificationProfileStreamUpdated(liveData));
      }
    });
  }

  void _saveDraft() {
    final uid = _repository.currentUserId;
    if (uid != null) {
      _repository.saveDraftState(uid, {
        'name': state.fullName,
        'fullName': state.fullName,
        'displayName': state.displayName.isEmpty ? state.fullName : state.displayName,
        'dob': state.dob,
        'gender': state.gender,
        'bloodGroup': state.bloodGroup,
        'emergencyContactName': state.emergencyContactName,
        'emergencyContactPhone': state.emergencyContactPhone,
        'emergencyContact': {
          'name': state.emergencyContactName,
          'phone': state.emergencyContactPhone,
        },
        'avatarUrl': state.avatarUrl,
        'photoUrl': state.avatarUrl,
        'bio': state.bio,
        'email': state.email,
        'phone': state.phone,
        'vehicleType': state.vehicleType,
        'vehicleNumber': state.vehicleNumber,
        'vehicleModel': state.vehicleModel,
        'drivingLicenseNumber': state.drivingLicenseNumber,
        'drivingLicense': state.drivingLicenseNumber,
        'dlExpiryDate': state.dlExpiryDate,
        'licenseValidTill': state.dlExpiryDate,
        'dlFrontUrl': state.dlFrontUrl,
        'dlBackUrl': state.dlBackUrl,
        'rcBookUrl': state.rcBookUrl,
        'vehicleRcUrl': state.rcBookUrl,
        'aadhaarNumber': state.aadhaarNumber,
        'panNumber': state.panNumber,
        'aadhaarFrontUrl': state.aadhaarFrontUrl,
        'aadhaarBackUrl': state.aadhaarBackUrl,
        'aadhaarUrl': state.aadhaarFrontUrl,
        'idProofUrl': state.aadhaarFrontUrl,
        'panCardUrl': state.panCardUrl,
        'bankAccountNumber': state.bankAccountNumber,
        'ifscCode': state.ifscCode,
        'bankName': state.bankName,
        'accountHolderName': state.accountHolderName,
        'upiId': state.upiId,
        'payoutFrequency': state.payoutFrequency,
        'city': state.city,
        'zone': state.operatingZone,
        'operatingZone': state.operatingZone,
        'preferredShift': state.preferredShift,
        'workType': state.workType,
        'deliveryRadiusKm': state.deliveryRadiusKm,
        'address': state.formattedAddress,
        'formattedAddress': state.formattedAddress,
        'houseFlatNo': state.houseFlatNo,
        'landmark': state.landmark,
        'latitude': state.latitude,
        'longitude': state.longitude,
        'currentStepIndex': state.currentStep.index,
      });
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
    _saveDraft();
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
    _saveDraft();
  }

  Future<void> _onAvatarPicked(
    DeliveryAvatarPicked event,
    Emitter<DeliveryOnboardingVerificationState> emit,
  ) async {
    // 1. Instant local display
    emit(state.copyWith(
      localAvatarBytes: event.bytes,
      avatarFileName: event.fileName,
      isUploadingAvatar: true,
    ));

    // 2. Real-time Firebase Storage upload and Firestore sync
    final uid = _repository.currentUserId;
    if (uid != null) {
      try {
        final downloadUrl = await _repository.uploadDocumentBytes(
          uid,
          'avatars',
          event.fileName.isNotEmpty ? event.fileName : 'avatar.jpg',
          event.bytes,
        );
        if (downloadUrl != null && downloadUrl.isNotEmpty) {
          emit(state.copyWith(
            avatarUrl: downloadUrl,
            isUploadingAvatar: false,
          ));
          await _repository.saveDocumentUrl(uid, 'avatarUrl', downloadUrl);
          _saveDraft();
        } else {
          emit(state.copyWith(isUploadingAvatar: false));
        }
      } catch (_) {
        emit(state.copyWith(isUploadingAvatar: false));
      }
    } else {
      emit(state.copyWith(isUploadingAvatar: false));
    }
  }

  void _onContactChanged(
    DeliveryContactChanged event,
    Emitter<DeliveryOnboardingVerificationState> emit,
  ) {
    emit(state.copyWith(
      phone: event.phone,
      email: event.email,
    ));
    _saveDraft();
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
    _saveDraft();
  }

  Future<void> _onDlDocumentPicked(
    DeliveryDlDocumentPicked event,
    Emitter<DeliveryOnboardingVerificationState> emit,
  ) async {
    // 1. Instant local preview
    if (event.isFront) {
      emit(state.copyWith(dlFrontBytes: event.bytes));
    } else {
      emit(state.copyWith(dlBackBytes: event.bytes));
    }

    // 2. Real-time Firebase Storage upload and Firestore persistence
    final uid = _repository.currentUserId;
    if (uid != null) {
      try {
        final folder = 'driving_license';
        final fileName = event.isFront ? 'dl_front.jpg' : 'dl_back.jpg';
        final downloadUrl = await _repository.uploadDocumentBytes(
          uid,
          folder,
          fileName,
          event.bytes,
        );
        if (downloadUrl != null && downloadUrl.isNotEmpty) {
          if (event.isFront) {
            emit(state.copyWith(dlFrontUrl: downloadUrl));
            await _repository.saveDocumentUrl(uid, 'dlFrontUrl', downloadUrl);
          } else {
            emit(state.copyWith(dlBackUrl: downloadUrl));
            await _repository.saveDocumentUrl(uid, 'dlBackUrl', downloadUrl);
          }
          _saveDraft();
        }
      } catch (_) {}
    }
  }

  Future<void> _onRcDocumentPicked(
    DeliveryRcDocumentPicked event,
    Emitter<DeliveryOnboardingVerificationState> emit,
  ) async {
    // 1. Instant local preview
    emit(state.copyWith(rcBookBytes: event.bytes));

    // 2. Real-time Firebase Storage upload and Firestore persistence
    final uid = _repository.currentUserId;
    if (uid != null) {
      try {
        final downloadUrl = await _repository.uploadDocumentBytes(
          uid,
          'vehicle_rc',
          event.fileName.isNotEmpty ? event.fileName : 'rc_book.jpg',
          event.bytes,
        );
        if (downloadUrl != null && downloadUrl.isNotEmpty) {
          emit(state.copyWith(rcBookUrl: downloadUrl));
          await _repository.saveDocumentUrl(uid, 'rcBookUrl', downloadUrl);
          _saveDraft();
        }
      } catch (_) {}
    }
  }

  void _onKycDetailsChanged(
    DeliveryKycDetailsChanged event,
    Emitter<DeliveryOnboardingVerificationState> emit,
  ) {
    emit(state.copyWith(
      aadhaarNumber: event.aadhaarNumber,
      panNumber: event.panNumber,
    ));
    _saveDraft();
  }

  Future<void> _onKycDocumentPicked(
    DeliveryKycDocumentPicked event,
    Emitter<DeliveryOnboardingVerificationState> emit,
  ) async {
    // 1. Instant local preview
    if (event.docType == 'aadhaar') {
      if (event.isFront) {
        emit(state.copyWith(aadhaarFrontBytes: event.bytes));
      } else {
        emit(state.copyWith(aadhaarBackBytes: event.bytes));
      }
    } else if (event.docType == 'pan') {
      emit(state.copyWith(panCardBytes: event.bytes));
    }

    // 2. Real-time Firebase Storage upload and Firestore persistence
    final uid = _repository.currentUserId;
    if (uid != null) {
      try {
        final folder = event.docType == 'aadhaar' ? 'government_id' : 'tax_id';
        final fileName = event.docType == 'aadhaar'
            ? (event.isFront ? 'aadhaar_front.jpg' : 'aadhaar_back.jpg')
            : 'pan_card.jpg';

        final downloadUrl = await _repository.uploadDocumentBytes(
          uid,
          folder,
          fileName,
          event.bytes,
        );
        if (downloadUrl != null && downloadUrl.isNotEmpty) {
          if (event.docType == 'aadhaar') {
            if (event.isFront) {
              emit(state.copyWith(aadhaarFrontUrl: downloadUrl));
              await _repository.saveDocumentUrl(uid, 'aadhaarFrontUrl', downloadUrl);
            } else {
              emit(state.copyWith(aadhaarBackUrl: downloadUrl));
              await _repository.saveDocumentUrl(uid, 'aadhaarBackUrl', downloadUrl);
            }
          } else if (event.docType == 'pan') {
            emit(state.copyWith(panCardUrl: downloadUrl));
            await _repository.saveDocumentUrl(uid, 'panCardUrl', downloadUrl);
          }
          _saveDraft();
        }
      } catch (_) {}
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
    _saveDraft();
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
    _saveDraft();
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
    _saveDraft();
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
    _saveDraft();
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
        'drivingLicense': state.drivingLicenseNumber,
        'dlExpiryDate': state.dlExpiryDate,
        'licenseValidTill': state.dlExpiryDate,
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
        avatarUrl: uploadedAvatarUrl,
        dlFrontUrl: uploadedDlFrontUrl,
        dlBackUrl: uploadedDlBackUrl,
        rcBookUrl: uploadedRcUrl,
        aadhaarFrontUrl: uploadedAadhaarFrontUrl,
        aadhaarBackUrl: uploadedAadhaarBackUrl,
        panCardUrl: uploadedPanUrl,
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
