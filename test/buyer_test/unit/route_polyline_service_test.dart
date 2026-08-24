import 'package:flutter_test/flutter_test.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:food_delivery_app/core/services/route_polyline_service.dart';

void main() {
  group('RoutePolylineService', () {
    late RoutePolylineService service;

    setUp(() {
      service = RoutePolylineService();
      service.clearCache();
    });

    test('decodePolyline decodes standard encoded polyline string accurately', () {
      // Standard encoded polyline string representing coordinates
      // (38.5, -120.2), (40.7, -120.95), (43.252, -126.453)
      const encoded = '_p~iF~ps|U_ulLnnqC_mqNvxq`@';
      final points = service.decodePolyline(encoded);

      expect(points.length, equals(3));
      expect(points[0].latitude, closeTo(38.5, 0.001));
      expect(points[0].longitude, closeTo(-120.2, 0.001));
      expect(points[1].latitude, closeTo(40.7, 0.001));
      expect(points[1].longitude, closeTo(-120.95, 0.001));
      expect(points[2].latitude, closeTo(43.252, 0.001));
      expect(points[2].longitude, closeTo(-126.453, 0.001));
    });

    test('calculateBearing calculates directional compass degrees correctly', () {
      const start = LatLng(13.0827, 80.2707);
      // Point due north
      const north = LatLng(14.0827, 80.2707);
      final bearingNorth = service.calculateBearing(start, north);
      expect(bearingNorth, closeTo(0.0, 1.0));

      // Point due east
      const east = LatLng(13.0827, 81.2707);
      final bearingEast = service.calculateBearing(start, east);
      expect(bearingEast, closeTo(90.0, 1.0));
    });

    test('computeBounds returns inclusive bounding box with margin padding', () {
      const p1 = LatLng(13.0827, 80.2707);
      const p2 = LatLng(13.0900, 80.2800);

      final bounds = service.computeBounds([p1, p2]);
      expect(bounds.southwest.latitude, lessThan(13.0827));
      expect(bounds.southwest.longitude, lessThan(80.2707));
      expect(bounds.northeast.latitude, greaterThan(13.0900));
      expect(bounds.northeast.longitude, greaterThan(80.2800));
    });

    test('generateSmoothPath produces intermediate multi-step curvature waypoints', () {
      const start = LatLng(13.0827, 80.2707);
      const end = LatLng(13.0927, 80.2807);

      final path = service.generateSmoothPath(start, end, steps: 16);
      expect(path.length, equals(17));
      expect(path.first.latitude, closeTo(start.latitude, 0.0001));
      expect(path.last.latitude, closeTo(end.latitude, 0.0001));
    });

    test('generateJourneyPolylines generates pre-pickup and post-pickup legs', () {
      const store = LatLng(13.0850, 80.2750);
      const driver = LatLng(13.0800, 80.2700);
      const customer = LatLng(13.0900, 80.2800);

      // Pre-pickup: Driver -> Store active, Store -> Customer upcoming
      final prePolylines = service.generateJourneyPolylines(
        storeLocation: store,
        driverLocation: driver,
        customerLocation: customer,
        isPickedUp: false,
      );
      expect(prePolylines.length, equals(2));
      expect(prePolylines.any((p) => p.polylineId.value == 'driver_to_store_active'), isTrue);
      expect(prePolylines.any((p) => p.polylineId.value == 'store_to_customer_upcoming'), isTrue);

      // Post-pickup: Store -> Driver completed, Driver -> Customer active
      final postPolylines = service.generateJourneyPolylines(
        storeLocation: store,
        driverLocation: driver,
        customerLocation: customer,
        isPickedUp: true,
      );
      expect(postPolylines.length, equals(2));
      expect(postPolylines.any((p) => p.polylineId.value == 'store_to_driver_completed'), isTrue);
      expect(postPolylines.any((p) => p.polylineId.value == 'driver_to_customer_active'), isTrue);
    });

    test('generateRealRoadJourneyPolylines generates polylines asynchronously with fallback', () async {
      const store = LatLng(13.0850, 80.2750);
      const driver = LatLng(13.0800, 80.2700);
      const customer = LatLng(13.0900, 80.2800);

      final polylines = await service.generateRealRoadJourneyPolylines(
        storeLocation: store,
        driverLocation: driver,
        customerLocation: customer,
        isPickedUp: false,
      );

      expect(polylines.isNotEmpty, isTrue);
      expect(polylines.any((p) => p.polylineId.value == 'driver_to_store_active'), isTrue);
      expect(polylines.any((p) => p.polylineId.value == 'store_to_customer_upcoming'), isTrue);
    });

    test('fetchRoadRoute caches verified real road routes between coordinates', () async {
      const start = LatLng(11.4555052, 77.6873137);
      const end = LatLng(11.4299713, 77.6759418);

      final route1 = await service.fetchRoadRoute(start, end);
      final route2 = await service.fetchRoadRoute(start, end);

      expect(identical(route1, route2), isTrue);
    });

    test('fetchRoadRouteAndETA returns instant result for identical coordinates', () async {
      const point = LatLng(13.0827, 80.2707);
      final result = await service.fetchRoadRouteAndETA(point, point);
      expect(result.points.length, equals(2));
      expect(result.durationText, equals('0 mins'));
      expect(result.distanceText, equals('0 km'));
    });

    test('RouteAndEtaResult.fromDirectionsJson parses intermediate step polylines', () {
      final mockDirectionsJson = {
        'routes': [
          {
            'bounds': {
              'northeast': {'lat': 13.10, 'lng': 80.30},
              'southwest': {'lat': 13.00, 'lng': 80.20},
            },
            'legs': [
              {
                'distance': {'text': '10 km', 'value': 10000},
                'duration': {'text': '20 mins', 'value': 1200},
                'steps': [
                  {
                    'polyline': {'points': '_p~iF~ps|U_ulLnnqC'},
                  },
                  {
                    'polyline': {'points': '_ulLnnqC_mqNvxq`@'},
                  }
                ]
              }
            ],
            'overview_polyline': {
              'points': '_p~iF~ps|U_ulLnnqC_mqNvxq`@',
            }
          }
        ],
        'status': 'OK'
      };

      final result = RouteAndEtaResult.fromDirectionsJson(mockDirectionsJson);
      expect(result.points.length, greaterThanOrEqualTo(2));
    });

    test('snapToPolyline accurately snaps raw coordinate to closest road segment', () {
      final polyline = [
        const LatLng(13.0000, 80.0000),
        const LatLng(13.0100, 80.0000),
        const LatLng(13.0100, 80.0100),
      ];

      const rawGps = LatLng(13.0050, 80.0005);
      final snap = service.snapToPolyline(rawGps, polyline);

      expect(snap.segmentIndex, equals(0));
      expect(snap.snappedPosition.latitude, closeTo(13.0050, 0.0001));
      expect(snap.snappedPosition.longitude, closeTo(80.0000, 0.0001));
      expect(snap.bearing, closeTo(0.0, 1.0));
      expect(snap.remainingPoints.length, equals(3));
    });

    test('getRemainingPolyline slices polyline starting from current position', () {
      final polyline = [
        const LatLng(13.0000, 80.0000),
        const LatLng(13.0100, 80.0000),
        const LatLng(13.0200, 80.0000),
      ];

      const current = LatLng(13.0050, 80.0000);
      final remaining = service.getRemainingPolyline(current, polyline);

      expect(remaining.length, equals(3));
      expect(remaining.first.latitude, closeTo(13.0050, 0.0001));
      expect(remaining.last, equals(polyline.last));
    });
  });
}
