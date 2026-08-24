import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:mocktail/mocktail.dart';
import 'package:food_delivery_app/core/services/google_distance_matrix_service.dart';

class MockHttpClient extends Mock implements http.Client {}

void main() {
  setUpAll(() {
    registerFallbackValue(Uri.parse('https://example.com'));
  });

  group('GoogleDistanceMatrixService Unit Tests', () {
    late MockHttpClient mockClient;
    late GoogleDistanceMatrixService service;

    setUp(() {
      mockClient = MockHttpClient();
      service = GoogleDistanceMatrixService(client: mockClient);
      service.clearCache();
    });

    const origin = LatLng(13.0827, 80.2707);
    const destination = LatLng(13.0850, 80.2750);

    test('Identical coordinates fast-path returns 0m and 0 mins without network', () async {
      final result = await service.computeDistanceAndEta(
        origin: origin,
        destination: origin,
      );

      expect(result.distanceKm, 0.0);
      expect(result.distanceMeters, 0);
      expect(result.durationMinutes, 0);
      expect(result.status, 'OK');
      expect(result.isFallback, isFalse);
    });

    test('DistanceMatrixResult fromGoogleElement correctly parses standard response', () {
      final element = {
        'status': 'OK',
        'distance': {'text': '3.2 km', 'value': 3200},
        'duration': {'text': '11 mins', 'value': 660},
        'duration_in_traffic': {'text': '14 mins', 'value': 840},
      };

      final result = DistanceMatrixResult.fromGoogleElement(element);
      expect(result.distanceKm, 3.2);
      expect(result.distanceMeters, 3200);
      expect(result.durationSeconds, 660);
      expect(result.durationMinutes, 14); // uses traffic minutes
      expect(result.durationText, '11 mins');
      expect(result.durationInTrafficText, '14 mins');
      expect(result.effectiveEtaText, '14 mins');
      expect(result.effectiveDistanceText, '3.2 km');
      expect(result.status, 'OK');
    });

    test('OSRM fallback parses driving route distance and calculates realistic ETA', () async {
      final osrmJson = jsonEncode({
        'code': 'Ok',
        'routes': [
          {
            'distance': 4500.0,
            'duration': 720.0, // 12 minutes
          }
        ]
      });

      when(() => mockClient.get(any(), headers: any(named: 'headers')))
          .thenAnswer((_) async => http.Response(osrmJson, 200));

      final result = await service.computeDistanceAndEta(
        origin: origin,
        destination: destination,
      );

      expect(result.distanceKm, 4.5);
      expect(result.distanceMeters, 4500);
      expect(result.durationMinutes, greaterThanOrEqualTo(12));
      expect(result.status, 'OK');
    });

    test('Haversine fallback triggers on complete network failure', () async {
      when(() => mockClient.get(any(), headers: any(named: 'headers')))
          .thenThrow(Exception('Connection reset by peer'));

      final result = await service.computeDistanceAndEta(
        origin: origin,
        destination: destination,
      );

      expect(result.distanceKm, greaterThan(0.0));
      expect(result.durationMinutes, greaterThanOrEqualTo(2));
      expect(result.isFallback, isTrue);
      expect(result.status, 'OK');
    });

    test('Coordinate caching avoids repeat network calls for identical path', () async {
      final osrmJson = jsonEncode({
        'code': 'Ok',
        'routes': [
          {'distance': 2000.0, 'duration': 300.0}
        ]
      });

      when(() => mockClient.get(any(), headers: any(named: 'headers')))
          .thenAnswer((_) async => http.Response(osrmJson, 200));

      final result1 = await service.computeDistanceAndEta(
        origin: origin,
        destination: destination,
      );
      final result2 = await service.computeDistanceAndEta(
        origin: origin,
        destination: destination,
      );

      expect(result1.distanceMeters, result2.distanceMeters);
      verify(() => mockClient.get(any(), headers: any(named: 'headers'))).called(1);
    });
  });
}
