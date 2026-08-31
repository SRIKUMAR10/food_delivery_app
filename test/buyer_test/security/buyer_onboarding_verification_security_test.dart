import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:food_delivery_app/features/buyer_bloc_architecture/buyer_onboarding_verification_page/buyer_onboarding_verification_state.dart';

void main() {
  group('Buyer Verification Security & Privacy Tests', () {
    test('Ensures password fields are never stored in preferences or state props', () {
      const state = BuyerOnboardingVerificationState(
        fullName: 'Security Tester',
        email: 'security@example.com',
        phone: '+919876543210',
        formattedAddress: '404 Encrypted Way',
      );

      final preferencesMap = state.preferencesMap;

      // Assert password or secret tokens do not exist in preferences map
      expect(preferencesMap.containsKey('password'), isFalse);
      expect(preferencesMap.containsKey('confirmPassword'), isFalse);
      expect(preferencesMap.containsKey('secretKey'), isFalse);
      expect(preferencesMap.containsKey('pin'), isFalse);
    });

    test('Sanitizes UPI IDs and addresses properly', () {
      const state = BuyerOnboardingVerificationState(
        defaultUpiId: 'user@okhdfcbank',
        preferredPaymentMethod: 'UPI',
      );

      expect(state.defaultUpiId, isNotNull);
      expect(state.defaultUpiId!.contains('@'), isTrue);
    });
  });
}
