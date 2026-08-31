import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mocktail/mocktail.dart';
import 'package:food_delivery_app/core/services/google_places_service.dart';

class MockHttpClient extends Mock implements http.Client {}

void main() {
  setUpAll(() {
    registerFallbackValue(Uri.parse('https://example.com'));
  });

  group('GooglePlacesService Unit Tests', () {
    late MockHttpClient mockClient;
    late GooglePlacesService service;

    setUp(() {
      mockClient = MockHttpClient();
      service = GooglePlacesService(client: mockClient);
    });

    test('GooglePlacePrediction fromJson parses structured formatting', () {
      final json = {
        'place_id': 'ChIJ_944321',
        'structured_formatting': {
          'main_text': 'Anna Nagar',
          'secondary_text': 'Chennai, Tamil Nadu, India',
        },
        'description': 'Anna Nagar, Chennai, Tamil Nadu, India',
        'types': ['locality', 'political'],
      };

      final prediction = GooglePlacePrediction.fromJson(json);
      expect(prediction.placeId, 'ChIJ_944321');
      expect(prediction.mainText, 'Anna Nagar');
      expect(prediction.secondaryText, 'Chennai, Tamil Nadu, India');
      expect(prediction.description, 'Anna Nagar, Chennai, Tamil Nadu, India');
      expect(prediction.types, contains('locality'));
    });

    test('GooglePlaceDetails fromJson parses Google result and coordinates', () {
      final json = {
        'result': {
          'place_id': 'place_123',
          'formatted_address': '123 Anna Salai, Thousand Lights, Chennai, Tamil Nadu 600006, India',
          'name': 'Anna Salai',
          'geometry': {
            'location': {'lat': 13.0604, 'lng': 80.2496},
          },
          'address_components': [
            {'long_name': '600006', 'types': ['postal_code']},
            {'long_name': 'Chennai', 'types': ['locality']},
            {'long_name': 'Tamil Nadu', 'types': ['administrative_area_level_1']},
            {'long_name': 'India', 'types': ['country']},
          ],
        },
      };

      final details = GooglePlaceDetails.fromJson(json);
      expect(details.placeId, 'place_123');
      expect(details.formattedAddress, contains('Anna Salai'));
      expect(details.latitude, 13.0604);
      expect(details.longitude, 80.2496);
      expect(details.postalCode, '600006');
      expect(details.city, 'Chennai');
      expect(details.state, 'Tamil Nadu');
      expect(details.country, 'India');
    });

    test('searchPlaces returns empty list on empty query', () async {
      final results = await service.searchPlaces('');
      expect(results, isEmpty);
    });

    test('searchPlaces parses OpenStreetMap/Nominatim response when fallback triggered', () async {
      final nominatimJson = jsonEncode([
        {
          'place_id': 98765,
          'osm_id': 12345,
          'display_name': 'T. Nagar, Chennai, Tamil Nadu, 600017, India',
          'type': 'suburb',
        },
      ]);

      when(() => mockClient.get(any(), headers: any(named: 'headers')))
          .thenAnswer((_) async => http.Response(nominatimJson, 200));

      final results = await service.searchPlaces('T. Nagar');
      expect(results, isNotEmpty);
      expect(results.first.mainText, 'T. Nagar');
      expect(results.first.secondaryText, contains('Chennai'));
    });

    test('searchPlaces gracefully handles network failure returning empty list', () async {
      when(() => mockClient.get(any(), headers: any(named: 'headers')))
          .thenThrow(Exception('No Internet Connection'));

      final results = await service.searchPlaces('Anna Nagar');
      expect(results, isEmpty);
    });

    test('reverseGeocode parses coordinates into formatted address details', () async {
      final reverseJson = jsonEncode({
        'place_id': 55555,
        'display_name': 'Marina Beach, Kamarajar Promenade, Chennai, Tamil Nadu, 600005, India',
        'lat': '13.0499',
        'lon': '80.2824',
        'address': {
          'suburb': 'Marina Beach',
          'city': 'Chennai',
          'state': 'Tamil Nadu',
          'postcode': '600005',
          'country': 'India',
        },
      });

      when(() => mockClient.get(any(), headers: any(named: 'headers')))
          .thenAnswer((_) async => http.Response(reverseJson, 200));

      final details = await service.reverseGeocode(13.0499, 80.2824);
      expect(details, isNotNull);
      expect(details!.formattedAddress, contains('Marina Beach'));
      expect(details.latitude, 13.0499);
      expect(details.longitude, 80.2824);
    });
  });
}
