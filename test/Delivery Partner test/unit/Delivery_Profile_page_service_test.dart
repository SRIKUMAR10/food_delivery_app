import 'package:flutter_test/flutter_test.dart';

import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Profile_page/Delivery_Profile_page_service.dart';

void main() {
  late DeliveryProfileService service;

  setUp(() {
    service = DeliveryProfileService();
  });

  group('DeliveryProfilePage Service Tests', () {
    test('chunkedUpload yields progress from start to completion', () async {
      final values = await service.chunkedUpload('insurance').toList();

      expect(values, isNotEmpty);
      expect(values.first, greaterThan(0.0));
      expect(values.last, 1.0);
      expect(values.toSet().toList(), List.of(values));
      for (final value in values) {
        expect(value, inInclusiveRange(0.0, 1.0));
      }
    });

    test('validateMedia rejects null and empty paths', () {
      expect(service.validateMedia(null), isNotNull);
      expect(service.validateMedia(''), isNotNull);
    });

    test('validateMedia rejects unsupported file extensions', () {
      expect(service.validateMedia('scan.exe'), isNotNull);
      expect(service.validateMedia('scan.gif'), isNotNull);
    });

    test('validateMedia accepts supported document extensions', () {
      expect(service.validateMedia('license.jpg'), isNull);
      expect(service.validateMedia('rc.pdf'), isNull);
      expect(service.validateMedia('pan.png'), isNull);
    });

    test('getEnvironmentVariables exposes only safe placeholder keys', () {
      final env = service.getEnvironmentVariables();
      expect(env, contains('BASE_URL'));
      expect(env, contains('API_KEY'));
      expect(env, contains('KEY_SECRET'));
      expect(env, contains('UPLOAD_ENDPOINT'));
      expect(
        env.keys,
        containsAll(['BASE_URL', 'API_KEY', 'KEY_SECRET', 'UPLOAD_ENDPOINT']),
      );
      expect(env.keys, hasLength(4));
    });

    test('requestMediaPermission resolves to granted', () async {
      expect(await service.requestMediaPermission(), isTrue);
    });

    test('checkNetworkConnectivity returns a boolean result', () async {
      final result = await service.checkNetworkConnectivity();
      expect(result, isA<bool>());
    });
  });
}
