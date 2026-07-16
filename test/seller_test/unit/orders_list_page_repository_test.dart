import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:food_delivery_app/core/models/order_status.dart';
import 'package:food_delivery_app/core/models/order_model.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/orders_list/orders_list_page_repository.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/orders_list/orders_list_page_service.dart';

class MockOrdersListService extends Mock implements OrdersListService {}

void main() {
  group('OrdersListRepository Tests', () {
    late MockOrdersListService mockService;
    late OrdersListRepository repository;

    setUp(() {
      mockService = MockOrdersListService();
      repository = OrdersListRepository(service: mockService);
    });

    final testOrders = [
      OrderModel(
        id: '1',
        customerId: 'c1',
        customerName: 'Customer 1',
        sellerId: 's1',
        status: OrderStatus.newOrder,
        amount: 100,
        timestamp: DateTime.now(),
      ),
    ];

    test('getOrdersStream returns correct stream from service', () {
      when(() => mockService.getOrdersStream('s1'))
          .thenAnswer((_) => Stream.value(testOrders));
      
      final stream = repository.getOrdersStream('s1');
      expect(stream, emits(testOrders));
      verify(() => mockService.getOrdersStream('s1')).called(1);
    });

    test('updateOrderStatus calls service correctly', () async {
      when(() => mockService.updateOrderStatus('1', OrderStatus.preparing))
          .thenAnswer((_) async {});
      
      await repository.updateOrderStatus('1', OrderStatus.preparing);
      verify(() => mockService.updateOrderStatus('1', OrderStatus.preparing)).called(1);
    });
  });
}
