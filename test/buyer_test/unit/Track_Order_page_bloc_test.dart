import 'package:flutter_test/flutter_test.dart';
import 'package:food_delivery_app/features/buyer_bloc_architecture/Track_Order_page/Track_Order_page_bloc.dart';
import 'package:food_delivery_app/features/buyer_bloc_architecture/Track_Order_page/Track_Order_page_event.dart';
import 'package:food_delivery_app/features/buyer_bloc_architecture/Track_Order_page/Track_Order_page_repository.dart';
import 'package:food_delivery_app/features/buyer_bloc_architecture/Track_Order_page/Track_Order_page_service.dart';
import 'package:food_delivery_app/features/buyer_bloc_architecture/Track_Order_page/Track_Order_page_state.dart';
import 'package:food_delivery_app/core/repositories/i_order_repository.dart';
import 'package:mocktail/mocktail.dart';

class MockTrackOrderRepository extends Mock implements TrackOrderRepository {}
class MockTrackOrderService extends Mock implements TrackOrderService {}
class MockOrderRepository extends Mock implements IOrderRepository {}

void main() {
  group('TrackOrderBloc', () {
    late MockTrackOrderRepository mockRepository;
    late MockTrackOrderService mockTrackService;
    late MockOrderRepository mockOrderRepository;
    late TrackOrderBloc bloc;

    setUp(() {
      mockRepository = MockTrackOrderRepository();
      mockTrackService = MockTrackOrderService();
      mockOrderRepository = MockOrderRepository();
      when(() => mockRepository.startTracking(any())).thenAnswer((_) async {});
      when(() => mockRepository.stopTracking()).thenAnswer((_) async {});
      when(() => mockRepository.locationStream).thenAnswer((_) => const Stream.empty());
      when(() => mockTrackService.watchOrder(any())).thenAnswer((_) => const Stream.empty());
      bloc = TrackOrderBloc(
        repository: mockRepository,
        orderRepository: mockOrderRepository,
        trackService: mockTrackService,
      );
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
          when(() => mockTrackService.getOrderDetails(orderId)).thenAnswer(
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
          final expectation = expectLater(bloc.stream, emitsInOrder(expectedStates));

          // Act
          bloc.add(
            LoadTrackOrderDetails(orderId: orderId, orderDate: orderDate),
          );
          await expectation;
        },
      );

      test(
        'emits [TrackOrderLoading, TrackOrderError] on repository failure (Failure Path)',
        () async {
          // Arrange
          when(
            () => mockTrackService.getOrderDetails(any()),
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
          final expectation = expectLater(bloc.stream, emitsInOrder(expectedStates));

          // Act
          bloc.add(
            LoadTrackOrderDetails(orderId: orderId, orderDate: orderDate),
          );
          await expectation;
        },
      );

      test(
        'handles null fields in repository response gracefully (Edge Case / Null Safety)',
        () async {
          // Arrange
          when(() => mockTrackService.getOrderDetails(orderId)).thenAnswer(
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
                  '',
                ),
          ];
          final expectation = expectLater(bloc.stream, emitsInOrder(expectedStates));

          // Act
          bloc.add(
            LoadTrackOrderDetails(orderId: orderId, orderDate: orderDate),
          );
          await expectation;
        },
      );
    });

    group('WebSocket & Stream logic (StartTracking)', () {
      test(
        'emits driver location update when websocket event received',
        () async {
          // Arrange
          when(() => mockTrackService.getOrderDetails(any())).thenAnswer(
            (_) async => {'status': 'New'},
          );
          when(() => mockRepository.locationStream).thenAnswer(
            (_) => Stream.fromIterable([
              const DriverLocation(lat: 13.0827, lng: 80.2707),
              const DriverLocation(lat: 13.0830, lng: 80.2710),
            ]),
          );

          // Assert
          final expectedStates = [
            isA<TrackOrderLoading>(),
            isA<TrackOrderLoaded>(),
            isA<TrackOrderLoaded>().having((s) => s.driverLat, 'lat1', 13.0827),
            isA<TrackOrderLoaded>().having((s) => s.driverLat, 'lat2', 13.0830),
          ];

          final expectation = expectLater(bloc.stream, emitsInOrder(expectedStates));

          // Act
          bloc.add(
            LoadTrackOrderDetails(orderId: '123', orderDate: DateTime.now()),
          );
          bloc.add(const StartTracking(riderId: 'rider1'));
          await expectation;
        },
      );

      test('handles startTracking failure gracefully', () async {
        // Arrange
        when(
          () => mockRepository.startTracking(any()),
        ).thenThrow(Exception('Socket connection failed'));

        // Act
        bloc.add(const StartTracking(riderId: 'rider1'));
        await Future<void>.delayed(Duration.zero);
        await Future<void>.delayed(Duration.zero);

        // Assert: the bloc remains in a stable state without crashing
        expect(bloc.state, isA<TrackOrderInitial>());
      });
    });

    group('RefreshTrackOrder', () {
      test('adds LoadTrackOrderDetails event', () async {
        // Arrange
        when(() => mockTrackService.getOrderDetails(any())).thenAnswer(
          (_) async => {},
        );

        // Assert
        final expectation = expectLater(
          bloc.stream,
          emitsThrough(isA<TrackOrderLoading>()),
        );

        // Act
        bloc.add(RefreshTrackOrder(orderId: '123', orderDate: DateTime(2023)));
        await expectation;
      });
    });

    group('ToggleMapFullScreen', () {
      test('defaults isMapExpanded to true and toggles to false then back to true', () async {
        // Arrange
        when(() => mockTrackService.getOrderDetails(any())).thenAnswer(
          (_) async => {'status': 'New'},
        );

        final expectation = expectLater(
          bloc.stream,
          emitsInOrder([
            isA<TrackOrderLoading>(),
            isA<TrackOrderLoaded>().having((s) => s.isMapExpanded, 'isMapExpanded initial', true),
            isA<TrackOrderLoaded>().having((s) => s.isMapExpanded, 'isMapExpanded toggled off', false),
            isA<TrackOrderLoaded>().having((s) => s.isMapExpanded, 'isMapExpanded toggled back on', true),
          ]),
        );

        // Act
        bloc.add(LoadTrackOrderDetails(orderId: '123', orderDate: DateTime.now()));
        // Wait until loaded
        await Future<void>.delayed(const Duration(milliseconds: 50));
        bloc.add(const ToggleMapFullScreen());
        await Future<void>.delayed(const Duration(milliseconds: 50));
        bloc.add(const ToggleMapFullScreen());
        await expectation;
      });
    });
  });
}
