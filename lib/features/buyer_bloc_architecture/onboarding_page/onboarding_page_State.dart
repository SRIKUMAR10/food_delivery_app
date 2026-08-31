abstract class OnboardingPageState {}

/// The initial state of the onboarding screen.
class OnboardingInitial extends OnboardingPageState {}

/// State emitted when the user needs to be navigated to the Home page (Web).
class OnboardingNavigateToHome extends OnboardingPageState {}

/// State emitted when the user needs to be navigated to the Curved Navigation Bar (Mobile).
class OnboardingNavigateToCurvedNav extends OnboardingPageState {}

/// State emitted when the user needs to be navigated to the Login Screen.
class OnboardingNavigateToLogin extends OnboardingPageState {}

/// State emitted while checking Firebase authentication status.
class OnboardingAuthWaiting extends OnboardingPageState {}

/// State emitted when the user is logged in.
class OnboardingAuthenticated extends OnboardingPageState {}

/// State emitted when the user is logged in but KYC is incomplete.
class OnboardingNavigateToKyc extends OnboardingPageState {
  final String? fullName;
  final String? email;
  final String? phone;
  final String? avatarUrl;
  final bool isPhoneVerified;

  OnboardingNavigateToKyc({
    this.fullName,
    this.email,
    this.phone,
    this.avatarUrl,
    this.isPhoneVerified = false,
  });
}

/// State emitted when the user is not logged in.
class OnboardingUnauthenticated extends OnboardingPageState {}
