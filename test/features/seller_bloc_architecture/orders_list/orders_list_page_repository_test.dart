import 'package:flutter_test/flutter_test.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:food_delivery_app/core/models/order_status.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/orders_list/orders_list_page_service.dart';

void main() {
  late FakeFirebaseFirestore fakeFirestore;
  late OrdersListService service;
  final String sellerId = 'seller123';

  setUp(() {
    fakeFirestore = FakeFirebaseFirestore();
    service = OrdersListService(firestore: fakeFirestore);
  });

  group('OrdersListService', () {
    test('returns empty list when no orders exist', () async {
      final stream = service.getOrdersStream(sellerId);
      final orders = await stream.first;
      expect(orders, isEmpty);
    });

    test('parses order correctly including missing items or address', () async {
      await fakeFirestore.collection('orders').add({
        'sellerId': sellerId,
        'status': 'New',
        'amount': 100.0,
        'timestamp': DateTime.now(),
        // Intentionally missing customerPhone, deliveryAddress, items
      });

      final stream = service.getOrdersStream(sellerId);
      final orders = await stream.first;

      expect(orders.length, 1);
      final order = orders.first;
      expect(order.status, OrderStatus.newOrder);
      expect(order.customerPhone, isNull);
      expect(order.deliveryAddress, isNull);
      expect(order.items, isNull);
    });

    test('parses order correctly with full fields', () async {
      await fakeFirestore.collection('orders').add({
        'sellerId': sellerId,
        'status': 'New',
        'amount': 1500.0,
        'timestamp': DateTime.now(),
        'customerPhone': '1234567890',
        'deliveryAddress': '123 Test St',
        'items': [
          {'productId': 'p1', 'name': 'Pizza', 'quantity': 2, 'price': 750.0}
        ]
      });

      final stream = service.getOrdersStream(sellerId);
      final orders = await stream.first;

      expect(orders.length, 1);
      final order = orders.first;
      expect(order.customerPhone, '1234567890');
      expect(order.deliveryAddress, '123 Test St');
      expect(order.items, isNotNull);
      expect(order.items!.length, 1);
      expect(order.items!.first.name, 'Pizza');
      expect(order.items!.first.quantity, 2);
    });

    test('updateOrderStatus updates firestore correctly', () async {
      final docRef = await fakeFirestore.collection('orders').add({
        'sellerId': sellerId,
        'status': 'New',
        'amount': 100.0,
        'timestamp': DateTime.now(),
      });

      await service.updateOrderStatus(docRef.id, OrderStatus.preparing);

      final doc = await fakeFirestore.collection('orders').doc(docRef.id).get();
      expect(doc.data()!['status'], 'Preparing');
    });
  });
}
