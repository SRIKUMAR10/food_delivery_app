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
        .snapshots(includeMetadataChanges: true)
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
        .snapshots(includeMetadataChanges: true)
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final order = OrderModel.fromMap(doc.data(), doc.id);
        _orderCache[doc.id] = order;
        return order;
      }).toList();
    });
  }

  @override
  Stream<OrderModel?> streamOrderById(String orderId) {
    if (orderId.isEmpty) {
      return Stream.value(null);
    }
    return _firestore
        .collection('orders')
        .doc(orderId)
        .snapshots(includeMetadataChanges: true)
        .map((snapshot) {
      if (!snapshot.exists || snapshot.data() == null) {
        return null;
      }
      final order = OrderModel.fromMap(snapshot.data()!, snapshot.id);
      _orderCache[snapshot.id] = order;
      return order;
    }).handleError((error) {
      debugPrint('Error in streamOrderById ($orderId): $error');
      return null;
    });
  }

  @override
  Stream<List<OrderModel>> streamAvailableDeliveryOrders() {
    return _firestore
        .collection('orders')
        .where('status', whereIn: ['ready', 'ready_for_pickup', 'preparing'])
        .snapshots(includeMetadataChanges: true)
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final order = OrderModel.fromMap(doc.data(), doc.id);
        _orderCache[doc.id] = order;
        return order;
      }).toList();
    }).handleError((error) {
      debugPrint('Error in streamAvailableDeliveryOrders: $error');
      return <OrderModel>[];
    });
  }

  @override
  Future<void> updateOrderStatus(String orderId, OrderStatus newStatus, {String? reason}) async {
    try {
      final Map<String, dynamic> updates = {
        'status': newStatus.value,
        'updatedAt': FieldValue.serverTimestamp(),
      };

      if (reason != null && reason.trim().isNotEmpty) {
        updates['cancellationReason'] = reason.trim();
      }

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
        case OrderStatus.pickedUp:
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
  Stream<DriverLocation> streamDriverLocation(String orderId) {
    if (orderId.isEmpty) {
      return Stream.value(const DriverLocation(lat: 0, lng: 0, timestamp: null));
    }
    return _firestore
        .collection('orders')
        .doc(orderId)
        .collection('live_location')
        .doc('current')
        .snapshots()
        .map((snapshot) {
      if (!snapshot.exists || snapshot.data() == null) {
        return const DriverLocation(lat: 0, lng: 0, timestamp: null);
      }
      final data = snapshot.data()!;
      final lat = (data['lat'] as num?)?.toDouble() ?? 0.0;
      final lng = (data['lng'] as num?)?.toDouble() ?? 0.0;
      final ts = (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now();
      return DriverLocation(lat: lat, lng: lng, timestamp: ts);
    });
  }

  @override
  Future<void> updateDriverLocation(String orderId, String driverId, double lat, double lng) async {
    await _firestore
        .collection('orders')
        .doc(orderId)
        .collection('live_location')
        .doc('current')
        .set({
      'lat': lat,
      'lng': lng,
      'driverId': driverId,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    await _firestore.collection('orders').doc(orderId).update({
      'driverLat': lat,
      'driverLng': lng,
    });

    await _firestore.collection('delivery_partners').doc(driverId).update({
      'currentLocation': {'lat': lat, 'lng': lng},
      'driverLat': lat,
      'driverLng': lng,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  @override
  Future<void> completeDeliveryWithEarnings({
    required String orderId,
    required String driverId,
    required double deliveryFee,
    required double totalOrderAmount,
    required String sellerId,
    required String customerId,
  }) async {
    final batch = _firestore.batch();

    final orderRef = _firestore.collection('orders').doc(orderId);
    batch.update(orderRef, {
      'status': OrderStatus.delivered.value,
      'deliveryPartnerStatus': 'completed',
      'deliveryStatus': 'delivered',
      'deliveredAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });

    if (driverId.isNotEmpty) {
      final driverRef = _firestore.collection('delivery_partners').doc(driverId);
      batch.set(driverRef, {
        'totalEarnings': FieldValue.increment(deliveryFee),
        'completedTrips': FieldValue.increment(1),
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      final driverTxRef = _firestore
          .collection('delivery_partners')
          .doc(driverId)
          .collection('transactions')
          .doc();
      batch.set(driverTxRef, {
        'orderId': orderId,
        'amount': deliveryFee,
        'type': 'delivery_earning',
        'description': 'Delivery fee for order #$orderId',
        'status': 'completed',
        'createdAt': FieldValue.serverTimestamp(),
      });
    }

    if (sellerId.isNotEmpty) {
      final sellerRef = _firestore.collection('sellers').doc(sellerId);
      batch.set(sellerRef, {
        'totalEarnings': FieldValue.increment(totalOrderAmount),
      }, SetOptions(merge: true));
    }

    if (customerId.isNotEmpty) {
      final customerTxRef = _firestore
          .collection('buyer_user')
          .doc(customerId)
          .collection('transactions')
          .doc();
      batch.set(customerTxRef, {
        'orderId': orderId,
        'amount': -totalOrderAmount,
        'type': 'order_payment',
        'description': 'Order #$orderId completed',
        'status': 'completed',
        'createdAt': FieldValue.serverTimestamp(),
      });
    }

    _orderCache.remove(orderId);
    await batch.commit();
  }

  @override
  Future<void> addOrderWalletTransaction({
    required String customerId,
    required String orderId,
    required String sellerId,
    required double amount,
  }) async {
    await _firestore
        .collection('buyer_user')
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
