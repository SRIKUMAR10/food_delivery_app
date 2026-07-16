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
    
    while (retryCount < maxRetries) {
      try {
        await _firestore
            .collection('orders')
            .doc(orderId)
            .update({'status': newStatus.value})
            .timeout(const Duration(seconds: 10)); // Timeout for offline detection
        return; // Success
      } on TimeoutException {
        retryCount++;
        if (retryCount >= maxRetries) {
          throw Exception('Network timeout. Please check your internet connection and try again.');
        }
        await Future.delayed(Duration(seconds: retryCount * 2)); // Exponential backoff
      } catch (e) {
        retryCount++;
        if (retryCount >= maxRetries) {
          throw Exception('Failed to update order status. Please try again.');
        }
        await Future.delayed(Duration(seconds: retryCount * 2)); // Exponential backoff
      }
    }
  }
}
