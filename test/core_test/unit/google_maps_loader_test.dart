import 'package:flutter_test/flutter_test.dart';
import 'package:food_delivery_app/core/services/google_maps_loader.dart';

void main() {
  group('GoogleMapsLoader Tests', () {
    test('isGoogleMapsJsReady returns a bool', () {
      final ready = isGoogleMapsJsReady();
      expect(ready, isA<bool>());
    });

    test('ensureGoogleMapsJsLoaded completes with boolean result', () async {
      final loaded = await ensureGoogleMapsJsLoaded();
      expect(loaded, isA<bool>());
    });

    test('markGoogleMapsAuthFailed executes without error', () {
      expect(() => markGoogleMapsAuthFailed(), returnsNormally);
    });

    test('registerGoogleMapsAuthFailureListener registers callback without error', () {
      expect(() => registerGoogleMapsAuthFailureListener(() {}), returnsNormally);
    });

    test('fetchWebGoogleDirectionsRoute returns Map or null', () async {
      final result = await fetchWebGoogleDirectionsRoute(13.0, 80.0, 13.1, 80.1);
      expect(result, anyOf(isNull, isA<Map<String, dynamic>>()));
    });
  });
}
