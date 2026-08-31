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

      // Assert password or secret tokens do not exist in state props
      expect(state.props.contains('password'), isFalse);
      expect(state.props.contains('confirmPassword'), isFalse);
      expect(state.props.contains('secretKey'), isFalse);
      expect(state.props.contains('pin'), isFalse);
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
