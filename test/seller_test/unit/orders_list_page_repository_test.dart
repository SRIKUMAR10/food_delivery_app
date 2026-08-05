import 'package:flutter_test/flutter_test.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:food_delivery_app/core/models/order_status.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/orders_list/orders_list_page_service.dart';

void main() {
  group('OrdersListService Status Tests', () {
    late FakeFirebaseFirestore fakeFirestore;
    late OrdersListService service;
    final String sellerId = 'seller123';

    setUp(() {
      fakeFirestore = FakeFirebaseFirestore();
      service = OrdersListService(firestore: fakeFirestore);
    });

    test('maps persisted status strings to OrderStatus correctly', () async {
      await fakeFirestore.collection('orders').add({
        'sellerId': sellerId,
        'status': 'OutForDelivery',
        'amount': 100.0,
        'timestamp': DateTime.now(),
      });
      await fakeFirestore.collection('orders').add({
        'sellerId': sellerId,
        'status': 'Delivered',
        'amount': 120.0,
        'timestamp': DateTime.now(),
      });

      final orders = await service.getOrdersStream(sellerId).first;
      expect(orders.length, 2);
      final statuses = orders.map((o) => o.status).toSet();
      expect(statuses, contains(OrderStatus.outForDelivery));
      expect(statuses, contains(OrderStatus.delivered));
    });

    test('updateOrderStatus writes the status string for accepted', () async {
      final docRef = await fakeFirestore.collection('orders').add({
        'sellerId': sellerId,
        'status': 'New',
        'amount': 100.0,
        'timestamp': DateTime.now(),
      });

      await service.updateOrderStatus(docRef.id, OrderStatus.accepted);

      final doc = await fakeFirestore.collection('orders').doc(docRef.id).get();
      expect(doc.data()!['status'], 'Accepted');
      expect(doc.data()!['acceptedAt'], isNotNull);
    });

    test('updateOrderStatus writes the status string for rejected', () async {
      final docRef = await fakeFirestore.collection('orders').add({
        'sellerId': sellerId,
        'status': 'New',
        'amount': 100.0,
        'timestamp': DateTime.now(),
      });

      await service.updateOrderStatus(docRef.id, OrderStatus.rejected);

      final doc = await fakeFirestore.collection('orders').doc(docRef.id).get();
      expect(doc.data()!['status'], 'Rejected');
      expect(doc.data()!['rejectedAt'], isNotNull);
    });
  });
}
