import 'package:flutter_test/flutter_test.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:food_delivery_app/core/services/voice_navigation_service.dart';
import 'package:food_delivery_app/core/services/route_polyline_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('VoiceNavigationService Unit Tests', () {
    late VoiceNavigationService service;

    setUp(() {
      service = VoiceNavigationService.instance;
      service.setMuted(false);
      service.resetSession();
    });

    test('Initial mute state is false', () {
      expect(service.isMuted, isFalse);
    });

    test('toggleMute and setMuted accurately toggle audio state', () {
      service.setMuted(true);
      expect(service.isMuted, isTrue);

      service.toggleMute();
      expect(service.isMuted, isFalse);
    });

    test('announceManeuver runs without error for verified step', () async {
      const step = RouteStepInfo(
        instruction: 'Turn left onto Gandhi Road',
        maneuver: RouteManeuver.turnLeft,
        distanceText: '200 m',
        distanceMeters: 200,
        durationText: '1 min',
        durationSeconds: 60,
        startLocation: LatLng(13.0827, 80.2707),
        endLocation: LatLng(13.0850, 80.2720),
        streetName: 'Gandhi Road',
      );

      // 200m distance bracket
      await service.announceManeuver(
        step: step,
        distanceToStepMeters: 190.0,
        stepIndex: 0,
      );

      // 50m distance bracket
      await service.announceManeuver(
        step: step,
        distanceToStepMeters: 45.0,
        stepIndex: 0,
      );

      // At turn (0m bracket)
      await service.announceManeuver(
        step: step,
        distanceToStepMeters: 10.0,
        stepIndex: 0,
      );

      expect(service.isMuted, isFalse);
    });

    test('announceArrival executes safely', () async {
      await service.announceArrival(isStore: true);
      await service.announceArrival(isStore: false);
      expect(service.isMuted, isFalse);
    });
  });
}
