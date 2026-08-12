// Real-Time BLoC Stream Binding Standardized
import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:food_delivery_app/core/services/i_auth_service.dart';
import 'onboarding_page_Event.dart';
import 'onboarding_page_State.dart';
/// BLoC to handle the business logic for the onboarding page.
class OnboardingPageBloc extends Bloc<OnboardingPageEvent, OnboardingPageState> {
  StreamSubscription<String?>? _authSubscription;

  final IAuthService _authService;

  OnboardingPageBloc({required IAuthService authService}) : _authService = authService, super(OnboardingAuthWaiting()) {
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
  /// Navigates to Login Page if unauthenticated, otherwise Home Page (Curved Navigation Bar).
  void _onGetStartedPressed(
    OnboardingGetStartedPressed event,
    Emitter<OnboardingPageState> emit,
  ) {
    if (_authService.currentUserId != null) {
      emit(OnboardingNavigateToHome());
    } else {
      emit(OnboardingNavigateToLogin());
    }
  }

  void _onAuthStatusChanged(
    OnboardingAuthStatusChanged event,
    Emitter<OnboardingPageState> emit,
  ) {
    if (event.userId != null) {
      emit(OnboardingAuthenticated());
    } else {
      emit(OnboardingUnauthenticated());
    }
  }
}
