import 'package:flutter_test/flutter_test.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_onboarding_page/Delivery_onboarding_page_repository.dart';

void main() {
  late DeliveryOnboardingRepository repository;

  setUp(() {
    repository = DeliveryOnboardingRepository();
  });

  group('DeliveryOnboardingRepository Unit Tests', () {
    test('getFeatures returns default onboarding feature items', () async {
      final features = await repository.getFeatures();
      expect(features.isNotEmpty, true);
      expect(features.any((f) => f.title == 'Fast Delivery'), true);
    });

    test('getPartnerStats returns partner metrics stats', () async {
      final stats = await repository.getPartnerStats();
      expect(stats.length, 4);
      expect(stats.first.value, '10K+');
    });

    test('getSecureEnvironmentConfigs returns required key secrets', () {
      final envs = repository.getSecureEnvironmentConfigs();
      expect(envs.containsKey('BASE_URL'), true);
      expect(envs.containsKey('API_KEY'), true);
      expect(envs.containsKey('KEY_SECRET'), true);
    });
  });
}
