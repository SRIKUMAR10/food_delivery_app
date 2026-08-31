import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:food_delivery_app/features/buyer_bloc_architecture/buyer_onboarding_verification_page/buyer_onboarding_verification_repository.dart';
import 'package:food_delivery_app/features/buyer_bloc_architecture/buyer_onboarding_verification_page/buyer_onboarding_verification_state.dart';

class MockBuyerVerificationRepository extends Mock
    implements IBuyerOnboardingVerificationRepository {}

void main() {
  setUpAll(() {
    registerFallbackValue(const BuyerOnboardingVerificationState());
  });

  group('Buyer Verification Dependency Tests', () {
    test('IBuyerOnboardingVerificationRepository contract matches mock implementation', () async {
      final mockRepo = MockBuyerVerificationRepository();

      when(() => mockRepo.saveBuyerVerificationProfile(
            userId: any(named: 'userId'),
            state: any(named: 'state'),
          )).thenAnswer((_) async {});

      await mockRepo.saveBuyerVerificationProfile(
        userId: 'user_123',
        state: const BuyerOnboardingVerificationState(fullName: 'Test User'),
      );

      verify(() => mockRepo.saveBuyerVerificationProfile(
            userId: 'user_123',
            state: any(named: 'state'),
          )).called(1);
    });
  });
}
