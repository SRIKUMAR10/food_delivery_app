import 'package:flutter_test/flutter_test.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_onboarding_page/Delivery_onboarding_page_state.dart';

void main() {
  group('DeliveryOnboardingPage State Restoration Tests', () {
    test('copyWith restores unchanged properties and updates targeted state props', () {
      const initial = DeliveryOnboardingPageState(
        selectedLanguage: 'English',
        isStarted: false,
      );

      final updated = initial.copyWith(
        selectedLanguage: 'Tamil',
        isStarted: true,
      );

      expect(updated.selectedLanguage, 'Tamil');
      expect(updated.isStarted, true);
      expect(updated.status, DeliveryOnboardingStatus.initial);
    });
  });
}
