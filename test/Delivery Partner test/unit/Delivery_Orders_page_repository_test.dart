import 'package:flutter_test/flutter_test.dart';

import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Orders_page/Delivery_Orders_page_repository.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Orders_page/Delivery_Orders_page_state.dart';

void main() {
  group('DeliveryOrdersPage Repository Tests', () {
    test('fetchOrders maps raw service data into order card models', () async {
      final repository = DeliveryOrdersRepository();
      final orders = await repository.fetchOrders();

      expect(orders, hasLength(8));
      final first = orders.first;
      expect(first.orderId, 'ORD12345');
      expect(first.customerName, 'Priya Sharma');
      expect(first.restaurantName, 'Green Bowl Kitchen');
      expect(first.pickupAddress, '42 Anna Salai, Chennai');
      expect(first.deliveryAddress, '21 MG Road, Velachery');
      expect(first.amount, 486.50);
      expect(first.itemsCount, 3);
      expect(first.distance, 2.4);
      expect(first.time, '10:30 AM');
      expect(first.paymentType, 'Cash');
    });

    test('fetchOrders maps statuses to the correct enum values', () async {
      final repository = DeliveryOrdersRepository();
      final orders = await repository.fetchOrders();

      expect(
        orders.where((o) => o.status == DeliveryOrderStatus.pending),
        hasLength(3),
      );
      expect(
        orders.where((o) => o.status == DeliveryOrderStatus.active),
        hasLength(2),
      );
      expect(
        orders.where((o) => o.status == DeliveryOrderStatus.completed),
        hasLength(3),
      );
    });

    test('updateOrderStatus returns the order with the new status', () async {
      final repository = DeliveryOrdersRepository();
      final updated = await repository.updateOrderStatus(
        'ORD12345',
        DeliveryOrderStatus.completed,
      );

      expect(updated.orderId, 'ORD12345');
      expect(updated.status, DeliveryOrderStatus.completed);
      expect(updated.customerName, 'Priya Sharma');
      expect(updated.restaurantName, 'Green Bowl Kitchen');
    });

    test('updateOrderStatus keeps other order fields intact', () async {
      final repository = DeliveryOrdersRepository();
      final updated = await repository.updateOrderStatus(
        'ORD12346',
        DeliveryOrderStatus.active,
      );

      expect(updated.orderId, 'ORD12346');
      expect(updated.status, DeliveryOrderStatus.active);
      expect(updated.amount, 732.00);
      expect(updated.itemsCount, 4);
    });

    test('updateOrderStatus throws for an unknown order id', () async {
      final repository = DeliveryOrdersRepository();
      expect(
        () => repository.updateOrderStatus(
          'ORD00000',
          DeliveryOrderStatus.completed,
        ),
        throwsA(anything),
      );
    });

    test('watchOrders emits the current list of orders', () async {
      final repository = DeliveryOrdersRepository();
      final emitted = await repository.watchOrders().first;

      expect(emitted, hasLength(8));
      expect(emitted.first.orderId, 'ORD12345');
    });
  });
}
