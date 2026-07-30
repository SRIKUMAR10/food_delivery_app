import 'package:flutter_test/flutter_test.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_onboarding_page/Delivery_onboarding_page_state.dart';

void main() {
  group('DeliveryOnboardingPage Snapshot Tests', () {
    test('serializes and deserializes state correctly', () {
      const state = DeliveryOnboardingPageState(
        selectedLanguage: 'Tamil',
        isStarted: true,
      );

      final json = state.toJson();
      final restored = DeliveryOnboardingPageState.fromJson(json);

      expect(restored.selectedLanguage, 'Tamil');
      expect(restored.isStarted, true);
    });
  });
}
