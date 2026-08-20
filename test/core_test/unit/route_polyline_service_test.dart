import 'package:flutter_test/flutter_test.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:food_delivery_app/core/services/route_polyline_service.dart';

void main() {
  group('RoutePolylineService Tests', () {
    late RoutePolylineService service;

    setUp(() {
      service = RoutePolylineService();
      service.clearCache();
    });

    const storeLoc = LatLng(13.0827, 80.2707);
    const driverLoc = LatLng(13.0850, 80.2750);
    const customerLoc = LatLng(13.0900, 80.2800);

    test('generateJourneyPolylines creates stage 1 active and stage 2 upcoming polylines before pickup', () {
      final polylines = service.generateJourneyPolylines(
        storeLocation: storeLoc,
        driverLocation: driverLoc,
        customerLocation: customerLoc,
        isPickedUp: false,
      );

      expect(polylines.length, 2);
      final polylineIds = polylines.map((p) => p.polylineId.value).toSet();
      expect(polylineIds.contains('driver_to_store_active'), isTrue);
      expect(polylineIds.contains('store_to_customer_upcoming'), isTrue);
    });

    test('generateJourneyPolylines creates completed and active delivery polylines after pickup', () {
      final polylines = service.generateJourneyPolylines(
        storeLocation: storeLoc,
        driverLocation: driverLoc,
        customerLocation: customerLoc,
        isPickedUp: true,
      );

      expect(polylines.length, 2);
      final polylineIds = polylines.map((p) => p.polylineId.value).toSet();
      expect(polylineIds.contains('store_to_driver_completed'), isTrue);
      expect(polylineIds.contains('driver_to_customer_active'), isTrue);
    });

    test('generateSmoothPath produces interpolated curved points', () {
      final path = service.generateSmoothPath(storeLoc, customerLoc, steps: 10);
      expect(path.length, 11);
      expect(path.first.latitude, storeLoc.latitude);
      expect(path.last.latitude, customerLoc.latitude);
    });

    test('calculateBearing calculates valid angle between coordinates', () {
      final bearing = service.calculateBearing(
        const LatLng(0.0, 0.0),
        const LatLng(1.0, 1.0),
      );
      expect(bearing, isNonNegative);
      expect(bearing, lessThanOrEqualTo(360.0));
    });

    test('computeBounds accurately bounds all given coordinates', () {
      final bounds = service.computeBounds([storeLoc, driverLoc, customerLoc]);
      expect(bounds.southwest.latitude, lessThan(storeLoc.latitude));
      expect(bounds.northeast.latitude, greaterThan(customerLoc.latitude));
    });
  });
}
