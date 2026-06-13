import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:food_delivery_app/Buyer Bloc Architecture/onboarding_page/onboarding_page_Bloc.dart';
import 'package:food_delivery_app/Buyer Bloc Architecture/onboarding_page/onboarding_page_Event.dart';
import 'package:food_delivery_app/Buyer Bloc Architecture/onboarding_page/onboarding_page_State.dart';

void main() {
  group('OnboardingPageBloc Tests', () {
    late OnboardingPageBloc onboardingPageBloc;

    setUp(() {
      onboardingPageBloc = OnboardingPageBloc();
    });

    tearDown(() {
      onboardingPageBloc.close();
    });

    test('Initial state is OnboardingInitial', () {
      expect(onboardingPageBloc.state, isA<OnboardingInitial>());
    });

    blocTest<OnboardingPageBloc, OnboardingPageState>(
      'emits OnboardingNavigateToHome when OnboardingGetStartedPressed(isWebLayout: true) is added',
      build: () => onboardingPageBloc,
      act: (bloc) => bloc.add(OnboardingGetStartedPressed(isWebLayout: true)),
      expect: () => [isA<OnboardingNavigateToHome>()],
    );

    blocTest<OnboardingPageBloc, OnboardingPageState>(
      'emits OnboardingNavigateToCurvedNav when OnboardingGetStartedPressed(isWebLayout: false) is added',
      build: () => onboardingPageBloc,
      act: (bloc) => bloc.add(OnboardingGetStartedPressed(isWebLayout: false)),
      expect: () => [isA<OnboardingNavigateToCurvedNav>()],
    );
  });
}
