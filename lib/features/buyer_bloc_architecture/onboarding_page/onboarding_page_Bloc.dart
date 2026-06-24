import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'onboarding_page_Event.dart';
import 'onboarding_page_State.dart';
/// BLoC to handle the business logic for the onboarding page.
class OnboardingPageBloc extends Bloc<OnboardingPageEvent, OnboardingPageState> {
  StreamSubscription<User?>? _authSubscription;

  OnboardingPageBloc() : super(OnboardingAuthWaiting()) {
    on<OnboardingGetStartedPressed>(_onGetStartedPressed);
    on<OnboardingAuthStatusChanged>(_onAuthStatusChanged);

    _authSubscription = FirebaseAuth.instance.authStateChanges().listen((user) {
      add(OnboardingAuthStatusChanged(user: user));
    });
  }

  @override
  Future<void> close() {
    _authSubscription?.cancel();
    return super.close();
  }

  /// Handles the 'Get Started' button press.
  /// Navigates to Home Page if web layout, otherwise Curved Navigation Bar.
  void _onGetStartedPressed(
    OnboardingGetStartedPressed event,
    Emitter<OnboardingPageState> emit,
  ) {
    // Navigate globally to the Home page route.
    emit(OnboardingNavigateToHome());
  }

  void _onAuthStatusChanged(
    OnboardingAuthStatusChanged event,
    Emitter<OnboardingPageState> emit,
  ) {
    if (event.user != null) {
      emit(OnboardingAuthenticated());
    } else {
      emit(OnboardingUnauthenticated());
    }
  }
}
