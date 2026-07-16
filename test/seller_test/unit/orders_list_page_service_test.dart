import 'package:flutter_test/flutter_test.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:food_delivery_app/core/models/order_status.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/orders_list/orders_list_page_service.dart';

void main() {
  group('OrdersListPageService Tests', () {
    late FakeFirebaseFirestore fakeFirestore;
    late OrdersListService service;

    setUp(() {
      fakeFirestore = FakeFirebaseFirestore();
      service = OrdersListService(firestore: fakeFirestore);
    });

    test('getOrdersStream emits orders correctly', () async {
      await fakeFirestore.collection('orders').doc('101').set({
        'sellerId': 'seller_1',
        'customerId': 'cust_1',
        'customerName': 'John Doe',
        'status': 'New',
        'amount': 500,
        'timestamp': DateTime.now(),
      });

      final stream = service.getOrdersStream('seller_1');
      
      final firstEmission = await stream.first;
      expect(firstEmission.length, 1);
      expect(firstEmission.first.id, '101');
      expect(firstEmission.first.status, OrderStatus.newOrder);
      expect(firstEmission.first.sellerId, 'seller_1');
    });

    test('updateOrderStatus updates Firestore document correctly', () async {
      await fakeFirestore.collection('orders').doc('102').set({
        'sellerId': 'seller_1',
        'status': 'New',
      });

      await service.updateOrderStatus('102', OrderStatus.preparing);

      final doc = await fakeFirestore.collection('orders').doc('102').get();
      expect(doc.data()?['status'], 'Preparing');
    });
  });
}
