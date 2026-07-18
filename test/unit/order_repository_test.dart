import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:food_delivery_app/features/buyer_bloc_architecture/Order%20Page/order_view_model.dart'
    show OrderViewModel;

// --- Blueprint Classes ---
// In a fully abstracted architecture, you would have an OrderRepository
abstract class OrderRepository {
  Future<List<OrderViewModel>> fetchOrders(String userId);
}

class MockOrderRepository extends Mock implements OrderRepository {}

void main() {
  group('OrderRepository Unit Tests (Blueprint)', () {
    late MockOrderRepository mockRepository;

    setUp(() {
      mockRepository = MockOrderRepository();
    });

    test('fetchOrders returns a list of OrderViewModels on success', () async {
      // Arrange
      final mockOrders = [
        OrderViewModel(
          id: 'ord_123',
          status: 'Delivered',
          totalAmount: 250.0,
          date: DateTime.now(),
          items: const [],
        ),
      ];
      when(
        () => mockRepository.fetchOrders(any()),
      ).thenAnswer((_) async => mockOrders);

      // Act
      final result = await mockRepository.fetchOrders('user1');

      // Assert
      expect(result, isNotEmpty);
      expect(result.first.id, 'ord_123');
      verify(() => mockRepository.fetchOrders('user1')).called(1);
    });

    test('fetchOrders throws Exception on network failure', () async {
      // Arrange
      when(
        () => mockRepository.fetchOrders(any()),
      ).thenThrow(Exception('Network error'));

      // Act & Assert
      expect(() => mockRepository.fetchOrders('user1'), throwsException);
    });
  });
}
