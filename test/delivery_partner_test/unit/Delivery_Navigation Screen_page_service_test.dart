import 'package:flutter_test/flutter_test.dart';

import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Navigation%20Screen_page/Delivery_Navigation%20Screen_page_service.dart';

void main() {
  late DeliveryNavigationService service;

  setUp(() {
    service = DeliveryNavigationService();
  });

  group('DeliveryNavigationService Unit Tests', () {
    test('calculateEstimatedEta returns 18 minutes for 6.2 km', () {
      expect(service.calculateEstimatedEta(6.2), 18);
      expect(service.calculateEstimatedEta(4.0), 12);
    });

    test('calculateEstimatedEta returns 0 for non-positive distances', () {
      expect(service.calculateEstimatedEta(0), 0);
      expect(service.calculateEstimatedEta(-3.5), 0);
    });

    test('sanitizeInput trims whitespace and strips unsafe characters', () {
      expect(service.sanitizeInput('  Arun Kumar  '), 'Arun Kumar');
      expect(service.sanitizeInput('+91 98765 43210'), '+91 98765 43210');
      expect(
        service.sanitizeInput('45, 3rd Cross Street; <script>'),
        '45, 3rd Cross Street script',
      );
    });

    test('sanitizeInput returns null for empty or null input', () {
      expect(service.sanitizeInput(null), isNull);
      expect(service.sanitizeInput(''), isNull);
      expect(service.sanitizeInput('   '), isNull);
    });

    test('sanitizeInput truncates over-long inputs', () {
      final long = List.filled(300, 'a').join();
      final sanitized = service.sanitizeInput(long);

      expect(sanitized, hasLength(200));
    });

    test('getEnvironmentVariables exposes only placeholder keys', () {
      final env = service.getEnvironmentVariables();

      expect(
        env.keys,
        containsAll(['BASE_URL', 'API_KEY', 'KEY_SECRET', 'MAPS_API_KEY']),
      );
      expect(env.keys, hasLength(4));
      expect(env['MAPS_API_KEY'], isA<String>());
    });

    test('checkLocationPermission returns a boolean result', () async {
      expect(await service.checkLocationPermission(), isA<bool>());
    });

    test('requestLocationPermission resolves to granted', () async {
      expect(await service.requestLocationPermission(), isTrue);
    });

    test('simulateLiveLocation yields decreasing in-range deltas', () async {
      final values = await service.simulateLiveLocation().toList();

      expect(values, isNotEmpty);
      expect(values.last, lessThan(values.first));
      for (final value in values) {
        expect(value, inInclusiveRange(1.0, 100.0));
      }
    });

    test('checkConnectivity returns a boolean result', () async {
      final result = await service.checkConnectivity();
      expect(result, isA<bool>());
    });

    test('fetchDemandZones returns Chennai hotspot coordinates', () async {
      final zones = await service.fetchDemandZones();

      expect(zones, isNotNull);
      expect(zones, isNotEmpty);
      expect(zones!.first, contains('name'));
      expect(zones.first, contains('latitude'));
      expect(zones.first, contains('longitude'));
    });

    test('fetchActiveOrder resolves null when Firestore is unavailable', () async {
      expect(await service.fetchActiveOrder(), isNull);
      expect(await service.fetchActiveOrder(orderId: 'ORD-123456'), isNull);
    });
  });
}
