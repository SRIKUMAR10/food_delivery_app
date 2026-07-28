import 'package:cloud_firestore/cloud_firestore.dart';
import '../core/models/order_model.dart';
import '../core/models/order_status.dart';
import '../core/repositories/i_order_repository.dart';

class FirebaseOrderRepository implements IOrderRepository {
  final FirebaseFirestore _firestore;

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
      return snapshot.docs
          .map((doc) => OrderModel.fromMap(doc.data(), doc.id))
          .toList();
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
      return snapshot.docs
          .map((doc) => OrderModel.fromMap(doc.data(), doc.id))
          .toList();
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
    } catch (e) {
      throw Exception('Failed to update order status: $e');
    }
  }

  @override
  Future<OrderModel?> getOrderById(String orderId) async {
    try {
      final doc = await _firestore.collection('orders').doc(orderId).get();
      if (doc.exists && doc.data() != null) {
        return OrderModel.fromMap(doc.data()!, doc.id);
      }
    } catch (e) {
      // Ignored for now or handle appropriately
    }
    return null;
  }
}
