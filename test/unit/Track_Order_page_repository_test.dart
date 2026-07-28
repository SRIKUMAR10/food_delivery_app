import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:food_delivery_app/features/buyer_bloc_architecture/Track_Order_page/Track_Order_page_repository.dart';
import 'package:food_delivery_app/features/buyer_bloc_architecture/Track_Order_page/Track_Order_page_service.dart';
import 'package:mocktail/mocktail.dart';

class MockTrackOrderService extends Mock implements TrackOrderService {}

void main() {
  group('TrackOrderRepositoryImpl', () {
    late MockTrackOrderService mockService;
    late TrackOrderRepositoryImpl repository;

    setUp(() {
      mockService = MockTrackOrderService();
      repository = TrackOrderRepositoryImpl(service: mockService);
    });

    group('fetchOrderDetails', () {
      const orderId = '123';

      test('returns mapped order details on success', () async {
        when(() => mockService.getOrderDetails(orderId)).thenAnswer(
          (_) async => {
            'estimatedDelivery': '30-40 mins',
            'driverName': 'John',
          },
        );

        final result = await repository.fetchOrderDetails(orderId);

        expect(result, isA<Map<String, dynamic>>());
        expect(result['estimatedDelivery'], '30-40 mins');
        expect(result['driverName'], 'John');
      });
    });

    group('startTracking and locationStream', () {
      const orderId = '456';

      test('emits DriverLocation from riderLocationStream', () async {
        final locationController = StreamController<Map<String, dynamic>>();
        when(() => mockService.getOrderDetails(orderId)).thenAnswer(
          (_) async => {'riderId': 'rider1'},
        );
        when(() => mockService.riderLocationStream('rider1')).thenAnswer(
          (_) => locationController.stream,
        );

        await repository.startTracking(orderId);

        locationController.add({'lat': 12.97, 'lng': 77.59});
        locationController.add({'lat': 12.98, 'lng': 77.60});

        await expectLater(
          repository.locationStream,
          emitsInOrder([
            const DriverLocation(lat: 12.97, lng: 77.59),
            const DriverLocation(lat: 12.98, lng: 77.60),
          ]),
        );

        await locationController.close();
        await repository.stopTracking();
      });

      test('handles null riderId gracefully', () async {
        when(() => mockService.getOrderDetails(orderId)).thenAnswer(
          (_) async => {},
        );

        await repository.startTracking(orderId);

        verifyNever(() => mockService.riderLocationStream(any()));
      });
    });
  });
}
