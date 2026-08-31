import 'package:flutter_test/flutter_test.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:food_delivery_app/core/services/realtime_vehicle_route_navigator.dart';

void main() {
  group('RealtimeVehicleRouteNavigator Tests', () {
    late RealtimeVehicleRouteNavigator navigator;

    const startLocation = LatLng(11.4555052, 77.6873137); // Delivery Partner Start
    const zoloRestaurantLocation = LatLng(11.4299713, 77.6759418); // Zolo Family Restaurant

    setUp(() {
      navigator = RealtimeVehicleRouteNavigator.instance;
      navigator.stopNavigation();
    });

    tearDown(() {
      navigator.stopNavigation();
    });

    test('Singleton instance returns identical object', () {
      final nav1 = RealtimeVehicleRouteNavigator();
      final nav2 = RealtimeVehicleRouteNavigator.instance;
      expect(identical(nav1, nav2), isTrue);
    });

    test('VehicleTelemetry toMap serialization includes all fields', () {
      const telemetry = VehicleTelemetry(
        currentPosition: startLocation,
        heading: 45.0,
        speedKmh: 35.5,
        remainingDistanceKm: 2.45,
        remainingDistanceMeters: 2450.0,
        etaMinutes: 4,
        progressRatio: 0.15,
        isArrived: false,
        statusMessage: 'Navigating to Zolo Family Restaurant',
        currentWaypointIndex: 2,
      );

      final map = telemetry.toMap();
      expect(map['lat'], startLocation.latitude);
      expect(map['lng'], startLocation.longitude);
      expect(map['heading'], 45.0);
      expect(map['speedKmh'], 35.5);
      expect(map['remainingDistanceKm'], 2.45);
      expect(map['isArrived'], isFalse);
      expect(map['statusMessage'], 'Navigating to Zolo Family Restaurant');
      expect(map['timestamp'], isNotNull);
    });

    test('startNavigation emits initial telemetry along real road waypoints to Zolo Restaurant', () async {
      final customPoints = [
        startLocation,
        const LatLng(11.4450000, 77.6820000),
        const LatLng(11.4350000, 77.6780000),
        zoloRestaurantLocation,
      ];

      final stream = navigator.startNavigation(
        start: startLocation,
        destination: zoloRestaurantLocation,
        destinationName: 'Zolo Family Restaurant',
        customRoutePoints: customPoints,
        simulationSpeedMultiplier: 50.0,
        tickInterval: const Duration(milliseconds: 10),
      );

      expect(navigator.isNavigating, isTrue);

      final firstTelemetry = await stream.first;
      expect(firstTelemetry.currentPosition.latitude, closeTo(startLocation.latitude, 0.001));
      expect(firstTelemetry.currentPosition.longitude, closeTo(startLocation.longitude, 0.001));
      expect(firstTelemetry.heading, isNonNegative);
      expect(firstTelemetry.remainingDistanceKm, isPositive);
      expect(firstTelemetry.isArrived, isFalse);
      expect(firstTelemetry.fullRoutePoints.length, 4);
    });

    test('Navigation completes smoothly when reaching Zolo Family Restaurant', () async {
      final customPoints = [
        startLocation,
        zoloRestaurantLocation,
      ];

      final stream = navigator.startNavigation(
        start: startLocation,
        destination: zoloRestaurantLocation,
        destinationName: 'Zolo Family Restaurant',
        customRoutePoints: customPoints,
        simulationSpeedMultiplier: 500.0, // High multiplier to complete fast in test
        tickInterval: const Duration(milliseconds: 5),
      );

      final telemetries = await stream.take(20).toList();
      expect(telemetries.isNotEmpty, isTrue);

      final last = telemetries.last;
      if (last.isArrived) {
        expect(last.speedKmh, 0.0);
        expect(last.remainingDistanceKm, 0.0);
        expect(last.progressRatio, 1.0);
        expect(last.statusMessage, contains('Arrived at Zolo Family Restaurant'));
      }
    });

    test('stopNavigation cleanly cancels loop and stream controller', () {
      navigator.startNavigation(
        start: startLocation,
        destination: zoloRestaurantLocation,
        tickInterval: const Duration(milliseconds: 50),
      );

      expect(navigator.isNavigating, isTrue);
      navigator.stopNavigation();
      expect(navigator.isNavigating, isFalse);
    });
  });
}
