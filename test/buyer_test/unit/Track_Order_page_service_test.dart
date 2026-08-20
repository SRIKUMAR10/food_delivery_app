import 'package:flutter_test/flutter_test.dart';
import 'package:food_delivery_app/features/buyer_bloc_architecture/Track_Order_page/Track_Order_page_service.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';

void main() {
  group('TrackOrderService', () {
    late TrackOrderService service;

    setUp(() {
      service = TrackOrderService(firestore: FakeFirebaseFirestore());
    });

    group('getOrderDetails', () {
      const orderId = '123';

      test('throws if order not found', () async {
        expect(
          () => service.getOrderDetails(orderId),
          throwsException,
        );
      });
    });

    group('cancelOrder & Automated Wallet Refund', () {
      test('cancels active order and processes instant wallet refund when prepaid', () async {
        final firestore = FakeFirebaseFirestore();
        final localService = TrackOrderService(firestore: firestore);

        // Seed buyer user with 100 initial wallet balance
        await firestore.collection('buyer_user').doc('buyer_456').set({
          'wallet': 100.0,
        });

        // Seed order
        await firestore.collection('orders').doc('order_789').set({
          'status': 'Placed',
          'buyerId': 'buyer_456',
          'totalAmount': 250.0,
          'paymentMethod': 'wallet',
          'paymentStatus': 'paid',
        });

        await localService.cancelOrder('order_789', reason: 'Changed my mind');

        // Check order status
        final updatedOrder = await firestore.collection('orders').doc('order_789').get();
        expect(updatedOrder.data()?['status'], 'Cancelled');
        expect(updatedOrder.data()?['cancellationReason'], 'Changed my mind');
        expect(updatedOrder.data()?['refundStatus'], 'completed');
        expect(updatedOrder.data()?['refundAmount'], 250.0);

        // Check buyer wallet balance credited
        final updatedBuyer = await firestore.collection('buyer_user').doc('buyer_456').get();
        expect(updatedBuyer.data()?['wallet'], 350.0);

        // Check transaction record created
        final txs = await firestore
            .collection('buyer_user')
            .doc('buyer_456')
            .collection('transactions')
            .get();
        expect(txs.docs.length, 1);
        expect(txs.docs.first.data()['amount'], 250.0);
        expect(txs.docs.first.data()['type'], 'refund');
        expect(txs.docs.first.data()['isCredit'], true);
      });

      test('cancels COD order without modifying wallet balance', () async {
        final firestore = FakeFirebaseFirestore();
        final localService = TrackOrderService(firestore: firestore);

        await firestore.collection('buyer_user').doc('buyer_cod').set({
          'wallet': 50.0,
        });

        await firestore.collection('orders').doc('order_cod').set({
          'status': 'Placed',
          'buyerId': 'buyer_cod',
          'totalAmount': 150.0,
          'paymentMethod': 'cod',
          'paymentStatus': 'pending',
        });

        await localService.cancelOrder('order_cod', reason: 'Mistake');

        final updatedOrder = await firestore.collection('orders').doc('order_cod').get();
        expect(updatedOrder.data()?['status'], 'Cancelled');
        expect(updatedOrder.data()?['refundStatus'], null);

        final updatedBuyer = await firestore.collection('buyer_user').doc('buyer_cod').get();
        expect(updatedBuyer.data()?['wallet'], 50.0);
      });

      test('throws when attempting to cancel already delivered or cancelled order', () async {
        final firestore = FakeFirebaseFirestore();
        final localService = TrackOrderService(firestore: firestore);

        await firestore.collection('orders').doc('order_delivered').set({
          'status': 'Delivered',
        });

        expect(
          () => localService.cancelOrder('order_delivered'),
          throwsA(isA<Exception>()),
        );
      });
    });
  });
}
