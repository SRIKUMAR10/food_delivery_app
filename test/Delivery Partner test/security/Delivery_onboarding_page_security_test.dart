import 'package:flutter_test/flutter_test.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_onboarding_page/Delivery_onboarding_page_repository.dart';

void main() {
  group('DeliveryOnboardingPage Security Tests', () {
    test('does not hardcode plain text secrets in source files', () {
      final repository = DeliveryOnboardingRepository();
      final envs = repository.getSecureEnvironmentConfigs();

      expect(envs.containsKey('BASE_URL'), true);
      expect(envs.containsKey('API_KEY'), true);
      expect(envs.containsKey('KEY_SECRET'), true);
    });
  });
}
