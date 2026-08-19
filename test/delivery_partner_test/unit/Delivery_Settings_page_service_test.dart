import 'package:flutter_test/flutter_test.dart';

import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Settings_page/Delivery_Settings_page_service.dart';

void main() {
  late DeliverySettingsService service;

  setUp(() {
    service = DeliverySettingsService();
  });

  group('DeliverySettingsPage Service Tests', () {
    test('checkNetworkConnectivity returns a boolean result', () async {
      final result = await service.checkNetworkConnectivity();
      expect(result, isA<bool>());
    });

    test('getSecureEnvironmentConfigs exposes safe placeholder keys', () {
      final env = service.getSecureEnvironmentConfigs();

      expect(env, contains('BASE_URL'));
      expect(env, contains('API_KEY'));
      expect(env, contains('KEY_SECRET'));
      expect(env, contains('SETTINGS_ENDPOINT'));
      expect(env.keys, hasLength(4));
    });

    test('secure configs fall back to non-plain-text defaults', () {
      final env = service.getSecureEnvironmentConfigs();

      for (final key in env.keys) {
        expect(env[key], isNotEmpty);
      }
      expect(env['BASE_URL'], contains('https://'));
    });

    test(
      'syncProgress yields monotonically increasing progress to 1.0',
      () async {
        final values = await service.syncProgress().toList();

        expect(values, isNotEmpty);
        expect(values.last, 1.0);
        for (final value in values) {
          expect(value, inInclusiveRange(0.0, 1.0));
        }
      },
    );

    test('requestNotificationPermission resolves to granted', () async {
      expect(await service.requestNotificationPermission(), isTrue);
    });

    test('requestLocationPermission resolves to granted', () async {
      expect(await service.requestLocationPermission(), isTrue);
    });

    test('parseDeliveryRadius accepts valid positive radius values', () {
      expect(service.parseDeliveryRadius('8.5'), 8.5);
      expect(service.parseDeliveryRadius('2'), 2.0);
      expect(service.parseDeliveryRadius(' 6 '), 6.0);
    });

    test('parseDeliveryRadius falls back for invalid values', () {
      expect(service.parseDeliveryRadius(''), 5.0);
      expect(service.parseDeliveryRadius('abc'), 5.0);
      expect(service.parseDeliveryRadius('-2'), 5.0);
      expect(service.parseDeliveryRadius('0'), 5.0);
      expect(service.parseDeliveryRadius('60'), 5.0);
    });

    test('changePassword validates minimum length', () async {
      expect(await service.changePassword('old', '123456'), isTrue);
      expect(await service.changePassword('old', '123'), isFalse);
    });

    test('deactivateAccount returns true on success', () async {
      expect(await service.deactivateAccount(reason: 'Vacation'), isTrue);
    });

    test('deleteAccount returns true on success', () async {
      expect(await service.deleteAccount(reason: 'Moving'), isTrue);
    });

    test('clearAppCache completes successfully', () async {
      expect(await service.clearAppCache(), isTrue);
    });
  });
}

