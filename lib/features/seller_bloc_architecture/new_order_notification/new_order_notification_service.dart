import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/models/order_model.dart';

class NewOrderNotificationService {
  final FirebaseFirestore _firestore;

  NewOrderNotificationService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  Stream<OrderModel> streamNewOrders(String sellerId) {
    return _firestore
        .collection('orders')
        .where('sellerId', isEqualTo: sellerId)
        .where('status', isEqualTo: 'New')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .expand((snapshot) {
          return snapshot.docs.map((doc) =>
              OrderModel.fromMap(doc.data(), doc.id));
        });
  }

  Future<void> acceptOrder(String orderId) async {
    await _firestore.collection('orders').doc(orderId).update({
      'status': 'Accepted',
      'acceptedAt': FieldValue.serverTimestamp(),
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
