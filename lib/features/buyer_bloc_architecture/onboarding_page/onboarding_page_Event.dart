import 'package:firebase_auth/firebase_auth.dart';

abstract class OnboardingPageEvent {}

/// Event triggered when the user taps the 'Get Started' button.
/// [isWebLayout] indicates if the layout is web or mobile.
class OnboardingGetStartedPressed extends OnboardingPageEvent {
  final bool isWebLayout;

  OnboardingGetStartedPressed({required this.isWebLayout});
}

/// Event triggered when the Firebase auth status changes.
class OnboardingAuthStatusChanged extends OnboardingPageEvent {
  final User? user;

  OnboardingAuthStatusChanged({this.user});
}
