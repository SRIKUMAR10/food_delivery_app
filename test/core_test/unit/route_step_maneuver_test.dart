import 'package:flutter_test/flutter_test.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:food_delivery_app/core/services/route_polyline_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('RouteStepInfo & RouteManeuver Unit Tests', () {
    test('RouteManeuver fromString parses various maneuver strings accurately',
        () {
      expect(RouteManeuver.fromString('turn-left'),
          equals(RouteManeuver.turnLeft));
      expect(RouteManeuver.fromString('turn-right'),
          equals(RouteManeuver.turnRight));
      expect(RouteManeuver.fromString('turn-slight-left'),
          equals(RouteManeuver.turnSlightLeft));
      expect(RouteManeuver.fromString('turn-slight-right'),
          equals(RouteManeuver.turnSlightRight));
      expect(RouteManeuver.fromString('turn-sharp-left'),
          equals(RouteManeuver.turnSharpLeft));
      expect(RouteManeuver.fromString('turn-sharp-right'),
          equals(RouteManeuver.turnSharpRight));
      expect(RouteManeuver.fromString('uturn-left'),
          equals(RouteManeuver.uturn));
      expect(RouteManeuver.fromString('roundabout'),
          equals(RouteManeuver.roundabout));
      expect(
          RouteManeuver.fromString('arrive'), equals(RouteManeuver.arrive));
      expect(
          RouteManeuver.fromString('straight'), equals(RouteManeuver.straight));
      expect(
          RouteManeuver.fromString('unknown_xyz'), equals(RouteManeuver.straight));
      expect(RouteManeuver.fromString(null), equals(RouteManeuver.unknown));
    });

    test('RouteStepInfo.fromGoogleStep parses Google Directions step correctly',
        () {
      final googleStepJson = {
        'html_instructions': 'Turn <b>left</b> onto <b>Main St</b>',
        'maneuver': 'turn-left',
        'distance': {'text': '350 m', 'value': 350},
        'duration': {'text': '2 mins', 'value': 120},
        'start_location': {'lat': 13.0827, 'lng': 80.2707},
        'end_location': {'lat': 13.0850, 'lng': 80.2720},
        'polyline': {'points': ''},
      };

      final step = RouteStepInfo.fromGoogleStep(googleStepJson);

      expect(step.instruction, equals('Turn left onto Main St'));
      expect(step.maneuver, equals(RouteManeuver.turnLeft));
      expect(step.distanceMeters, equals(350));
      expect(step.distanceText, equals('350 m'));
      expect(step.durationSeconds, equals(120));
      expect(step.startLocation, equals(const LatLng(13.0827, 80.2707)));
      expect(step.endLocation, equals(const LatLng(13.0850, 80.2720)));
    });

    test('RouteStepInfo.fromOsrmStep parses OSRM step correctly', () {
      final osrmStepJson = {
        'name': 'Anna Salai',
        'distance': 420.0,
        'duration': 45.0,
        'maneuver': {
          'type': 'turn',
          'modifier': 'right',
          'location': [80.2707, 13.0827],
        },
        'geometry': '',
      };

      final step = RouteStepInfo.fromOsrmStep(osrmStepJson);

      expect(step.instruction, equals('Turn right onto Anna Salai'));
      expect(step.maneuver, equals(RouteManeuver.turnRight));
      expect(step.distanceMeters, equals(420));
      expect(step.distanceText, equals('420 m'));
      expect(step.streetName, equals('Anna Salai'));
      expect(step.startLocation, equals(const LatLng(13.0827, 80.2707)));
    });

    test('RouteAndEtaResult.empty returns verified empty state without fake data',
        () {
      final emptyResult = RouteAndEtaResult.empty();

      expect(emptyResult.points, isEmpty);
      expect(emptyResult.steps, isEmpty);
      expect(emptyResult.durationText, equals('-- mins'));
      expect(emptyResult.distanceText, equals('-- km'));
      expect(emptyResult.durationSeconds, equals(0));
      expect(emptyResult.distanceMeters, equals(0));
    });

    test('generateJourneyPolylines returns empty set to avoid fake routes', () {
      final polylines = RoutePolylineService.instance.generateJourneyPolylines(
        storeLocation: const LatLng(13.0827, 80.2707),
        driverLocation: const LatLng(13.0850, 80.2720),
        customerLocation: const LatLng(13.0900, 80.2750),
      );

      expect(polylines, isEmpty);
    });
  });
}
