import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:food_delivery_app/core/services/google_places_service.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Profile_page/delivery_google_address_search_dialog.dart';

class MockGooglePlacesService extends Mock implements GooglePlacesService {}

void main() {
  group('DeliveryGoogleAddressSearchDialog Widget Tests', () {
    late MockGooglePlacesService mockPlacesService;

    setUp(() {
      mockPlacesService = MockGooglePlacesService();

      when(() => mockPlacesService.searchPlaces(any()))
          .thenAnswer((_) async => [
                const GooglePlacePrediction(
                  placeId: 'place_1',
                  mainText: 'Anna Nagar West',
                  secondaryText: 'Chennai, Tamil Nadu, India',
                  description: 'Anna Nagar West, Chennai, Tamil Nadu, India',
                ),
              ]);

      when(() => mockPlacesService.getPlaceDetails(any(), fallbackAddress: any(named: 'fallbackAddress')))
          .thenAnswer((_) async => const GooglePlaceDetails(
                placeId: 'place_1',
                formattedAddress: 'Anna Nagar West, Chennai, Tamil Nadu, India',
                mainText: 'Anna Nagar West',
                latitude: 13.0850,
                longitude: 80.2100,
              ));

      when(() => mockPlacesService.getCurrentLocationAddress())
          .thenAnswer((_) async => const GooglePlaceDetails(
                placeId: 'current_gps',
                formattedAddress: 'T. Nagar, Chennai, Tamil Nadu, India',
                mainText: 'T. Nagar',
                latitude: 13.0418,
                longitude: 80.2341,
              ));

      when(() => mockPlacesService.reverseGeocode(any(), any()))
          .thenAnswer((_) async => const GooglePlaceDetails(
                placeId: 'pin_geocode',
                formattedAddress: 'Velachery, Chennai, Tamil Nadu, India',
                mainText: 'Velachery',
                latitude: 12.9815,
                longitude: 80.2180,
              ));
    });

    Widget createTestWidget({required ValueChanged<AddressSelectionResult> onSelected}) {
      return MaterialApp(
        home: Scaffold(
          body: DeliveryGoogleAddressSearchDialog(
            addressType: 'Home',
            currentAddress: '',
            placesService: mockPlacesService,
            onAddressSelected: onSelected,
          ),
        ),
      );
    }

    testWidgets('renders search mode with dark delivery theme and tab bar', (tester) async {
      await tester.pumpWidget(createTestWidget(onSelected: (_) {}));
      await tester.pumpAndSettle();

      expect(find.text('Set Home Address'), findsOneWidget);
      expect(find.text('Search Address'), findsOneWidget);
      expect(find.text('Pick on Map'), findsOneWidget);
      expect(find.byKey(const ValueKey('addressSearchInputField')), findsOneWidget);
      expect(find.byKey(const ValueKey('useCurrentLocationButton')), findsOneWidget);
    });

    testWidgets('switches to Pick on Map mode when Pick on Map tab is tapped', (tester) async {
      await tester.pumpWidget(createTestWidget(onSelected: (_) {}));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Pick on Map'));
      await tester.pumpAndSettle();

      expect(find.byKey(const ValueKey('mapDoorFlatInputField')), findsOneWidget);
      expect(find.text('Save This Address'), findsOneWidget);
    });

    testWidgets('selecting a popular location and refining door number returns address with coordinates', (tester) async {
      AddressSelectionResult? savedResult;

      await tester.pumpWidget(createTestWidget(onSelected: (result) {
        savedResult = result;
      }));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const ValueKey('popularLocationItem_0')));
      await tester.pumpAndSettle();

      await tester.enterText(find.byKey(const ValueKey('doorFlatInputField')), 'Flat 3B, Green Towers');
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const ValueKey('confirmAddressSelectionButton')));
      await tester.pumpAndSettle();

      expect(savedResult, isNotNull);
      expect(savedResult!.address, contains('Flat 3B, Green Towers'));
      expect(savedResult!.address, contains('Anna Nagar'));
      expect(savedResult!.latitude, isNotNull);
      expect(savedResult!.longitude, isNotNull);
      expect(savedResult!.effectiveGoogleMapsUrl, contains('google.com/maps'));
    });

    testWidgets('GPS button auto-fills current location address', (tester) async {
      await tester.pumpWidget(createTestWidget(onSelected: (_) {}));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const ValueKey('useCurrentLocationButton')));
      await tester.pumpAndSettle();

      expect(find.text('T. Nagar, Chennai, Tamil Nadu, India'), findsOneWidget);
    });
  });
}