import 'package:flutter_test/flutter_test.dart';

import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Navigation%20Screen_page/Delivery_Navigation%20Screen_page_state.dart';

void main() {
  group('DeliveryNavigationState Snapshot Tests', () {
    test('default initial state exposes documented defaults', () {
      const state = DeliveryNavigationState();

      expect(state.status, DeliveryNavigationStatus.initial);
      expect(state.localeCode, 'en');
      expect(state.isOffline, isFalse);
      expect(state.hasLocationPermission, isFalse);
      expect(state.audioEnabled, isFalse);
      expect(state.emergencyMode, isFalse);
      expect(state.errorMessage, isNull);
      expect(state.etaMinutes, 6);
      expect(state.distanceKm, 2.1);
      expect(state.nextTurnInstruction, 'Turn Left onto Bhavani Main Road');
      expect(state.turnDistanceMeters, 250.0);
      expect(state.trafficLevel, DeliveryNavigationTrafficLevel.moderate);
      expect(state.mapZoomLevel, 15.0);
      expect(state.isNavigating, isFalse);
    });

    test('loaded state snapshot carries full navigation details', () {
      const state = DeliveryNavigationState(
        status: DeliveryNavigationStatus.loaded,
        hasLocationPermission: true,
        audioEnabled: true,
      );

      expect(state.order.orderId, '#ORD-789456');
      expect(state.order.customerName, 'Senthilkumar');
      expect(state.order.customerPhone, '+91 98420 54321');
      expect(state.pickup.label, 'Pickup');
      expect(state.drop.label, 'Drop');
      expect(state.pickup.iconKey, 'pickup');
      expect(state.drop.iconKey, 'drop');
      expect(state.pickup.address, contains('Bhavani'));
      expect(state.drop.address, contains('Kuruppanaickenpalayam'));
      expect(state.status, DeliveryNavigationStatus.loaded);
    });

    test(
      'copyWith produces an expected snapshot without mutating original',
      () {
        const original = DeliveryNavigationState(
          status: DeliveryNavigationStatus.loaded,
          hasLocationPermission: true,
        );

        final updated = original.copyWith(
          status: DeliveryNavigationStatus.navigating,
          audioEnabled: true,
          trafficLevel: DeliveryNavigationTrafficLevel.heavy,
          mapZoomLevel: 17.5,
        );

        expect(updated.status, DeliveryNavigationStatus.navigating);
        expect(updated.audioEnabled, isTrue);
        expect(updated.trafficLevel, DeliveryNavigationTrafficLevel.heavy);
        expect(updated.mapZoomLevel, 17.5);
        expect(updated.isNavigating, isTrue);

        expect(original.status, DeliveryNavigationStatus.loaded);
        expect(original.audioEnabled, isFalse);
        expect(original.trafficLevel, DeliveryNavigationTrafficLevel.moderate);
        expect(original.mapZoomLevel, 15.0);
      },
    );

    test('clearError wipes the error message in the snapshot', () {
      const errored = DeliveryNavigationState(
        status: DeliveryNavigationStatus.error,
        errorMessage: 'Failed to load route',
      );

      final cleared = errored.copyWith(clearError: true);

      expect(cleared.errorMessage, isNull);
      expect(cleared.status, DeliveryNavigationStatus.error);
      expect(errored.errorMessage, 'Failed to load route');
    });

    test('states are value-equatable by their full snapshot', () {
      const a = DeliveryNavigationState(
        status: DeliveryNavigationStatus.loaded,
        hasLocationPermission: true,
      );
      const b = DeliveryNavigationState(
        status: DeliveryNavigationStatus.loaded,
        hasLocationPermission: true,
      );
      const c = DeliveryNavigationState(
        status: DeliveryNavigationStatus.loaded,
        hasLocationPermission: true,
        audioEnabled: true,
      );

      expect(a, equals(b));
      expect(a, isNot(equals(c)));
      expect(a.props.length, equals(b.props.length));
    });
  });
}
