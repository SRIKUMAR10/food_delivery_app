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
  group('TrackOrder Error Handling', () {
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

    test('Emits TrackOrderError when service fails during load', () async {
      // Arrange
      when(
        () => mockTrackService.getOrderDetails(any()),
      ).thenThrow(Exception('Network Error'));

      // Assert
      final expectedStates = [
        isA<TrackOrderLoading>(),
        isA<TrackOrderError>().having(
          (s) => s.message,
          'message',
          contains('Network connection error'),
        ),
      ];
      final expectation = expectLater(bloc.stream, emitsInOrder(expectedStates));

      // Act
      bloc.add(
        LoadTrackOrderDetails(orderId: '123', orderDate: DateTime.now()),
      );
      await expectation;
    });

    test('handles tracking start failure gracefully', () async {
      // Arrange
      when(
        () => mockRepository.startTracking(any()),
      ).thenThrow(Exception('Socket Error'));

      // Act
      bloc.add(const StartTracking(riderId: 'rider1'));
      await Future<void>.delayed(Duration.zero);
      await Future<void>.delayed(Duration.zero);

      // Assert: the bloc remains stable without crashing
      expect(bloc.state, isA<TrackOrderInitial>());
    });
  });
}
