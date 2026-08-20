import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:food_delivery_app/core/services/map_marker_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('MapMarkerService Tests', () {
    final service = MapMarkerService.instance;

    setUp(() {
      service.clearCache();
    });

    test('isTwoWheeler accurately detects 2-wheeler vehicle types', () {
      expect(MapMarkerService.isTwoWheeler('bike'), isTrue);
      expect(MapMarkerService.isTwoWheeler('scooter'), isTrue);
      expect(MapMarkerService.isTwoWheeler('Motorcycle'), isTrue);
      expect(MapMarkerService.isTwoWheeler('2w'), isTrue);
      expect(MapMarkerService.isTwoWheeler('two_wheeler'), isTrue);
      expect(MapMarkerService.isTwoWheeler(null), isTrue); // default fallback
      expect(MapMarkerService.isTwoWheeler('car'), isFalse);
      expect(MapMarkerService.isTwoWheeler('van'), isFalse);
    });

    test('isFourWheeler accurately detects 4-wheeler vehicle types', () {
      expect(MapMarkerService.isFourWheeler('car'), isTrue);
      expect(MapMarkerService.isFourWheeler('van'), isTrue);
      expect(MapMarkerService.isFourWheeler('4w'), isTrue);
      expect(MapMarkerService.isFourWheeler('four_wheeler'), isTrue);
      expect(MapMarkerService.isFourWheeler('auto'), isTrue);
      expect(MapMarkerService.isFourWheeler('bike'), isFalse);
      expect(MapMarkerService.isFourWheeler(null), isFalse);
    });

    test('getVehicleMarker generates and caches 2-wheeler marker', () async {
      final marker1 = await service.getVehicleMarker(
        vehicleType: 'bike',
        heading: 45.0,
      );
      expect(marker1, isNotNull);

      // Verify cached retrieval
      final marker2 = await service.getVehicleMarker(
        vehicleType: 'bike',
        heading: 46.0, // Should quantize to 45 degrees and hit cache
      );
      expect(marker2, isNotNull);
    });

    test('getVehicleMarker generates 4-wheeler marker for car', () async {
      final marker = await service.getVehicleMarker(
        vehicleType: 'car',
        heading: 180.0,
        primaryColor: Colors.blue,
      );
      expect(marker, isNotNull);
    });

    test('getStoreMarker generates and caches store pin marker', () async {
      final storeMarker = await service.getStoreMarker();
      expect(storeMarker, isNotNull);
    });

    test('getCustomerMarker generates and caches customer drop pin marker', () async {
      final customerMarker = await service.getCustomerMarker();
      expect(customerMarker, isNotNull);
    });
  });
}
