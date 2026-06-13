import 'package:flutter_bloc/flutter_bloc.dart';
import 'onboarding_page_Event.dart';
import 'onboarding_page_State.dart';

/// BLoC to handle the business logic for the onboarding page.
class OnboardingPageBloc extends Bloc<OnboardingPageEvent, OnboardingPageState> {
  OnboardingPageBloc() : super(OnboardingInitial()) {
    on<OnboardingGetStartedPressed>(_onGetStartedPressed);
  }

  /// Handles the 'Get Started' button press.
  /// Navigates to Home Page if web layout, otherwise Curved Navigation Bar.
  void _onGetStartedPressed(
    OnboardingGetStartedPressed event,
    Emitter<OnboardingPageState> emit,
  ) {
    if (event.isWebLayout) {
      emit(OnboardingNavigateToHome());
    } else {
      emit(OnboardingNavigateToCurvedNav());
    }
  }
}
