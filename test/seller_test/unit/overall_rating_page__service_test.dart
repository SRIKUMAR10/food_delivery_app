import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

import '../../../lib/features/seller_bloc_architecture/overall_rating_page/overall_rating_page__bloc.dart';

// Assuming an implementation of the service that uses http
class OverallRatingServiceImpl implements OverallRatingService {
  final http.Client client;

  OverallRatingServiceImpl({required this.client});

  @override
  Future<Map<String, dynamic>> fetchRatingsAndReviews() async {
    final response = await client.get(Uri.parse('https://api.example.com/ratings'));
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Server Exception');
    }
  }
}

class MockHttpClient extends Mock implements http.Client {}

void main() {
  late OverallRatingServiceImpl service;
  late MockHttpClient mockHttpClient;

  setUp(() {
    mockHttpClient = MockHttpClient();
    service = OverallRatingServiceImpl(client: mockHttpClient);
  });

  group('OverallRatingService', () {
    test('should return data map when the response code is 200', () async {
      // arrange
      const responsePayload = '{"overallRating": 4.8, "totalReviews": 248, "reviews": []}';
      when(() => mockHttpClient.get(any()))
          .thenAnswer((_) async => http.Response(responsePayload, 200));

      // act
      final result = await service.fetchRatingsAndReviews();

      // assert
      expect(result, isA<Map<String, dynamic>>());
      expect(result['overallRating'], 4.8);
    });

    test('should throw an exception when the response code is 404 or other', () async {
      // arrange
      when(() => mockHttpClient.get(any()))
          .thenAnswer((_) async => http.Response('Not Found', 404));

      // act & assert
      expect(() => service.fetchRatingsAndReviews(), throwsException);
    });
  });
}
