import 'package:flutter_test/flutter_test.dart';
import 'package:food_delivery_app/features/buyer_bloc_architecture/Track_Order_page/Track_Order_page_bloc.dart';
import 'package:food_delivery_app/features/buyer_bloc_architecture/Track_Order_page/Track_Order_page_event.dart';
import 'package:food_delivery_app/features/buyer_bloc_architecture/Track_Order_page/Track_Order_page_repository.dart';
import 'package:food_delivery_app/features/buyer_bloc_architecture/Track_Order_page/Track_Order_page_state.dart';
import 'package:mocktail/mocktail.dart';

class MockTrackOrderRepository extends Mock implements TrackOrderRepository {}

void main() {
  group('TrackOrder Error Handling', () {
    late MockTrackOrderRepository mockRepository;
    late TrackOrderBloc bloc;

    setUp(() {
      mockRepository = MockTrackOrderRepository();
      bloc = TrackOrderBloc(repository: mockRepository);
    });

    tearDown(() {
      bloc.close();
    });

    test('Emits TrackOrderError when API fails during load', () async {
      // Arrange
      when(
        () => mockRepository.fetchOrderDetails(any()),
      ).thenThrow(Exception('Network Error'));

      // Assert
      final expectedStates = [
        isA<TrackOrderLoading>(),
        isA<TrackOrderError>().having(
          (s) => s.message,
          'message',
          contains('Network Error'),
        ),
      ];
      expectLater(bloc.stream, emitsInOrder(expectedStates));

      // Act
      bloc.add(
        LoadTrackOrderDetails(orderId: '123', orderDate: DateTime.now()),
      );
    });

    test('Emits TrackOrderError when tracking start fails', () async {
      // Arrange
      when(
        () => mockRepository.startTracking(any()),
      ).thenThrow(Exception('Socket Error'));

      // Assert
      final expectedStates = [
        isA<TrackingLoading>(),
        isA<TrackOrderError>().having(
          (s) => s.message,
          'message',
          contains('Socket Error'),
        ),
      ];
      expectLater(bloc.stream, emitsInOrder(expectedStates));

      // Act
      bloc.add(const StartTracking());
    });
  });
}
