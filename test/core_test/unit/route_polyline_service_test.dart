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

    test('fetchRoadRouteAndETA returns instant result for identical coordinates', () async {
      final result = await service.fetchRoadRouteAndETA(storeLoc, storeLoc);
      expect(result.points.length, 2);
      expect(result.durationText, '0 mins');
      expect(result.distanceText, '0 km');
    });

    test('decodePolyline decodes standard encoded polyline strings accurately', () {
      // Encoded polyline for (38.5, -120.2) to (40.7, -120.95) to (43.252, -126.453)
      const encoded = '_p~iF~ps|U_ulLnnqC_mqNvxq`@';
      final points = service.decodePolyline(encoded);
      expect(points.isNotEmpty, isTrue);
      expect((points.first.latitude - 38.5).abs(), lessThan(0.01));
      expect((points.first.longitude - -120.2).abs(), lessThan(0.01));
    });

    test('decodePolyline handles empty or malformed strings gracefully without throwing', () {
      expect(service.decodePolyline(''), isEmpty);
      expect(service.decodePolyline('???invalid???'), isA<List<LatLng>>());
    });

    test('Cache is verified properly with isCached check', () async {
      const p1 = LatLng(12.9716, 77.5946);
      const p2 = LatLng(12.9750, 77.6000);

      expect(service.isCached(p1, p2), isFalse);
    });

    test('RouteStepInfo.fromGoogleStep parses step instructions and distance', () {
      final stepJson = {
        'html_instructions': 'Turn <b>left</b> onto <b>NH-47</b>',
        'maneuver': 'turn-left',
        'distance': {'text': '500 m', 'value': 500},
        'duration': {'text': '1 min', 'value': 60},
        'start_location': {'lat': 11.4299, 'lng': 77.6759},
        'end_location': {'lat': 11.4350, 'lng': 77.6800},
      };
      final step = RouteStepInfo.fromGoogleStep(stepJson);
      expect(step.maneuver, RouteManeuver.turnLeft);
      expect(step.distanceMeters, 500);
      expect(step.durationText, '1 min');
    });

    test('Haversine and path distance calculations are accurate', () {
      const p1 = LatLng(13.0827, 80.2707);
      const p2 = LatLng(13.0927, 80.2707);

      final dist = service.haversineDistanceMeters(p1, p2);
      expect(dist, greaterThan(1000));
      expect(dist, lessThan(1200));

      final total = service.calculateTotalPathDistanceMeters([p1, p2]);
      expect(total, equals(dist));
    });

    test('RouteAndEtaResult.fromDirectionsJson parses overview_polyline, distance, duration, and bounds', () {
      final mockJson = {
        'routes': [
          {
            'bounds': {
              'northeast': {'lat': 11.4555, 'lng': 77.6873},
              'southwest': {'lat': 11.4299, 'lng': 77.6759},
            },
            'legs': [
              {
                'distance': {'text': '5.7 km', 'value': 5740},
                'duration': {'text': '14 mins', 'value': 840},
              }
            ],
            'overview_polyline': {
              'points': '_p~iF~ps|U_ulLnnqC_mqNvxq`@',
            }
          }
        ],
        'status': 'OK'
      };

      final result = RouteAndEtaResult.fromDirectionsJson(mockJson);
      expect(result.points.isNotEmpty, isTrue);
      expect(result.distanceText, equals('5.7 km'));
      expect(result.distanceMeters, equals(5740));
      expect(result.durationText, equals('14 mins'));
      expect(result.durationSeconds, equals(840));
      expect(result.bounds, isNotNull);
      expect(result.bounds!.northeast.latitude, equals(11.4555));
      expect(result.bounds!.southwest.longitude, equals(77.6759));
    });

    test('RouteAndEtaResult.fromOsrmJson parses geometry, distance, and duration correctly', () {
      final mockOsrmJson = {
        'code': 'Ok',
        'routes': [
          {
            'geometry': '_p~iF~ps|U_ulLnnqC_mqNvxq`@',
            'distance': 3450.0,
            'duration': 420.0,
          }
        ]
      };

      final result = RouteAndEtaResult.fromOsrmJson(mockOsrmJson);
      expect(result.points.isNotEmpty, isTrue);
      expect(result.distanceMeters, equals(3450));
      expect(result.distanceText, equals('3.5 km'));
      expect(result.durationSeconds, equals(420));
      expect(result.durationText, equals('7 mins'));
    });

    test('RouteAndEtaResult.fromDirectionsJson decodes and concatenates intermediate step polylines', () {
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
                    'polyline': {'points': '_p~iF~ps|U_ulLnnqC'}, // step 1
                  },
                  {
                    'polyline': {'points': '_ulLnnqC_mqNvxq`@'}, // step 2
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
      expect(result.distanceText, equals('10 km'));
      expect(result.durationText, equals('20 mins'));
    });

    test('snapToPolyline accurately snaps point to nearest segment and calculates bearing and remaining path', () {
      final polyline = [
        const LatLng(13.0000, 80.0000),
        const LatLng(13.0100, 80.0000), // Due North segment 1
        const LatLng(13.0100, 80.0100), // Due East segment 2
      ];

      // Point slightly to the East of segment 1 (13.0050, 80.0005)
      const rawGps = LatLng(13.0050, 80.0005);
      final snapResult = service.snapToPolyline(rawGps, polyline);

      expect(snapResult.segmentIndex, equals(0));
      expect(snapResult.snappedPosition.latitude, closeTo(13.0050, 0.0001));
      expect(snapResult.snappedPosition.longitude, closeTo(80.0000, 0.0001));
      expect(snapResult.bearing, closeTo(0.0, 1.0)); // Due North
      expect(snapResult.distanceFromPolylineMeters, greaterThan(0));
      expect(snapResult.distanceFromPolylineMeters, lessThan(100));
      expect(snapResult.remainingPoints.length, equals(3)); // [snapped, p2, p3]
      expect(snapResult.remainingDistanceMeters, greaterThan(0));
    });

    test('getRemainingPolyline returns sub-route starting at snapped position', () {
      final polyline = [
        const LatLng(13.0000, 80.0000),
        const LatLng(13.0100, 80.0000),
        const LatLng(13.0200, 80.0000),
      ];

      const currentGps = LatLng(13.0060, 80.0001);
      final remaining = service.getRemainingPolyline(currentGps, polyline);

      expect(remaining.length, equals(3));
      expect(remaining.first.latitude, closeTo(13.0060, 0.0001));
      expect(remaining.last, equals(polyline.last));
    });
  });
}

