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
        // Arrange
        when(() => mockService.getOrderDetails(orderId)).thenAnswer(
          (_) async => {
            'estimatedDelivery': '30-40 mins',
            'driverName': 'John',
          },
        );

        // Act
        final result = await repository.fetchOrderDetails(orderId);

        // Assert
        expect(result['estimatedDelivery'], '30-40 mins');
        expect(result['driverName'], 'John');
        verify(() => mockService.getOrderDetails(orderId)).called(1);
      });

      test('throws exception when service fails', () async {
        // Arrange
        when(
          () => mockService.getOrderDetails(any()),
        ).thenThrow(Exception('Service failed'));

        // Act & Assert
        expect(
          () => repository.fetchOrderDetails(orderId),
          throwsA(
            isA<Exception>().having(
              (e) => e.toString(),
              'message',
              contains('Service failed'),
            ),
          ),
        );
      });
    });

    group('locationStream', () {
      test('maps service stream correctly to DriverLocation', () {
        // Arrange
        when(() => mockService.connectDriverLocationSocket(any())).thenAnswer(
          (_) => Stream.fromIterable([
            {'lat': 12.0, 'lng': 77.0},
            {'lat': 12.1, 'lng': 77.1},
          ]),
        );

        // Act
        final stream = repository.locationStream;

        // Assert
        expectLater(
          stream,
          emitsInOrder([
            const DriverLocation(lat: 12.0, lng: 77.0),
            const DriverLocation(lat: 12.1, lng: 77.1),
          ]),
        );
      });

      test('handles null values in stream gracefully', () {
        // Arrange
        when(() => mockService.connectDriverLocationSocket(any())).thenAnswer(
          (_) => Stream.fromIterable([
            {'lat': null, 'lng': null},
          ]),
        );

        // Act
        final stream = repository.locationStream;

        // Assert
        expectLater(
          stream,
          emitsInOrder([
            const DriverLocation(lat: 0.0, lng: 0.0), // fallback values
          ]),
        );
      });
    });
  });
}
