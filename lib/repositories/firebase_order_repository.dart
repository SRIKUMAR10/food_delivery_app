import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../core/models/order_model.dart';
import '../core/models/order_status.dart';
import '../core/repositories/i_order_repository.dart';

class FirebaseOrderRepository implements IOrderRepository {
  final FirebaseFirestore _firestore;
  
  // Cache to store loaded orders for performance optimization
  static final Map<String, OrderModel> _orderCache = {};

  FirebaseOrderRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Stream<List<OrderModel>> getBuyerOrdersStream(String buyerId) {
    if (buyerId.isEmpty) {
      return Stream.value([]);
    }

    return _firestore
        .collection('orders')
        .where('customerId', isEqualTo: buyerId)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final order = OrderModel.fromMap(doc.data(), doc.id);
        _orderCache[doc.id] = order;
        return order;
      }).toList();
    });
  }

  @override
  Stream<List<OrderModel>> getSellerOrdersStream(String sellerId) {
    if (sellerId.isEmpty) {
      return Stream.value([]);
    }

    return _firestore
        .collection('orders')
        .where('sellerId', isEqualTo: sellerId)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final order = OrderModel.fromMap(doc.data(), doc.id);
        _orderCache[doc.id] = order;
        return order;
      }).toList();
    });
  }

  @override
  Future<void> updateOrderStatus(String orderId, OrderStatus newStatus) async {
    try {
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
        case OrderStatus.newOrder:
          break;
      }

      await _firestore.collection('orders').doc(orderId).update(updates);
      // Invalidate the cache to fetch fresh data on subsequent queries
      _orderCache.remove(orderId);
    } catch (e) {
      throw Exception('Failed to update order status: $e');
    }
  }

  @override
  Future<OrderModel?> getOrderById(String orderId) async {
    if (_orderCache.containsKey(orderId)) {
      return _orderCache[orderId];
    }
    try {
      final doc = await _firestore.collection('orders').doc(orderId).get();
      if (doc.exists && doc.data() != null) {
        final order = OrderModel.fromMap(doc.data()!, doc.id);
        _orderCache[orderId] = order;
        return order;
      }
    } catch (e) {
      debugPrint('firebase_order_repository.getOrderById error: $e');
    }
    return null;
  }

  @override
  Future<void> addOrderWalletTransaction({
    required String customerId,
    required String orderId,
    required String sellerId,
    required double amount,
  }) async {
    await _firestore
        .collection('users')
        .doc(customerId)
        .collection('transactions')
        .add({
      'orderId': orderId,
      'sellerId': sellerId,
      'amount': -amount,
      'type': 'order_payment',
      'description': 'Order #$orderId completed',
      'status': 'completed',
      'createdAt': FieldValue.serverTimestamp(),
    });
  }
}
