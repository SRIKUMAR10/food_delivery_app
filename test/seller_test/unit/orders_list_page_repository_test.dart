import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/orders_list/orders_list_page_repository.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/orders_list/orders_list_page_service.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/orders_list/orders_list_page_state.dart';

class MockOrdersListService extends Mock implements OrdersListService {}

void main() {
  group('OrdersListRepository Unit Tests', () {
    late OrdersListRepository repository;
    late MockOrdersListService mockService;

    setUp(() {
      mockService = MockOrdersListService();
      repository = OrdersListRepository(service: mockService);
    });

    final mockOrders = [
      const OrderModel(
        id: '1',
        customerName: 'Test User',
        status: 'New',
        amount: 500,
        timeAgo: '1 min ago',
      ),
    ];

    test('getOrders returns data successfully from service', () async {
      when(() => mockService.fetchOrders()).thenAnswer((_) async => mockOrders);

      final result = await repository.getOrders();

      expect(result, mockOrders);
      verify(() => mockService.fetchOrders()).called(1);
    });

    test('getOrders throws an exception when service fails', () async {
      when(
        () => mockService.fetchOrders(),
      ).thenThrow(Exception('Network Error'));

      expect(() => repository.getOrders(), throwsException);
      verify(() => mockService.fetchOrders()).called(1);
    });
  });
}
