import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:food_delivery_app/features/buyer_bloc_architecture/onboarding_page/onboarding_page_Bloc.dart';
import 'package:food_delivery_app/features/buyer_bloc_architecture/onboarding_page/onboarding_page_Event.dart';
import 'package:food_delivery_app/features/buyer_bloc_architecture/onboarding_page/onboarding_page_State.dart';
import 'package:food_delivery_app/core/services/i_auth_service.dart';
import 'package:mocktail/mocktail.dart';

class MockAuthService extends Mock implements IAuthService {}

void main() {
  group('OnboardingPageBloc Tests', () {
    late OnboardingPageBloc onboardingPageBloc;
    late MockAuthService mockAuthService;

    setUp(() {
      mockAuthService = MockAuthService();
      when(() => mockAuthService.authStateChanges).thenAnswer((_) => Stream.value(null));
      when(() => mockAuthService.currentUserId).thenReturn(null);
      onboardingPageBloc = OnboardingPageBloc(authService: mockAuthService);
    });

    tearDown(() {
      onboardingPageBloc.close();
    });

    test('Initial state is OnboardingAuthWaiting', () {
      expect(onboardingPageBloc.state, isA<OnboardingAuthWaiting>());
    });

    blocTest<OnboardingPageBloc, OnboardingPageState>(
      'emits OnboardingNavigateToLogin when unauthenticated and OnboardingGetStartedPressed is added',
      build: () => onboardingPageBloc,
      act: (bloc) => bloc.add(OnboardingGetStartedPressed(isWebLayout: false)),
      expect: () => [isA<OnboardingNavigateToLogin>()],
    );

    blocTest<OnboardingPageBloc, OnboardingPageState>(
      'emits OnboardingNavigateToHome when authenticated and OnboardingGetStartedPressed is added',
      setUp: () {
        when(() => mockAuthService.currentUserId).thenReturn('test_user_id');
      },
      build: () => onboardingPageBloc,
      act: (bloc) => bloc.add(OnboardingGetStartedPressed(isWebLayout: true)),
      expect: () => [isA<OnboardingNavigateToHome>()],
    );
  });
}
