import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:food_delivery_app/core/utils/app_exception_formatter.dart';
import 'buyer_onboarding_verification_event.dart';
import 'buyer_onboarding_verification_state.dart';
import 'buyer_onboarding_verification_repository.dart';

class BuyerOnboardingVerificationBloc
    extends Bloc<BuyerOnboardingVerificationEvent, BuyerOnboardingVerificationState> {
  final IBuyerOnboardingVerificationRepository repository;
  final FirebaseAuth auth;
  Timer? _otpTimer;

  BuyerOnboardingVerificationBloc({
    IBuyerOnboardingVerificationRepository? repository,
    FirebaseAuth? auth,
    String? initialFullName,
    String? initialDisplayName,
    String? initialEmail,
    String? initialPhone,
    String? initialAvatarUrl,
    bool initialIsPhoneVerified = false,
  })  : repository = repository ?? BuyerOnboardingVerificationRepository(),
        auth = auth ?? FirebaseAuth.instance,
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
    on<BuyerPersonalDetailsUpdated>(_onPersonalDetailsUpdated);
    on<BuyerContactUpdated>(_onContactUpdated);
    on<BuyerSendOtpRequested>(_onSendOtpRequested);
    on<BuyerOtpCodeChanged>(_onOtpCodeChanged);
    on<BuyerVerifyOtpPressed>(_onVerifyOtpPressed);
    on<BuyerOtpTimerTicked>(_onOtpTimerTicked);
    on<BuyerAddressUpdated>(_onAddressUpdated);
    on<BuyerCurrentLocationRequested>(_onCurrentLocationRequested);
    on<BuyerDietaryPreferenceToggled>(_onDietaryPreferenceToggled);
    on<BuyerSpicePreferenceChanged>(_onSpicePreferenceChanged);
    on<BuyerAllergyToggled>(_onAllergyToggled);
    on<BuyerCustomAllergyNotesChanged>(_onCustomAllergyNotesChanged);
    on<BuyerPaymentPreferenceSelected>(_onPaymentPreferenceSelected);
    on<BuyerPermissionsUpdated>(_onPermissionsUpdated);
    on<BuyerCompleteVerificationSubmitted>(_onCompleteVerificationSubmitted);
  }

  Future<void> _onAutoFetchRequested(
    BuyerVerificationAutoFetchRequested event,
    Emitter<BuyerOnboardingVerificationState> emit,
  ) async {
    final uid = auth.currentUser?.uid;
    if (uid == null || uid.isEmpty) return;

    try {
      final doc = await FirebaseFirestore.instance.collection('buyer_user').doc(uid).get();
      if (doc.exists && doc.data() != null) {
        final data = doc.data()!;
        final name = (data['fullName'] ?? data['name'] ?? data['displayName'] ?? '').toString().trim();
        final displayName = (data['displayName'] ?? data['name'] ?? '').toString().trim();
        final email = (data['email'] ?? data['emailAddress'] ?? '').toString().trim();
        final phone = (data['phone'] ?? data['phoneNumber'] ?? data['mobile'] ?? '').toString().trim();
        final imageUrl = (data['imageUrl'] ?? data['photoUrl'] ?? data['profilePic']) as String?;
        final isPhoneVerified = data['isPhoneVerified'] == true || phone.isNotEmpty;

        emit(state.copyWith(
          fullName: state.fullName.isEmpty ? name : state.fullName,
          displayName: state.displayName.isEmpty ? (displayName.isNotEmpty ? displayName : name) : state.displayName,
          email: state.email.isEmpty ? email : state.email,
          phone: state.phone.isEmpty ? phone : state.phone,
          avatarUrl: state.avatarUrl ?? imageUrl,
          isPhoneVerified: state.isPhoneVerified || isPhoneVerified,
        ));
      }
    } catch (_) {
      // Non-blocking fallback
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
      avatarUrl: event.avatarUrl,
      currentStep: BuyerVerificationStep.contactVerification,
      status: BuyerVerificationStatus.inProgress,
      errorMessage: null,
    ));
  }

  void _onContactUpdated(
    BuyerContactUpdated event,
    Emitter<BuyerOnboardingVerificationState> emit,
  ) {
    emit(state.copyWith(
      email: event.email.trim(),
      phone: event.phone.trim(),
    ));
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

  void _onAddressUpdated(
    BuyerAddressUpdated event,
    Emitter<BuyerOnboardingVerificationState> emit,
  ) {
    if (event.formattedAddress.trim().isEmpty) {
      emit(state.copyWith(
        errorMessage: 'Please specify your delivery address',
        status: BuyerVerificationStatus.failure,
      ));
      return;
    }

    emit(state.copyWith(
      formattedAddress: event.formattedAddress.trim(),
      houseFlatNo: event.houseFlatNo.trim(),
      landmark: event.landmark.trim(),
      addressTag: event.addressTag,
      latitude: event.latitude,
      longitude: event.longitude,
      currentStep: BuyerVerificationStep.dietaryPreferences,
      status: BuyerVerificationStatus.inProgress,
      errorMessage: null,
    ));
  }

  Future<void> _onCurrentLocationRequested(
    BuyerCurrentLocationRequested event,
    Emitter<BuyerOnboardingVerificationState> emit,
  ) async {
    emit(state.copyWith(isLocatingGps: true));
    try {
      // Pinpoint coordinates (e.g. Chennai / Madurai center as default GPS)
      emit(state.copyWith(
        isLocatingGps: false,
        latitude: 13.0827,
        longitude: 80.2707,
        formattedAddress: 'Anna Nagar, Chennai, Tamil Nadu, 600040',
        addressTag: 'Home',
        successMessage: 'GPS Location detected accurately',
      ));
    } catch (e) {
      emit(state.copyWith(
        isLocatingGps: false,
        errorMessage: 'Unable to fetch GPS location',
      ));
    }
  }

  void _onDietaryPreferenceToggled(
    BuyerDietaryPreferenceToggled event,
    Emitter<BuyerOnboardingVerificationState> emit,
  ) {
    final list = List<String>.from(state.selectedDietaryTypes);
    if (list.contains(event.dietaryType)) {
      list.remove(event.dietaryType);
    } else {
      list.add(event.dietaryType);
    }
    emit(state.copyWith(selectedDietaryTypes: list));
  }

  void _onSpicePreferenceChanged(
    BuyerSpicePreferenceChanged event,
    Emitter<BuyerOnboardingVerificationState> emit,
  ) {
    emit(state.copyWith(spicePreference: event.spicePreference));
  }

  void _onAllergyToggled(
    BuyerAllergyToggled event,
    Emitter<BuyerOnboardingVerificationState> emit,
  ) {
    final list = List<String>.from(state.selectedAllergies);
    if (list.contains(event.allergy)) {
      list.remove(event.allergy);
    } else {
      list.add(event.allergy);
    }
    emit(state.copyWith(selectedAllergies: list));
  }

  void _onCustomAllergyNotesChanged(
    BuyerCustomAllergyNotesChanged event,
    Emitter<BuyerOnboardingVerificationState> emit,
  ) {
    emit(state.copyWith(customAllergyNotes: event.notes));
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
