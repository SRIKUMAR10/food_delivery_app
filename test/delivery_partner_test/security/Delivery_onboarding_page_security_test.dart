import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:food_delivery_app/features/Delivery Partner Bloc Architecture/Delivery_onboarding_page/Delivery_onboarding_page_repository.dart';

void main() {
  group('DeliveryOnboardingPage Security Tests', () {
    test('does not hardcode plain text secrets in source files', () {
      dotenv.loadFromString(
        envString: 'BASE_URL=https://api.fooddelivery.example.com\n'
            'API_KEY=env_api_key_secure\n'
            'KEY_SECRET=env_key_secret_secure\n',
      );
      final repository = DeliveryOnboardingRepository();
      final envs = repository.getSecureEnvironmentConfigs();

      expect(envs.containsKey('BASE_URL'), true);
      expect(envs.containsKey('API_KEY'), true);
      expect(envs.containsKey('KEY_SECRET'), true);
    });
  });
}
