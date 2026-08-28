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

    test(
        'decodePolyline decodes standard encoded polyline string accurately',
        () {
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

    test('calculateBearing calculates directional compass degrees correctly',
        () {
      const start = LatLng(13.0827, 80.2707);
      const north = LatLng(14.0827, 80.2707);
      final bearingNorth = service.calculateBearing(start, north);
      expect(bearingNorth, closeTo(0.0, 1.0));

      const east = LatLng(13.0827, 81.2707);
      final bearingEast = service.calculateBearing(start, east);
      expect(bearingEast, closeTo(90.0, 1.0));
    });

    test('computeBounds returns inclusive bounding box with margin padding',
        () {
      const p1 = LatLng(13.0827, 80.2707);
      const p2 = LatLng(13.0900, 80.2800);

      final bounds = service.computeBounds([p1, p2]);
      expect(bounds.southwest.latitude, lessThan(13.0827));
      expect(bounds.southwest.longitude, lessThan(80.2707));
      expect(bounds.northeast.latitude, greaterThan(13.0900));
      expect(bounds.northeast.longitude, greaterThan(80.2800));
    });

    test('generateJourneyPolylines returns empty set under strict real data policy',
        () {
      const store = LatLng(13.0850, 80.2750);
      const driver = LatLng(13.0800, 80.2700);
      const customer = LatLng(13.0900, 80.2800);

      final polylines = service.generateJourneyPolylines(
        storeLocation: store,
        driverLocation: driver,
        customerLocation: customer,
        isPickedUp: false,
      );
      expect(polylines, isEmpty);
    });

    test('fetchRoadRouteAndETA returns instant result for identical coordinates',
        () async {
      const point = LatLng(13.0827, 80.2707);
      final result = await service.fetchRoadRouteAndETA(point, point);
      expect(result.points.length, equals(2));
      expect(result.durationText, equals('0 mins'));
      expect(result.distanceText, equals('0 km'));
    });

    test('RouteAndEtaResult.fromDirectionsJson parses intermediate step polylines',
        () {
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
                    'html_instructions': 'Head north on Main St',
                    'maneuver': 'depart',
                    'distance': {'text': '5 km', 'value': 5000},
                    'duration': {'text': '10 mins', 'value': 600},
                    'start_location': {'lat': 13.00, 'lng': 80.20},
                    'end_location': {'lat': 13.05, 'lng': 80.25},
                    'polyline': {'points': '_p~iF~ps|U_ulLnnqC'},
                  },
                  {
                    'html_instructions': 'Turn right on Park Ave',
                    'maneuver': 'turn-right',
                    'distance': {'text': '5 km', 'value': 5000},
                    'duration': {'text': '10 mins', 'value': 600},
                    'start_location': {'lat': 13.05, 'lng': 80.25},
                    'end_location': {'lat': 13.10, 'lng': 80.30},
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
      expect(result.steps.length, equals(2));
      expect(result.steps[0].maneuver, equals(RouteManeuver.depart));
      expect(result.steps[1].maneuver, equals(RouteManeuver.turnRight));
    });

    test(
        'snapToPolyline accurately snaps raw coordinate to closest road segment',
        () {
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

    test(
        'getRemainingPolyline slices polyline starting from current position',
        () {
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
