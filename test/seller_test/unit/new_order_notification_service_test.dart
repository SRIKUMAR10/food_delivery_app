import 'package:flutter_test/flutter_test.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/new_order_notification/new_order_notification_service.dart';
import 'package:food_delivery_app/core/models/order_status.dart';

void main() {
  group('NewOrderNotificationService', () {
    late FakeFirebaseFirestore fakeFirestore;
    late NewOrderNotificationService service;
    final String sellerId = 'seller_1';

    setUp(() {
      fakeFirestore = FakeFirebaseFirestore();
      service = NewOrderNotificationService(firestore: fakeFirestore);
    });

    test('streamNewOrders emits only New orders for the seller', () async {
      await fakeFirestore.collection('orders').add({
        'sellerId': sellerId,
        'status': 'New',
        'amount': 100.0,
        'timestamp': DateTime(2026, 8, 5),
      });
      await fakeFirestore.collection('orders').add({
        'sellerId': sellerId,
        'status': 'Accepted',
        'amount': 200.0,
        'timestamp': DateTime(2026, 8, 5),
      });
      await fakeFirestore.collection('orders').add({
        'sellerId': 'other_seller',
        'status': 'New',
        'amount': 300.0,
        'timestamp': DateTime(2026, 8, 5),
      });

      final orders = await service.streamNewOrders(sellerId).first;

      expect(orders.length, 1);
      expect(orders.first.status, OrderStatus.newOrder);
      expect(orders.first.amount, 100.0);
    });

    test('acceptOrder updates the order status to Accepted', () async {
      final docRef = await fakeFirestore.collection('orders').add({
        'sellerId': sellerId,
        'status': 'New',
        'amount': 100.0,
        'timestamp': DateTime(2026, 8, 5),
      });

      await service.acceptOrder(docRef.id);

      final doc = await fakeFirestore.collection('orders').doc(docRef.id).get();
      expect(doc.data()!['status'], 'Accepted');
    });

    test('rejectOrder updates the order status to Rejected', () async {
      final docRef = await fakeFirestore.collection('orders').add({
        'sellerId': sellerId,
        'status': 'New',
        'amount': 100.0,
        'timestamp': DateTime(2026, 8, 5),
      });

      await service.rejectOrder(docRef.id);

      final doc = await fakeFirestore.collection('orders').doc(docRef.id).get();
      expect(doc.data()!['status'], 'Rejected');
    });
  });
}
