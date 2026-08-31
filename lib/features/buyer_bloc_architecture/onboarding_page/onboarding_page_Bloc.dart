import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:food_delivery_app/core/services/i_auth_service.dart';
import 'package:food_delivery_app/repositories/user_repository.dart';
import 'onboarding_page_Event.dart';
import 'onboarding_page_State.dart';

/// BLoC to handle the business logic for the onboarding page.
class OnboardingPageBloc extends Bloc<OnboardingPageEvent, OnboardingPageState> {
  StreamSubscription<String?>? _authSubscription;
  final IAuthService _authService;
  final UserRepository _userRepository;

  OnboardingPageBloc({
    required IAuthService authService,
    UserRepository? userRepository,
  })  : _authService = authService,
        _userRepository = userRepository ?? UserRepository(),
        super(OnboardingAuthWaiting()) {
    on<OnboardingGetStartedPressed>(_onGetStartedPressed);
    on<OnboardingAuthStatusChanged>(_onAuthStatusChanged);

    _authSubscription = _authService.authStateChanges.listen((userId) {
      add(OnboardingAuthStatusChanged(userId: userId));
    });
  }

  @override
  Future<void> close() {
    _authSubscription?.cancel();
    return super.close();
  }

  /// Handles the 'Get Started' button press.
  /// Navigates to Login Page if unauthenticated, otherwise checks KYC status.
  Future<void> _onGetStartedPressed(
    OnboardingGetStartedPressed event,
    Emitter<OnboardingPageState> emit,
  ) async {
    final uid = _authService.currentUserId;
    if (uid == null) {
      emit(OnboardingNavigateToLogin());
      return;
    }

    try {
      final docData = await _userRepository.getUserData(uid);
      if (docData != null) {
        final isKyc = (docData['isBuyerKycVerified'] == true) &&
            (docData['onboardingCompleted'] == true);
        if (!isKyc) {
          final name = (docData['fullName'] ?? docData['name'] ?? docData['displayName'] ?? '').toString().trim();
          final email = (docData['email'] ?? docData['emailAddress'] ?? '').toString().trim();
          final phone = (docData['phone'] ?? docData['mobile'] ?? docData['phoneNumber'] ?? '').toString().trim();
          final imageUrl = (docData['imageUrl'] ?? docData['photoUrl'] ?? docData['profilePic']) as String?;
          final isPhoneVerified = docData['isPhoneVerified'] == true || phone.isNotEmpty;

          emit(OnboardingNavigateToKyc(
            fullName: name,
            email: email,
            phone: phone,
            avatarUrl: imageUrl,
            isPhoneVerified: isPhoneVerified,
          ));
          return;
        }
      } else {
        emit(OnboardingNavigateToKyc());
        return;
      }
    } catch (_) {
      emit(OnboardingNavigateToKyc());
      return;
    }

    emit(OnboardingNavigateToHome());
  }

  Future<void> _onAuthStatusChanged(
    OnboardingAuthStatusChanged event,
    Emitter<OnboardingPageState> emit,
  ) async {
    if (event.userId == null) {
      emit(OnboardingUnauthenticated());
      return;
    }

    try {
      final docData = await _userRepository.getUserData(event.userId!);
      if (docData != null) {
        final isKyc = (docData['isBuyerKycVerified'] == true) &&
            (docData['onboardingCompleted'] == true);
        if (!isKyc) {
          final name = (docData['fullName'] ?? docData['name'] ?? docData['displayName'] ?? '').toString().trim();
          final email = (docData['email'] ?? docData['emailAddress'] ?? '').toString().trim();
          final phone = (docData['phone'] ?? docData['mobile'] ?? docData['phoneNumber'] ?? '').toString().trim();
          final imageUrl = (docData['imageUrl'] ?? docData['photoUrl'] ?? docData['profilePic']) as String?;
          final isPhoneVerified = docData['isPhoneVerified'] == true || phone.isNotEmpty;

          emit(OnboardingNavigateToKyc(
            fullName: name,
            email: email,
            phone: phone,
            avatarUrl: imageUrl,
            isPhoneVerified: isPhoneVerified,
          ));
          return;
        }
      } else {
        emit(OnboardingNavigateToKyc());
        return;
      }
    } catch (_) {
      emit(OnboardingNavigateToKyc());
      return;
    }

    emit(OnboardingAuthenticated());
  }
}
