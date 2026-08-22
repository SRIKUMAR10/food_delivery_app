// Real-Time Firestore Stream Provider Standardized
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'Delivery_Orders_page_service.dart';
import 'Delivery_Orders_page_state.dart';

abstract class DeliveryOrdersRepositoryBase {
  Future<List<DeliveryOrderCardModel>> fetchOrders();
  Future<DeliveryOrderCardModel> updateOrderStatus(
    String orderId,
    DeliveryOrderStatus status,
  );
  Future<bool> acceptOrderAtomic(String orderId);
  Future<bool> rejectOrder(String orderId, {String? reason});
  Stream<List<DeliveryOrderCardModel>> watchOrders();
  Stream<bool> watchOnlineStatus();
  Future<void> updateOnlineStatus(bool isOnline);
}

class DeliveryOrdersRepository implements DeliveryOrdersRepositoryBase {
  final DeliveryOrdersServiceBase _service;
  final FirebaseFirestore? _firestore;
  final FirebaseAuth? _auth;

  DeliveryOrdersRepository({
    DeliveryOrdersServiceBase? service,
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  })  : _service = service ?? DeliveryOrdersService(
          firestore: firestore ?? FirebaseFirestore.instance,
          auth: auth ?? FirebaseAuth.instance,
        ),
        _firestore = firestore,
        _auth = auth;

  List<DeliveryOrderCardModel> _mapOrders(Map<String, dynamic> raw) {
    final rawOrders = raw['orders'] as List? ?? [];
    return rawOrders.map((e) {
      final map = e as Map<String, dynamic>;
      return DeliveryOrderCardModel(
        orderId: map['orderId'] ?? '',
        customerName: map['customerName'] ?? '',
        restaurantName: map['restaurantName'] ?? '',
        pickupAddress: map['pickupAddress'] ?? '',
        deliveryAddress: map['deliveryAddress'] ?? '',
        amount: (map['amount'] as num?)?.toDouble() ?? 0.0,
        itemsCount: map['itemsCount'] ?? 0,
        status: _parseStatus(map['status'] ?? 'pending'),
        distance: (map['distance'] as num?)?.toDouble() ?? 0.0,
        time: map['time'] ?? '',
        paymentType: map['paymentType'] ?? 'Cash',
        phoneNumber: map['phoneNumber'] ?? '',
        etaMins: map['etaMins'] ?? 0,
        lateMins: map['lateMins'] ?? 0,
        priority: map['priority'] ?? false,
        restaurantRating: (map['restaurantRating'] as num?)?.toDouble() ?? 0.0,
        expectedTip: (map['expectedTip'] as num?)?.toDouble() ?? 0.0,
        preparationTimeMins: map['preparationTimeMins'] ?? 0,
        deliveryBonus: (map['deliveryBonus'] as num?)?.toDouble() ?? 0.0,
        restaurantLocation: map['restaurantLocation'] ?? '',
        customerArea: map['customerArea'] ?? '',
        estimatedEarnings: (map['estimatedEarnings'] as num?)?.toDouble() ?? 0.0,
        pickupDistance: (map['pickupDistance'] as num?)?.toDouble() ?? 0.0,
        deliveryDistance: (map['deliveryDistance'] as num?)?.toDouble() ?? 0.0,
        sellerId: map['sellerId'] ?? '',
        customerId: map['customerId'] ?? '',
        assignedTime: map['assignedTime'] ?? '',
        acceptedTime: map['acceptedTime'] ?? '',
        assignmentStatus: map['assignmentStatus'] ?? '',
        rejectedBy: (map['rejectedBy'] as List?)?.map((e) => e.toString()).toList() ?? const [],
        isAvailable: map['isAvailable'] ?? false,
      );
    }).toList();
  }

  DeliveryOrderStatus _parseStatus(String raw) {
    switch (raw.toLowerCase()) {
      case 'pending':
      case 'new':
      case 'neworder':
      case 'assigned':
      case 'searching_driver':
        return DeliveryOrderStatus.pending;
      case 'active':
      case 'accepted':
      case 'on_the_way':
      case 'preparing':
      case 'ready':
      case 'ready_for_pickup':
      case 'outfordelivery':
      case 'in_progress':
      case 'picked_up':
        return DeliveryOrderStatus.active;
      case 'completed':
      case 'delivered':
        return DeliveryOrderStatus.completed;
      case 'cancelled':
        return DeliveryOrderStatus.cancelled;
      default:
        return DeliveryOrderStatus.pending;
    }
  }

  @override
  Future<List<DeliveryOrderCardModel>> fetchOrders() async {
    final raw = await _service.fetchOrdersData();
    return _mapOrders(raw);
  }

  @override
  Future<DeliveryOrderCardModel> updateOrderStatus(
    String orderId,
    DeliveryOrderStatus status,
  ) async {
    final String firestoreStatus = switch (status) {
      DeliveryOrderStatus.pending => 'Accepted',
      DeliveryOrderStatus.active => 'OutForDelivery',
      DeliveryOrderStatus.completed => 'Delivered',
      DeliveryOrderStatus.cancelled => 'Cancelled',
    };

    try {
      final currentFirestore = _firestore ?? FirebaseFirestore.instance;
      await currentFirestore.collection('orders').doc(orderId).update({
        'status': firestoreStatus,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (_) {}

    final orders = await fetchOrders();
    final order = orders.firstWhere(
      (o) => o.orderId == orderId,
      orElse: () => DeliveryOrderCardModel(
        orderId: orderId,
        customerName: '',
        restaurantName: '',
        pickupAddress: '',
        deliveryAddress: '',
        amount: 0.0,
        itemsCount: 0,
        status: status,
        distance: 0.0,
        time: '',
        paymentType: '',
      ),
    );
    return order.copyWith(status: status);
  }

  @override
  Future<bool> acceptOrderAtomic(String orderId) async {
    final currentFirestore = _firestore ?? FirebaseFirestore.instance;
    final currentAuth = _auth ?? FirebaseAuth.instance;
    final partnerUid = currentAuth.currentUser?.uid;

    if (partnerUid == null || partnerUid.trim().isEmpty) {
      throw Exception('You must be signed in to accept an order.');
    }

    final partnerName = currentAuth.currentUser?.displayName ?? '';
    final partnerPhone = currentAuth.currentUser?.phoneNumber ?? '';

    final orderRef = currentFirestore.collection('orders').doc(orderId);

    return currentFirestore.runTransaction<bool>((transaction) async {
      final snapshot = await transaction.get(orderRef);
      if (!snapshot.exists) return false;

      final data = snapshot.data()!;

      final existingRider =
          data['riderId'] ?? data['deliveryPartnerId'] ?? data['driverId'];
      final isHeldByOther = existingRider != null &&
          existingRider.toString().trim().isNotEmpty &&
          existingRider.toString() != partnerUid;
      if (isHeldByOther) return false;

      final rawStatus = data['status']?.toString() ?? '';
      if (!_isEligibleForAcceptance(rawStatus)) return false;

      transaction.update(orderRef, {
        'riderId': partnerUid,
        'riderName': partnerName,
        'riderPhone': partnerPhone,
        'deliveryPartnerId': partnerUid,
        'deliveryPartnerName': partnerName,
        'deliveryPartnerPhone': partnerPhone,
        'status': 'OutForDelivery',
        'deliveryPartnerStatus': 'accepted',
        'pickupStatus': 'heading_to_store',
        'deliveryAssignmentStatus': 'assigned',
        'assignedAt': FieldValue.serverTimestamp(),
        'acceptedAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      final sellerId = (data['sellerId'] ?? data['seller_id'] ?? '').toString();
      final customerId =
          (data['customerId'] ?? data['customer_id'] ?? '').toString();

      final assignmentId =
          currentFirestore.collection('order_assignments').doc().id;
      transaction.set(
        currentFirestore.collection('order_assignments').doc(assignmentId),
        {
          'assignmentId': assignmentId,
          'partnerId': partnerUid,
          'orderId': orderId,
          'restaurantId': sellerId,
          'customerId': customerId,
          'assignedTime': FieldValue.serverTimestamp(),
          'acceptedTime': FieldValue.serverTimestamp(),
          'assignmentStatus': 'accepted',
          'createdAt': FieldValue.serverTimestamp(),
        },
      );

      transaction.set(orderRef.collection('assignments').doc(partnerUid), {
        'partnerId': partnerUid,
        'orderId': orderId,
        'restaurantId': sellerId,
        'customerId': customerId,
        'assignedTime': FieldValue.serverTimestamp(),
        'acceptedTime': FieldValue.serverTimestamp(),
        'assignmentStatus': 'accepted',
        'createdAt': FieldValue.serverTimestamp(),
      });

      return true;
    });
  }

  bool _isEligibleForAcceptance(String status) {
    switch (status.toLowerCase()) {
      case 'ready':
      case 'ready_for_pickup':
      case 'order_ready':
      case 'searching_driver':
      case 'pending':
      case 'new':
      case 'neworder':
      case 'confirmed':
      case 'preparing':
        return true;
      default:
        return false;
    }
  }

  @override
  Future<bool> rejectOrder(String orderId, {String? reason}) async {
    final currentFirestore = _firestore ?? FirebaseFirestore.instance;
    final currentAuth = _auth ?? FirebaseAuth.instance;
    final partnerUid = currentAuth.currentUser?.uid;

    if (partnerUid == null || partnerUid.trim().isEmpty) {
      throw Exception('You must be signed in to reject an order.');
    }

    final orderRef = currentFirestore.collection('orders').doc(orderId);
    await orderRef.update({
      'rejectedBy': FieldValue.arrayUnion([partnerUid]),
      'rejectedAt': FieldValue.serverTimestamp(),
      if (reason != null && reason.trim().isNotEmpty) 'rejectionReason': reason,
      'updatedAt': FieldValue.serverTimestamp(),
    });
    return true;
  }

  @override
  Stream<List<DeliveryOrderCardModel>> watchOrders() {
    return _service.watchOrdersData().map(_mapOrders);
  }

  @override
  Stream<bool> watchOnlineStatus() {
    final currentFirestore = _firestore ?? FirebaseFirestore.instance;
    final currentAuth = _auth ?? FirebaseAuth.instance;
    final uid = currentAuth.currentUser?.uid;
    if (uid == null || uid.isEmpty) {
      return Stream.value(true);
    }
    return currentFirestore
        .collection('delivery_partners')
        .doc(uid)
        .snapshots()
        .map((doc) {
      if (!doc.exists || doc.data() == null) return true;
      final data = doc.data()!;
      return (data['isOnline'] as bool?) ?? true;
    }).handleError((_) => true);
  }

  @override
  Future<void> updateOnlineStatus(bool isOnline) async {
    final currentFirestore = _firestore ?? FirebaseFirestore.instance;
    final currentAuth = _auth ?? FirebaseAuth.instance;
    final uid = currentAuth.currentUser?.uid;
    if (uid == null || uid.isEmpty) return;

    final updates = {
      'isOnline': isOnline,
      'isAvailable': isOnline,
      'status': isOnline ? 'online' : 'offline',
      'lastActiveAt': FieldValue.serverTimestamp(),
      if (!isOnline) 'lastLogout': FieldValue.serverTimestamp(),
    };

    try {
      await currentFirestore
          .collection('delivery_partners')
          .doc(uid)
          .set(updates, SetOptions(merge: true));
    } catch (_) {}

    try {
      await currentFirestore
          .collection('riders')
          .doc(uid)
          .set(updates, SetOptions(merge: true));
    } catch (_) {}
  }
}

