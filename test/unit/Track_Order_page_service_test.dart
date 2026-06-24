import 'package:flutter_test/flutter_test.dart';
import 'package:food_delivery_app/features/buyer_bloc_architecture/Track_Order_page/Track_Order_page_service.dart';
import 'package:mocktail/mocktail.dart';
import 'package:http/http.dart' as http;

class MockHttpClient extends Mock implements http.Client {}

class FakeUri extends Fake implements Uri {}

void main() {
  setUpAll(() {
    registerFallbackValue(FakeUri());
  });

  group('TrackOrderService', () {
    late MockHttpClient mockHttpClient;
    late TrackOrderService service;

    setUp(() {
      mockHttpClient = MockHttpClient();
      service = TrackOrderService(httpClient: mockHttpClient);
    });

    group('getOrderDetails', () {
      const orderId = '123';
      final uri = Uri.parse('https://api.fooddelivery.com/orders/$orderId');

      test(
        'returns order details map when API call is successful (200 OK)',
        () async {
          // Arrange
          const responseBody =
              '{"driverName": "Alice", "estimatedDelivery": "15-20 mins"}';
          when(
            () => mockHttpClient.get(uri),
          ).thenAnswer((_) async => http.Response(responseBody, 200));

          // Act
          final result = await service.getOrderDetails(orderId);

          // Assert
          expect(result, isA<Map<String, dynamic>>());
          expect(result['driverName'], 'Alice');
          expect(result['estimatedDelivery'], '15-20 mins');
          verify(() => mockHttpClient.get(uri)).called(1);
        },
      );

      test('throws Exception when API call fails (404 Not Found)', () async {
        // Arrange
        when(
          () => mockHttpClient.get(uri),
        ).thenAnswer((_) async => http.Response('Not Found', 404));

        // Act & Assert
        expect(
          () => service.getOrderDetails(orderId),
          throwsA(
            isA<Exception>().having(
              (e) => e.toString(),
              'message',
              contains('404'),
            ),
          ),
        );
      });

      test(
        'throws Exception when API call fails (500 Internal Server Error)',
        () async {
          // Arrange
          when(
            () => mockHttpClient.get(uri),
          ).thenAnswer((_) async => http.Response('Server Error', 500));

          // Act & Assert
          expect(
            () => service.getOrderDetails(orderId),
            throwsA(
              isA<Exception>().having(
                (e) => e.toString(),
                'message',
                contains('500'),
              ),
            ),
          );
        },
      );

      test(
        'handles network failure gracefully (Timeout/SocketException)',
        () async {
          // Arrange
          when(
            () => mockHttpClient.get(uri),
          ).thenThrow(Exception('Socket connection failed'));

          // Act & Assert
          expect(
            () => service.getOrderDetails(orderId),
            throwsA(
              isA<Exception>().having(
                (e) => e.toString(),
                'message',
                contains('Socket connection failed'),
              ),
            ),
          );
        },
      );
    });

    group('connectDriverLocationSocket', () {
      test('returns a valid stream', () {
        // Act
        final stream = service.connectDriverLocationSocket('123');

        // Assert
        expect(stream, isA<Stream<Map<String, dynamic>>>());
      });
    });
  });
}
