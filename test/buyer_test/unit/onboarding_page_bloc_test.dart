import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:food_delivery_app/features/buyer_bloc_architecture/onboarding_page/onboarding_page_Bloc.dart';
import 'package:food_delivery_app/features/buyer_bloc_architecture/onboarding_page/onboarding_page_Event.dart';
import 'package:food_delivery_app/features/buyer_bloc_architecture/onboarding_page/onboarding_page_State.dart';
import 'package:food_delivery_app/core/services/i_auth_service.dart';
import 'package:food_delivery_app/repositories/user_repository.dart';
import 'package:mocktail/mocktail.dart';

class MockAuthService extends Mock implements IAuthService {}
class MockUserRepository extends Mock implements UserRepository {}

void main() {
  group('OnboardingPageBloc Tests', () {
    late OnboardingPageBloc onboardingPageBloc;
    late MockAuthService mockAuthService;
    late MockUserRepository mockUserRepository;

    setUp(() {
      mockAuthService = MockAuthService();
      mockUserRepository = MockUserRepository();
      when(() => mockAuthService.authStateChanges).thenAnswer((_) => Stream.value(null));
      when(() => mockAuthService.currentUserId).thenReturn(null);
      when(() => mockUserRepository.getUserData(any())).thenAnswer((_) async => null);
      onboardingPageBloc = OnboardingPageBloc(
        authService: mockAuthService,
        userRepository: mockUserRepository,
      );
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
      'emits OnboardingNavigateToKyc when authenticated without KYC and OnboardingGetStartedPressed is added',
      setUp: () {
        when(() => mockAuthService.currentUserId).thenReturn('test_user_id');
        when(() => mockUserRepository.getUserData('test_user_id')).thenAnswer((_) async => {
          'fullName': 'Test User',
          'isBuyerKycVerified': false,
          'onboardingCompleted': false,
        });
      },
      build: () => onboardingPageBloc,
      act: (bloc) => bloc.add(OnboardingGetStartedPressed(isWebLayout: true)),
      expect: () => [isA<OnboardingNavigateToKyc>()],
    );

    blocTest<OnboardingPageBloc, OnboardingPageState>(
      'emits OnboardingNavigateToHome when authenticated with full KYC and OnboardingGetStartedPressed is added',
      setUp: () {
        when(() => mockAuthService.currentUserId).thenReturn('verified_user_id');
        when(() => mockUserRepository.getUserData('verified_user_id')).thenAnswer((_) async => {
          'fullName': 'Verified User',
          'isBuyerKycVerified': true,
          'onboardingCompleted': true,
        });
      },
      build: () => onboardingPageBloc,
      act: (bloc) => bloc.add(OnboardingGetStartedPressed(isWebLayout: true)),
      expect: () => [isA<OnboardingNavigateToHome>()],
    );
  });
}
