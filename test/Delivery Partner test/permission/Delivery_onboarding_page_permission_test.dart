import 'package:flutter_test/flutter_test.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_onboarding_page/Delivery_onboarding_page_state.dart';

void main() {
  group('DeliveryOnboardingPage Permission Tests', () {
    test('handles default permission states smoothly without throwing exceptions', () {
      const state = DeliveryOnboardingPageState();
      expect(state.errorMessage, isNull);
      expect(state.status, DeliveryOnboardingStatus.initial);
    });
  });
}
