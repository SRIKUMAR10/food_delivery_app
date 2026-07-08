import 'package:flutter_test/flutter_test.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/orders_list/orders_list_page_service.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/orders_list/orders_list_page_state.dart';

void main() {
  group('OrdersListService Unit Tests', () {
    late OrdersListService service;

    setUp(() {
      service = OrdersListService();
    });

    test('fetchOrders returns a list of OrderModel', () async {
      final orders = await service.fetchOrders();
      expect(orders, isA<List<OrderModel>>());
      expect(orders.isNotEmpty, true);
      expect(orders.first.id, isNotEmpty);
      expect(orders.first.customerName, isNotEmpty);
    });
  });
}
