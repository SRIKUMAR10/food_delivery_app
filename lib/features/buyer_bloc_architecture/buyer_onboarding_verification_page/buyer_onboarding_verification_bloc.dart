import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image/image.dart' as img;
import 'package:food_delivery_app/core/utils/app_exception_formatter.dart';
import 'package:food_delivery_app/core/services/google_places_service.dart';
import 'buyer_onboarding_verification_event.dart';
import 'buyer_onboarding_verification_state.dart';
import 'buyer_onboarding_verification_repository.dart';

class BuyerOnboardingVerificationBloc
    extends Bloc<BuyerOnboardingVerificationEvent, BuyerOnboardingVerificationState> {
  final IBuyerOnboardingVerificationRepository repository;
  final FirebaseAuth auth;
  final ImagePicker? imagePicker;
  Timer? _otpTimer;

  BuyerOnboardingVerificationBloc({
    IBuyerOnboardingVerificationRepository? repository,
    FirebaseAuth? auth,
    ImagePicker? imagePicker,
    String? initialFullName,
    String? initialDisplayName,
    String? initialEmail,
    String? initialPhone,
    String? initialAvatarUrl,
    bool initialIsPhoneVerified = false,
  })  : repository = repository ?? BuyerOnboardingVerificationRepository(),
        auth = auth ?? FirebaseAuth.instance,
        imagePicker = imagePicker,
        super(BuyerOnboardingVerificationState(
          fullName: initialFullName ?? '',
          displayName: initialDisplayName ?? initialFullName ?? '',
          email: initialEmail ?? '',
          phone: initialPhone ?? '',
          avatarUrl: initialAvatarUrl,
          isPhoneVerified: initialIsPhoneVerified || (initialPhone != null && initialPhone.isNotEmpty),
        )) {
    on<BuyerVerificationPrefillRequested>(_onPrefillRequested);
    on<BuyerVerificationAutoFetchRequested>(_onAutoFetchRequested);
    on<BuyerVerificationStepChanged>(_onStepChanged);
    on<BuyerVerificationNextStepPressed>(_onNextStepPressed);
    on<BuyerVerificationPreviousStepPressed>(_onPreviousStepPressed);
    on<BuyerAvatarPickRequested>(_onAvatarPickRequested);
    on<BuyerAvatarRemoved>(_onAvatarRemoved);
    on<BuyerPersonalDetailsUpdated>(_onPersonalDetailsUpdated);
    on<BuyerContactUpdated>(_onContactUpdated);
    on<BuyerSendOtpRequested>(_onSendOtpRequested);
    on<BuyerOtpCodeChanged>(_onOtpCodeChanged);
    on<BuyerVerifyOtpPressed>(_onVerifyOtpPressed);
    on<BuyerOtpTimerTicked>(_onOtpTimerTicked);
    on<BuyerAddressUpdated>(_onAddressUpdated);
    on<BuyerAddressTagChanged>(_onAddressTagChanged);
    on<BuyerAddressLocationSelected>(_onAddressLocationSelected);
    on<BuyerCurrentLocationRequested>(_onCurrentLocationRequested);
    on<BuyerPaymentMethodChanged>(_onPaymentMethodChanged);
    on<BuyerWalletToggled>(_onWalletToggled);
    on<BuyerPaymentPreferenceSelected>(_onPaymentPreferenceSelected);
    on<BuyerSinglePermissionToggled>(_onSinglePermissionToggled);
    on<BuyerPermissionsUpdated>(_onPermissionsUpdated);
    on<BuyerCompleteVerificationSubmitted>(_onCompleteVerificationSubmitted);
  }

  Future<void> _onAutoFetchRequested(
    BuyerVerificationAutoFetchRequested event,
    Emitter<BuyerOnboardingVerificationState> emit,
  ) async {
    var uid = auth.currentUser?.uid;
    if (uid == null || uid.isEmpty) {
      final user = await repository.waitForCurrentUser();
      uid = user?.uid;
    }
    if (uid == null || uid.isEmpty) {
      emit(state.copyWith(isDataFetched: true));
      return;
    }

    try {
      final data = await repository.getCurrentUserVerificationData(uid);
      if (data.isNotEmpty) {
        final name = (data['fullName'] ?? data['name'] ?? data['displayName'] ?? '').toString().trim();
        final displayName = (data['displayName'] ?? data['name'] ?? '').toString().trim();
        final email = (data['email'] ?? data['emailAddress'] ?? '').toString().trim();
        final phone = (data['phone'] ?? data['phoneNumber'] ?? data['mobile'] ?? '').toString().trim();
        final imageUrl = (data['imageUrl'] ?? data['photoUrl'] ?? data['profilePic'] ?? data['avatarUrl']) as String?;
        final bio = (data['bio'] ?? '').toString().trim();
        final isPhoneVerified = data['isPhoneVerified'] == true || phone.isNotEmpty;
        final locationPermission = data['locationPermissionGranted'] as bool? ??
            (data['permissions'] is Map ? data['permissions']['location'] as bool? : null);
        final notificationsPermission = data['pushNotificationsGranted'] as bool? ??
            (data['permissions'] is Map ? data['permissions']['pushNotifications'] as bool? : null);
        final cameraPermission = data['cameraPermissionGranted'] as bool? ??
            (data['permissions'] is Map ? data['permissions']['camera'] as bool? : null);

        final address = (data['address'] ?? data['deliveryAddress'] ?? data['fullAddress'] ?? data['formattedAddress'] ?? '').toString().trim();
        final houseFlatNo = (data['houseFlatNo'] ?? data['flatNo'] ?? '').toString().trim();
        final landmark = (data['landmark'] ?? data['nearbyLandmark'] ?? '').toString().trim();
        final selectedTag = (data['selectedAddressType'] ?? data['addressTag'] ?? data['tag'] ?? '').toString().trim();
        final lat = (data['latitude'] as num?)?.toDouble() ?? (data['lat'] as num?)?.toDouble();
        final lng = (data['longitude'] as num?)?.toDouble() ?? (data['lng'] as num?)?.toDouble();

        final preferredPayment = (data['preferredPaymentMethod'] ?? data['paymentMethod'] ?? '').toString().trim();
        final defaultUpi = (data['defaultUpiId'] ?? data['upiId']) as String?;
        final activateWallet = data['activateBuyerWallet'] as bool?;

        emit(state.copyWith(
          isDataFetched: true,
          fullName: state.fullName.isEmpty ? name : state.fullName,
          displayName: state.displayName.isEmpty ? (displayName.isNotEmpty ? displayName : name) : state.displayName,
          bio: state.bio.isEmpty ? bio : state.bio,
          email: state.email.isEmpty ? email : state.email,
          phone: state.phone.isEmpty ? phone : state.phone,
          avatarUrl: state.avatarUrl ?? imageUrl,
          isPhoneVerified: state.isPhoneVerified || isPhoneVerified,
          formattedAddress: state.formattedAddress.isEmpty ? address : state.formattedAddress,
          houseFlatNo: state.houseFlatNo.isEmpty ? houseFlatNo : state.houseFlatNo,
          landmark: state.landmark.isEmpty ? landmark : state.landmark,
          addressTag: selectedTag.isNotEmpty ? selectedTag : state.addressTag,
          latitude: state.latitude ?? lat,
          longitude: state.longitude ?? lng,
          preferredPaymentMethod: preferredPayment.isNotEmpty ? preferredPayment : state.preferredPaymentMethod,
          defaultUpiId: state.defaultUpiId ?? defaultUpi,
          activateBuyerWallet: activateWallet ?? state.activateBuyerWallet,
          locationPermissionGranted: locationPermission ?? state.locationPermissionGranted,
          pushNotificationsGranted: notificationsPermission ?? state.pushNotificationsGranted,
          cameraPermissionGranted: cameraPermission ?? state.cameraPermissionGranted,
        ));
      } else {
        emit(state.copyWith(isDataFetched: true));
      }
    } catch (_) {
      emit(state.copyWith(isDataFetched: true));
    }
  }

  void _saveDraft(BuyerOnboardingVerificationState s) {
    final uid = auth.currentUser?.uid;
    if (uid != null && uid.isNotEmpty) {
      repository.saveDraftState(uid, {
        'fullName': s.fullName,
        'displayName': s.displayName,
        'bio': s.bio,
        'email': s.email,
        'phone': s.phone,
        'avatarUrl': s.avatarUrl,
        'isPhoneVerified': s.isPhoneVerified,
        'formattedAddress': s.formattedAddress,
        'houseFlatNo': s.houseFlatNo,
        'landmark': s.landmark,
        'addressTag': s.addressTag,
        'latitude': s.latitude,
        'longitude': s.longitude,
        'preferredPaymentMethod': s.preferredPaymentMethod,
        'defaultUpiId': s.defaultUpiId,
        'activateBuyerWallet': s.activateBuyerWallet,
        'locationPermissionGranted': s.locationPermissionGranted,
        'pushNotificationsGranted': s.pushNotificationsGranted,
        'cameraPermissionGranted': s.cameraPermissionGranted,
        'currentStep': s.currentStep.name,
      });
    }
  }

  void _onPrefillRequested(
    BuyerVerificationPrefillRequested event,
    Emitter<BuyerOnboardingVerificationState> emit,
  ) {
    emit(state.copyWith(
      fullName: event.fullName ?? state.fullName,
      displayName: event.displayName ?? state.displayName,
      email: event.email ?? state.email,
      phone: event.phone ?? state.phone,
      avatarUrl: event.avatarUrl ?? state.avatarUrl,
      isPhoneVerified: event.isPhoneVerified ?? state.isPhoneVerified,
    ));
    _saveDraft(state);
  }

  void _onStepChanged(
    BuyerVerificationStepChanged event,
    Emitter<BuyerOnboardingVerificationState> emit,
  ) {
    emit(state.copyWith(
      currentStep: event.step,
      errorMessage: null,
      successMessage: null,
    ));
    _saveDraft(state);
  }

  void _onNextStepPressed(
    BuyerVerificationNextStepPressed event,
    Emitter<BuyerOnboardingVerificationState> emit,
  ) {
    final currentIndex = BuyerVerificationStep.values.indexOf(state.currentStep);
    if (currentIndex < BuyerVerificationStep.values.length - 1) {
      final nextStep = BuyerVerificationStep.values[currentIndex + 1];
      emit(state.copyWith(
        currentStep: nextStep,
        errorMessage: null,
      ));
    }
  }

  void _onPreviousStepPressed(
    BuyerVerificationPreviousStepPressed event,
    Emitter<BuyerOnboardingVerificationState> emit,
  ) {
    final currentIndex = BuyerVerificationStep.values.indexOf(state.currentStep);
    if (currentIndex > 0) {
      final prevStep = BuyerVerificationStep.values[currentIndex - 1];
      emit(state.copyWith(
        currentStep: prevStep,
        errorMessage: null,
      ));
    }
  }

  Future<void> _onAvatarPickRequested(
    BuyerAvatarPickRequested event,
    Emitter<BuyerOnboardingVerificationState> emit,
  ) async {
    try {
      Uint8List? imageBytes = event.directBytes;
      String fileName = event.fileName ?? 'avatar_${DateTime.now().millisecondsSinceEpoch}.jpg';
      String contentType = 'image/jpeg';

      if (imageBytes == null) {
        XFile? picked;
        try {
          final picker = imagePicker ?? ImagePicker();
          picked = await picker.pickImage(
            source: event.source ?? ImageSource.gallery,
            imageQuality: 100,
          );
        } catch (pickerErr) {
          debugPrint('ImagePicker info: $pickerErr. Trying fallback.');
        }

        if (picked != null) {
          imageBytes = await picked.readAsBytes();
          fileName = picked.name;
        } else if (!kIsWeb && (defaultTargetPlatform == TargetPlatform.windows || defaultTargetPlatform == TargetPlatform.linux || defaultTargetPlatform == TargetPlatform.macOS)) {
          final result = await FilePicker.platform.pickFiles(
            type: FileType.image,
            allowMultiple: false,
            withData: true,
          );
          if (result != null && result.files.isNotEmpty) {
            imageBytes = result.files.first.bytes;
            fileName = result.files.first.name;
          }
        }
      }

      if (imageBytes == null) return;

      emit(state.copyWith(
        isUploadingAvatar: true,
        localAvatarBytes: imageBytes,
        status: BuyerVerificationStatus.inProgress,
      ));

      Uint8List bytesToUpload = imageBytes;
      try {
        img.Image? decoded = img.decodeImage(imageBytes);
        if (decoded != null) {
          if (decoded.width > 800 || decoded.height > 800) {
            decoded = decoded.width >= decoded.height
                ? img.copyResize(decoded, width: 800)
                : img.copyResize(decoded, height: 800);
          }
          bytesToUpload = Uint8List.fromList(
            img.encodeJpg(decoded, quality: 80),
          );
        }
      } catch (e) {
        debugPrint('Image decode note, using raw bytes: $e');
      }

      if (fileName.toLowerCase().endsWith('.png')) {
        contentType = 'image/png';
      } else if (fileName.toLowerCase().endsWith('.webp')) {
        contentType = 'image/webp';
      }

      final uid = auth.currentUser?.uid ?? 'guest_buyer_${DateTime.now().millisecondsSinceEpoch}';

      final downloadUrl = await repository.uploadProfileAvatar(
        userId: uid,
        imageBytes: bytesToUpload,
        fileName: fileName,
        contentType: contentType,
      );

      emit(state.copyWith(
        avatarUrl: downloadUrl,
        isUploadingAvatar: false,
        successMessage: 'Profile photo updated successfully!',
        status: BuyerVerificationStatus.inProgress,
      ));
    } catch (e) {
      debugPrint('Avatar upload error: $e');
      emit(state.copyWith(
        isUploadingAvatar: false,
        errorMessage: 'Failed to upload photo: ${AppExceptionFormatter.toUserFriendlyMessage(e)}',
        status: BuyerVerificationStatus.failure,
      ));
    }
  }

  void _onAvatarRemoved(
    BuyerAvatarRemoved event,
    Emitter<BuyerOnboardingVerificationState> emit,
  ) {
    emit(state.copyWith(
      clearAvatar: true,
      successMessage: 'Profile photo removed',
      status: BuyerVerificationStatus.inProgress,
    ));
  }

  void _onPersonalDetailsUpdated(
    BuyerPersonalDetailsUpdated event,
    Emitter<BuyerOnboardingVerificationState> emit,
  ) {
    if (event.fullName.trim().isEmpty) {
      emit(state.copyWith(
        errorMessage: 'Please enter your full name',
        status: BuyerVerificationStatus.failure,
      ));
      return;
    }

    emit(state.copyWith(
      fullName: event.fullName.trim(),
      displayName: event.displayName.trim().isNotEmpty
          ? event.displayName.trim()
          : event.fullName.trim(),
      bio: event.bio.trim(),
      avatarUrl: event.avatarUrl ?? state.avatarUrl,
      currentStep: BuyerVerificationStep.contactVerification,
      status: BuyerVerificationStatus.inProgress,
      errorMessage: null,
    ));
    _saveDraft(state);
  }

  void _onContactUpdated(
    BuyerContactUpdated event,
    Emitter<BuyerOnboardingVerificationState> emit,
  ) {
    emit(state.copyWith(
      email: event.email.trim(),
      phone: event.phone.trim(),
    ));
    _saveDraft(state);
  }

  Future<void> _onSendOtpRequested(
    BuyerSendOtpRequested event,
    Emitter<BuyerOnboardingVerificationState> emit,
  ) async {
    if (state.phone.trim().isEmpty) {
      emit(state.copyWith(
        errorMessage: 'Please provide a valid mobile number',
        status: BuyerVerificationStatus.failure,
      ));
      return;
    }

    emit(state.copyWith(status: BuyerVerificationStatus.loading));
    try {
      await repository.sendPhoneVerificationOtp(phone: state.phone);
      _startOtpTimer();
      emit(state.copyWith(
        status: BuyerVerificationStatus.otpSent,
        otpCountdown: 30,
        isOtpResendAvailable: false,
        successMessage: 'OTP code sent to ${state.phone}',
      ));
      _saveDraft(state);
    } catch (e) {
      emit(state.copyWith(
        status: BuyerVerificationStatus.failure,
        errorMessage: AppExceptionFormatter.toUserFriendlyMessage(e),
      ));
    }
  }

  void _onOtpCodeChanged(
    BuyerOtpCodeChanged event,
    Emitter<BuyerOnboardingVerificationState> emit,
  ) {
    emit(state.copyWith(otpCode: event.otpCode));
  }

  Future<void> _onVerifyOtpPressed(
    BuyerVerifyOtpPressed event,
    Emitter<BuyerOnboardingVerificationState> emit,
  ) async {
    if (state.otpCode.trim().length != 6) {
      emit(state.copyWith(
        errorMessage: 'Please enter the 6-digit OTP',
        status: BuyerVerificationStatus.failure,
      ));
      return;
    }

    emit(state.copyWith(status: BuyerVerificationStatus.loading));
    try {
      final isValid = await repository.verifyPhoneOtp(
        verificationId: 'active_id',
        otpCode: state.otpCode,
      );

      if (isValid) {
        _otpTimer?.cancel();
        emit(state.copyWith(
          status: BuyerVerificationStatus.otpVerified,
          isPhoneVerified: true,
          currentStep: BuyerVerificationStep.addressSelection,
          successMessage: 'Phone verified successfully!',
        ));
        _saveDraft(state);
      } else {
        emit(state.copyWith(
          status: BuyerVerificationStatus.failure,
          errorMessage: 'Invalid OTP code. Please try again.',
        ));
      }
    } catch (e) {
      emit(state.copyWith(
        status: BuyerVerificationStatus.failure,
        errorMessage: AppExceptionFormatter.toUserFriendlyMessage(e),
      ));
    }
  }

  void _onOtpTimerTicked(
    BuyerOtpTimerTicked event,
    Emitter<BuyerOnboardingVerificationState> emit,
  ) {
    if (state.otpCountdown > 1) {
      emit(state.copyWith(otpCountdown: state.otpCountdown - 1));
    } else {
      _otpTimer?.cancel();
      emit(state.copyWith(
        otpCountdown: 0,
        isOtpResendAvailable: true,
      ));
    }
  }

  void _startOtpTimer() {
    _otpTimer?.cancel();
    _otpTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      add(const BuyerOtpTimerTicked());
    });
  }

  Future<void> _onAddressUpdated(
    BuyerAddressUpdated event,
    Emitter<BuyerOnboardingVerificationState> emit,
  ) async {
    if (event.formattedAddress.trim().isEmpty) {
      emit(state.copyWith(
        errorMessage: 'Please specify your delivery address',
        status: BuyerVerificationStatus.failure,
      ));
      return;
    }

    final uid = auth.currentUser?.uid;
    if (uid != null && uid.isNotEmpty) {
      try {
        await repository.saveStep3Address(
          userId: uid,
          formattedAddress: event.formattedAddress.trim(),
          houseFlatNo: event.houseFlatNo.trim(),
          landmark: event.landmark.trim(),
          addressTag: event.addressTag,
          latitude: event.latitude,
          longitude: event.longitude,
        );
      } catch (e) {
        debugPrint('Real-time Step 3 persistence warning: $e');
      }
    }

    emit(state.copyWith(
      formattedAddress: event.formattedAddress.trim(),
      houseFlatNo: event.houseFlatNo.trim(),
      landmark: event.landmark.trim(),
      addressTag: event.addressTag,
      latitude: event.latitude,
      longitude: event.longitude,
      currentStep: BuyerVerificationStep.paymentSetup,
      status: BuyerVerificationStatus.inProgress,
      errorMessage: null,
      successMessage: 'Delivery address saved successfully!',
    ));
    _saveDraft(state);
  }

  void _onAddressTagChanged(
    BuyerAddressTagChanged event,
    Emitter<BuyerOnboardingVerificationState> emit,
  ) {
    emit(state.copyWith(
      addressTag: event.addressTag,
      status: BuyerVerificationStatus.inProgress,
    ));
    _saveDraft(state);
  }

  void _onAddressLocationSelected(
    BuyerAddressLocationSelected event,
    Emitter<BuyerOnboardingVerificationState> emit,
  ) {
    emit(state.copyWith(
      formattedAddress: event.formattedAddress.trim(),
      latitude: event.latitude,
      longitude: event.longitude,
      houseFlatNo: event.houseFlatNo ?? state.houseFlatNo,
      landmark: event.landmark ?? state.landmark,
      addressTag: event.addressTag ?? state.addressTag,
      status: BuyerVerificationStatus.inProgress,
      errorMessage: null,
      successMessage: 'Address selected successfully',
    ));
    _saveDraft(state);
  }

  Future<void> _onCurrentLocationRequested(
    BuyerCurrentLocationRequested event,
    Emitter<BuyerOnboardingVerificationState> emit,
  ) async {
    emit(state.copyWith(isLocatingGps: true, errorMessage: null));
    try {
      final details = await GooglePlacesService.instance.getCurrentLocationAddress();
      if (details != null && details.formattedAddress.isNotEmpty) {
        emit(state.copyWith(
          isLocatingGps: false,
          latitude: details.latitude ?? state.latitude,
          longitude: details.longitude ?? state.longitude,
          formattedAddress: details.formattedAddress,
          status: BuyerVerificationStatus.inProgress,
          successMessage: 'Real-time GPS Location detected',
        ));
        _saveDraft(state);
      } else {
        // If GPS permission was denied or device location disabled, provide clear message
        emit(state.copyWith(
          isLocatingGps: false,
          errorMessage: 'Unable to detect live GPS. Please enable device location.',
          status: BuyerVerificationStatus.failure,
        ));
      }
    } catch (e) {
      emit(state.copyWith(
        isLocatingGps: false,
        errorMessage: 'Unable to fetch GPS location: $e',
        status: BuyerVerificationStatus.failure,
      ));
    }
  }

  void _onPaymentMethodChanged(
    BuyerPaymentMethodChanged event,
    Emitter<BuyerOnboardingVerificationState> emit,
  ) {
    emit(state.copyWith(
      preferredPaymentMethod: event.paymentMethod,
      status: BuyerVerificationStatus.inProgress,
    ));
    _saveDraft(state);
  }

  void _onWalletToggled(
    BuyerWalletToggled event,
    Emitter<BuyerOnboardingVerificationState> emit,
  ) {
    emit(state.copyWith(
      activateBuyerWallet: event.activate,
      status: BuyerVerificationStatus.inProgress,
    ));
    _saveDraft(state);
  }

  void _onPaymentPreferenceSelected(
    BuyerPaymentPreferenceSelected event,
    Emitter<BuyerOnboardingVerificationState> emit,
  ) {
    emit(state.copyWith(
      preferredPaymentMethod: event.paymentMethod,
      defaultUpiId: event.defaultUpiId,
      activateBuyerWallet: event.activateBuyerWallet,
      currentStep: BuyerVerificationStep.permissionsSetup,
    ));
    _saveDraft(state);
  }

  void _onSinglePermissionToggled(
    BuyerSinglePermissionToggled event,
    Emitter<BuyerOnboardingVerificationState> emit,
  ) {
    if (event.permissionType == 'location') {
      emit(state.copyWith(locationPermissionGranted: event.isGranted));
    } else if (event.permissionType == 'notifications') {
      emit(state.copyWith(pushNotificationsGranted: event.isGranted));
    } else if (event.permissionType == 'camera') {
      emit(state.copyWith(cameraPermissionGranted: event.isGranted));
    }
    _saveDraft(state);
  }

  void _onPermissionsUpdated(
    BuyerPermissionsUpdated event,
    Emitter<BuyerOnboardingVerificationState> emit,
  ) {
    emit(state.copyWith(
      locationPermissionGranted: event.locationGranted,
      pushNotificationsGranted: event.notificationsGranted,
      cameraPermissionGranted: event.cameraGranted,
      currentStep: BuyerVerificationStep.completionSuccess,
    ));
    _saveDraft(state);
  }

  Future<void> _onCompleteVerificationSubmitted(
    BuyerCompleteVerificationSubmitted event,
    Emitter<BuyerOnboardingVerificationState> emit,
  ) async {
    emit(state.copyWith(status: BuyerVerificationStatus.loading));
    try {
      final uid = auth.currentUser?.uid ?? 'guest_buyer_${DateTime.now().millisecondsSinceEpoch}';
      await repository.saveBuyerVerificationProfile(
        userId: uid,
        state: state,
      );

      emit(state.copyWith(
        status: BuyerVerificationStatus.success,
        successMessage: 'Buyer Verification & Profile Setup Completed! ₹100 Welcome Gift Unlocked.',
      ));
    } catch (e) {
      emit(state.copyWith(
        status: BuyerVerificationStatus.failure,
        errorMessage: AppExceptionFormatter.toUserFriendlyMessage(e),
      ));
    }
  }

  @override
  Future<void> close() {
    _otpTimer?.cancel();
    return super.close();
  }
}
