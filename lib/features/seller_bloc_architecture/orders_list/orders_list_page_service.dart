import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/models/order_model.dart';
import '../../../../core/models/order_status.dart';

class OrdersListService {
  final FirebaseFirestore _firestore;

  OrdersListService({FirebaseFirestore? firestore}) 
      : _firestore = firestore ?? FirebaseFirestore.instance;

  Stream<List<OrderModel>> getOrdersStream(String sellerId) {
    return _firestore
        .collection('orders')
        .where('sellerId', isEqualTo: sellerId)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => OrderModel.fromMap(doc.data(), doc.id)).toList();
    });
  }

  Future<void> updateOrderStatus(String orderId, OrderStatus newStatus) async {
    const int maxRetries = 3;
    int retryCount = 0;

    final Map<String, dynamic> updates = {
      'status': newStatus.value,
      'updatedAt': FieldValue.serverTimestamp(),
    };

    switch (newStatus) {
      case OrderStatus.accepted:
        updates['acceptedAt'] = FieldValue.serverTimestamp();
        break;
      case OrderStatus.rejected:
        updates['rejectedAt'] = FieldValue.serverTimestamp();
        break;
      case OrderStatus.preparing:
        updates['preparingAt'] = FieldValue.serverTimestamp();
        break;
      case OrderStatus.ready:
        updates['readyAt'] = FieldValue.serverTimestamp();
        break;
      case OrderStatus.outForDelivery:
        updates['outForDeliveryAt'] = FieldValue.serverTimestamp();
        break;
      case OrderStatus.delivered:
        updates['deliveredAt'] = FieldValue.serverTimestamp();
        break;
      case OrderStatus.cancelled:
        updates['cancelledAt'] = FieldValue.serverTimestamp();
        break;
      default:
        break;
    }
    
    while (retryCount < maxRetries) {
      try {
        await _firestore
            .collection('orders')
            .doc(orderId)
            .update(updates)
            .timeout(const Duration(seconds: 10));
        return;
      } on TimeoutException {
        retryCount++;
        if (retryCount >= maxRetries) {
          throw Exception('Network timeout. Please check your internet connection and try again.');
        }
        await Future.delayed(Duration(seconds: retryCount * 2));
      } catch (e) {
        retryCount++;
        if (retryCount >= maxRetries) {
          throw Exception('Failed to update order status. Please try again.');
        }
        await Future.delayed(Duration(seconds: retryCount * 2));
      }
    }
  }
}
