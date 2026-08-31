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
        selectedDietaryTypes: ['Vegetarian'],
        spicePreference: 'Spicy',
        selectedAllergies: ['Nuts'],
        activateBuyerWallet: true,
      );

      final restored = original.copyWith(
        fullName: 'Restored Name',
        currentStep: BuyerVerificationStep.dietaryPreferences,
      );

      expect(restored.fullName, equals('Restored Name'));
      expect(restored.email, equals('original@test.com'));
      expect(restored.phone, equals('+919876543210'));
      expect(restored.currentStep, equals(BuyerVerificationStep.dietaryPreferences));
      expect(restored.formattedAddress, equals('Original Address'));
      expect(restored.selectedDietaryTypes, equals(['Vegetarian']));
      expect(restored.spicePreference, equals('Spicy'));
      expect(restored.selectedAllergies, equals(['Nuts']));
      expect(restored.activateBuyerWallet, isTrue);
    });
  });
}
