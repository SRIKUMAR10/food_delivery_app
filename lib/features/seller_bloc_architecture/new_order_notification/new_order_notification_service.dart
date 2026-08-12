import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/models/order_model.dart';
import '../../../../core/models/order_status.dart';

class NewOrderNotificationService {
  final FirebaseFirestore _firestore;

  NewOrderNotificationService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  Stream<List<OrderModel>> streamNewOrders(String sellerId) {
    return _firestore
        .collection('orders')
        .where('sellerId', isEqualTo: sellerId)
        .snapshots()
        .map((snapshot) {
          final orders = snapshot.docs
              .map((doc) => OrderModel.fromMap(doc.data(), doc.id))
              .where((order) => order.status == OrderStatus.newOrder)
              .toList();
          orders.sort((a, b) => b.timestamp.compareTo(a.timestamp));
          return orders;
        });
  }

  Future<void> acceptOrder(String orderId) async {
    await _firestore.collection('orders').doc(orderId).update({
      'status': 'Accepted',
      'acceptedAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> markReady(String orderId) async {
    await _firestore.collection('orders').doc(orderId).update({
      'status': 'Ready',
      'readyAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> rejectOrder(String orderId) async {
    await _firestore.collection('orders').doc(orderId).update({
      'status': 'Rejected',
      'rejectedAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }
}
