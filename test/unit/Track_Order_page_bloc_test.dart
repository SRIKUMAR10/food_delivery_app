import 'package:flutter_test/flutter_test.dart';
import 'package:food_delivery_app/features/buyer_bloc_architecture/Track_Order_page/Track_Order_page_bloc.dart';
import 'package:food_delivery_app/features/buyer_bloc_architecture/Track_Order_page/Track_Order_page_event.dart';
import 'package:food_delivery_app/features/buyer_bloc_architecture/Track_Order_page/Track_Order_page_repository.dart';
import 'package:food_delivery_app/features/buyer_bloc_architecture/Track_Order_page/Track_Order_page_state.dart';
import 'package:mocktail/mocktail.dart';

class MockTrackOrderRepository extends Mock implements TrackOrderRepository {}

void main() {
  group('TrackOrderBloc', () {
    late MockTrackOrderRepository mockRepository;
    late TrackOrderBloc bloc;

    setUp(() {
      mockRepository = MockTrackOrderRepository();
      bloc = TrackOrderBloc(repository: mockRepository);
    });

    tearDown(() {
      bloc.close();
    });

    test('initial state should be TrackOrderInitial', () {
      expect(bloc.state, isA<TrackOrderInitial>());
    });

    group('LoadTrackOrderDetails', () {
      final orderDate = DateTime(2023, 1, 1, 10, 0);
      const orderId = 'FG125678';

      test(
        'emits [TrackOrderLoading, TrackOrderLoaded] on success (Happy Path)',
        () async {
          // Arrange
          when(() => mockRepository.fetchOrderDetails(orderId)).thenAnswer(
            (_) async => {
              'estimatedDelivery': '20-30 mins',
              'driverName': 'Jane Doe',
              'driverImage': 'url',
              'driverPhone': '+0987654321',
            },
          );

          // Assert
          final expectedStates = [
            isA<TrackOrderLoading>(),
            isA<TrackOrderLoaded>()
                .having((s) => s.orderId, 'orderId', orderId)
                .having(
                  (s) => s.estimatedDelivery,
                  'estimatedDelivery',
                  '20-30 mins',
                )
                .having(
                  (s) => s.deliveryPartner.name,
                  'driverName',
                  'Jane Doe',
                ),
          ];
          expectLater(bloc.stream, emitsInOrder(expectedStates));

          // Act
          bloc.add(
            LoadTrackOrderDetails(orderId: orderId, orderDate: orderDate),
          );
        },
      );

      test(
        'emits [TrackOrderLoading, TrackOrderError] on repository failure (Failure Path)',
        () async {
          // Arrange
          when(
            () => mockRepository.fetchOrderDetails(any()),
          ).thenThrow(Exception('API Timeout'));

          // Assert
          final expectedStates = [
            isA<TrackOrderLoading>(),
            isA<TrackOrderError>().having(
              (s) => s.message,
              'message',
              contains('API Timeout'),
            ),
          ];
          expectLater(bloc.stream, emitsInOrder(expectedStates));

          // Act
          bloc.add(
            LoadTrackOrderDetails(orderId: orderId, orderDate: orderDate),
          );
        },
      );

      test(
        'handles null fields in repository response gracefully (Edge Case / Null Safety)',
        () async {
          // Arrange
          when(() => mockRepository.fetchOrderDetails(orderId)).thenAnswer(
            (_) async => {}, // Empty map, should use defaults
          );

          // Assert
          final expectedStates = [
            isA<TrackOrderLoading>(),
            isA<TrackOrderLoaded>()
                .having(
                  (s) => s.estimatedDelivery,
                  'default delivery',
                  '30-40 mins',
                )
                .having(
                  (s) => s.deliveryPartner.name,
                  'default name',
                  'John D.',
                ),
          ];
          expectLater(bloc.stream, emitsInOrder(expectedStates));

          // Act
          bloc.add(
            LoadTrackOrderDetails(orderId: orderId, orderDate: orderDate),
          );
        },
      );
    });

    group('WebSocket & Stream logic (StartTracking)', () {
      test(
        'emits driver location update when websocket event received',
        () async {
          // Arrange
          when(
            () => mockRepository.startTracking(any()),
          ).thenAnswer((_) async => {});
          when(() => mockRepository.locationStream).thenAnswer(
            (_) => Stream.fromIterable([
              const DriverLocation(lat: 13.0827, lng: 80.2707),
              const DriverLocation(lat: 13.0830, lng: 80.2710),
            ]),
          );

          // Assert
          final expectedStates = [
            isA<TrackingLoading>(),
            isA<LocationUpdated>().having((s) => s.lat, 'lat1', 13.0827),
            isA<LocationUpdated>().having((s) => s.lat, 'lat2', 13.0830),
          ];

          expectLater(bloc.stream, emitsInOrder(expectedStates));

          // Act
          bloc.add(const StartTracking());
        },
      );

      test('emits TrackOrderError if startTracking fails', () async {
        // Arrange
        when(
          () => mockRepository.startTracking(any()),
        ).thenThrow(Exception('Socket connection failed'));

        // Assert
        expectLater(
          bloc.stream,
          emitsInOrder([
            isA<TrackingLoading>(),
            isA<TrackOrderError>().having(
              (s) => s.message,
              'message',
              contains('Socket connection failed'),
            ),
          ]),
        );

        // Act
        bloc.add(const StartTracking());
      });
    });

    group('RefreshTrackOrder', () {
      test('adds LoadTrackOrderDetails event', () async {
        // Act
        bloc.add(RefreshTrackOrder(orderId: '123', orderDate: DateTime(2023)));

        // Assert
        // We verify that state goes to Loading, which means LoadTrackOrderDetails was added and processed
        when(
          () => mockRepository.fetchOrderDetails(any()),
        ).thenAnswer((_) async => {});
        await expectLater(bloc.stream, emitsThrough(isA<TrackOrderLoading>()));
      });
    });
  });
}
