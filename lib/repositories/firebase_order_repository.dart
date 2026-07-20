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
      await _firestore.collection('orders').doc(orderId).update({
        'status': newStatus.name,
        'updatedAt': FieldValue.serverTimestamp(), // Assuming updatedAt exists or is a good practice
      });
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
