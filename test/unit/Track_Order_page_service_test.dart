import 'package:flutter_test/flutter_test.dart';
import 'package:food_delivery_app/features/buyer_bloc_architecture/Track_Order_page/Track_Order_page_service.dart';
import 'package:http/http.dart' as http;

void main() {

  group('TrackOrderService', () {
    late TrackOrderService service;

    setUp(() {
      service = TrackOrderService(httpClient: http.Client());
    });

    group('getOrderDetails', () {
      const orderId = '123';
      final uri = Uri.parse('https://api.fooddelivery.com/orders/$orderId');

      test(
        'returns order details map with dummy data',
        () async {
          final result = await service.getOrderDetails(orderId);

          expect(result, isA<Map<String, dynamic>>());
          expect(result['estimatedDelivery'], isA<String>());
          expect(result['driverName'], isA<String>());
          expect(result['driverImage'], isA<String>());
          expect(result['driverPhone'], isA<String>());
        },
      );

      test('does not throw (implementation returns dummy data)', () async {
        expect(service.getOrderDetails(orderId), completes);
      });
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
