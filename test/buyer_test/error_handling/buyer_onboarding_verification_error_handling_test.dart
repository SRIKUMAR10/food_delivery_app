import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:food_delivery_app/features/buyer_bloc_architecture/buyer_onboarding_verification_page/buyer_onboarding_verification_bloc.dart';
import 'package:food_delivery_app/features/buyer_bloc_architecture/buyer_onboarding_verification_page/buyer_onboarding_verification_event.dart';
import 'package:food_delivery_app/features/buyer_bloc_architecture/buyer_onboarding_verification_page/buyer_onboarding_verification_state.dart';
import 'package:food_delivery_app/features/buyer_bloc_architecture/buyer_onboarding_verification_page/buyer_onboarding_verification_repository.dart';

class MockBuyerVerificationRepository extends Mock
    implements IBuyerOnboardingVerificationRepository {}

class MockFirebaseAuth extends Mock implements FirebaseAuth {}
class MockUser extends Mock implements User {}

void main() {
  late MockBuyerVerificationRepository mockRepository;
  late MockFirebaseAuth mockAuth;
  late MockUser mockUser;

  setUpAll(() {
    registerFallbackValue(const BuyerOnboardingVerificationState());
  });

  setUp(() {
    mockRepository = MockBuyerVerificationRepository();
    mockAuth = MockFirebaseAuth();
    mockUser = MockUser();

    when(() => mockUser.uid).thenReturn('error_test_user');
    when(() => mockAuth.currentUser).thenReturn(mockUser);
  });

  group('Buyer Verification Error Handling Tests', () {
    blocTest<BuyerOnboardingVerificationBloc, BuyerOnboardingVerificationState>(
      'handles Firestore repository write failure gracefully',
      build: () {
        when(() => mockRepository.saveBuyerVerificationProfile(
              userId: any(named: 'userId'),
              state: any(named: 'state'),
            )).thenThrow(Exception('Firestore write failed: network timeout'));
        return BuyerOnboardingVerificationBloc(
          repository: mockRepository,
          auth: mockAuth,
        );
      },
      seed: () => const BuyerOnboardingVerificationState(
        currentStep: BuyerVerificationStep.completionSuccess,
        fullName: 'Error User',
      ),
      act: (bloc) => bloc.add(const BuyerCompleteVerificationSubmitted()),
      expect: () => [
        isA<BuyerOnboardingVerificationState>()
            .having((s) => s.status, 'status', BuyerVerificationStatus.loading),
        isA<BuyerOnboardingVerificationState>()
            .having((s) => s.status, 'status', BuyerVerificationStatus.failure)
            .having((s) => s.errorMessage, 'errorMessage', isNotEmpty),
      ],
    );
  });
}
