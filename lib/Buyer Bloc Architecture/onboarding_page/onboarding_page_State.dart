abstract class OnboardingPageState {}

/// The initial state of the onboarding screen.
class OnboardingInitial extends OnboardingPageState {}

/// State emitted when the user needs to be navigated to the Home page (Web).
class OnboardingNavigateToHome extends OnboardingPageState {}

/// State emitted when the user needs to be navigated to the Curved Navigation Bar (Mobile).
class OnboardingNavigateToCurvedNav extends OnboardingPageState {}
