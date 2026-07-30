import 'package:flutter_test/flutter_test.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:food_delivery_app/repositories/firebase_order_repository.dart';

void main() {
  group('FirebaseOrderRepository Unit Tests', () {
    late FakeFirebaseFirestore fakeFirestore;
    late FirebaseOrderRepository orderRepository;

    setUp(() {
      fakeFirestore = FakeFirebaseFirestore();
      orderRepository = FirebaseOrderRepository(firestore: fakeFirestore);
    });

    test('getBuyerOrdersStream queries the root orders collection', () async {
      await fakeFirestore.collection('orders').doc('order1').set({
        'customerId': 'test_uid',
        'status': 'New',
        'amount': 25.0,
        'timestamp': DateTime.now(),
        'items': []
      });

      await fakeFirestore.collection('orders').doc('order2').set({
        'customerId': 'other_uid',
        'status': 'New',
        'amount': 15.0,
        'timestamp': DateTime.now(),
        'items': []
      });

      final stream = orderRepository.getBuyerOrdersStream('test_uid');
      final ordersList = await stream.first;

      expect(ordersList.length, 1);
      expect(ordersList.first.id, 'order1');
    });

    test('returns empty list for empty buyerId', () async {
      final stream = orderRepository.getBuyerOrdersStream('');
      final ordersList = await stream.first;

      expect(ordersList, isEmpty);
    });
  });
}
