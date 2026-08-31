import 'package:flutter_test/flutter_test.dart';
import 'package:food_delivery_app/features/buyer_bloc_architecture/buyer_onboarding_verification_page/buyer_onboarding_verification_state.dart';

void main() {
  group('Buyer Onboarding Verification State Restoration Tests', () {
    test('copyWith restores all state properties with precision', () {
      const original = BuyerOnboardingVerificationState(
        fullName: 'Original Name',
        email: 'original@test.com',
        phone: '+919876543210',
        currentStep: BuyerVerificationStep.addressSelection,
        formattedAddress: 'Original Address',
        preferredPaymentMethod: 'UPI',
        defaultUpiId: 'original@okhdfc',
        activateBuyerWallet: true,
      );

      final restored = original.copyWith(
        fullName: 'Restored Name',
        currentStep: BuyerVerificationStep.paymentSetup,
      );

      expect(restored.fullName, equals('Restored Name'));
      expect(restored.email, equals('original@test.com'));
      expect(restored.phone, equals('+919876543210'));
      expect(restored.currentStep, equals(BuyerVerificationStep.paymentSetup));
      expect(restored.formattedAddress, equals('Original Address'));
      expect(restored.preferredPaymentMethod, equals('UPI'));
      expect(restored.defaultUpiId, equals('original@okhdfc'));
      expect(restored.activateBuyerWallet, isTrue);
    });
  });
}
