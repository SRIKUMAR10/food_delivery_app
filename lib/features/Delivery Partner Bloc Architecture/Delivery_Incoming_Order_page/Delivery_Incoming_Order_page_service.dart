import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

abstract class DeliveryIncomingOrderServiceBase {
  Future<bool> checkNetworkConnectivity();
  Future<bool> requestLocationPermission();
  double calculateDistance(double lat1, double lon1, double lat2, double lon2);
  String formatCurrency(double amount);
  Future<Map<String, dynamic>?> fetchIncomingOrderData();
  Stream<Map<String, dynamic>?> watchIncomingOrderData();
  Future<bool> acceptIncomingOrder(String orderId);
  Future<bool> declineIncomingOrder(String orderId);
}

class DeliveryIncomingOrderService
    implements DeliveryIncomingOrderServiceBase {
  final FirebaseFirestore? _firestore;
  final FirebaseAuth? _auth;

  DeliveryIncomingOrderService({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;
  @override
  Future<bool> checkNetworkConnectivity() async {
    if (kIsWeb) {
      return true;
    }
    try {
      final result = await InternetAddress.lookup('google.com')
          .timeout(const Duration(seconds: 5));
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } on SocketException {
      return false;
    } on TimeoutException {
      return false;
    } catch (_) {
      return false;
    }
  }

  @override
  Future<bool> requestLocationPermission() async {
    return true;
  }

  @override
  double calculateDistance(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    const double r = 6371;
    final dLat = _toRad(lat2 - lat1);
    final dLon = _toRad(lon2 - lon1);
    final a = _sin(dLat / 2) * _sin(dLat / 2) +
        _cos(_toRad(lat1)) *
            _cos(_toRad(lat2)) *
            _sin(dLon / 2) *
            _sin(dLon / 2);
    final c = 2 * _atan2(_sqrt(a), _sqrt(1 - a));
    return r * c;
  }

  double _toRad(double degree) => degree * 3.141592653589793 / 180.0;
  double _sin(double x) => _sinImpl(x);
  double _cos(double x) => _cosImpl(x);
  double _sqrt(double x) => _sqrtImpl(x);
  double _atan2(double a, double b) => _atan2Impl(a, b);

  static double _sinImpl(double x) {
    double result = x;
    double term = x;
    for (int i = 1; i <= 10; i++) {
      term *= -x * x / ((2 * i) * (2 * i + 1));
      result += term;
    }
    return result;
  }

  static double _cosImpl(double x) {
    double result = 1.0;
    double term = 1.0;
    for (int i = 1; i <= 10; i++) {
      term *= -x * x / ((2 * i - 1) * (2 * i));
      result += term;
    }
    return result;
  }

  static double _sqrtImpl(double x) {
    if (x <= 0) return 0;
    double guess = x;
    for (int i = 0; i < 20; i++) {
      guess = (guess + x / guess) / 2;
    }
    return guess;
  }

  static double _atan2Impl(double y, double x) {
    if (x > 0) return _atan(y / x);
    if (x < 0 && y >= 0) return _atan(y / x) + 3.141592653589793;
    if (x < 0 && y < 0) return _atan(y / x) - 3.141592653589793;
    if (x == 0 && y > 0) return 3.141592653589793 / 2;
    if (x == 0 && y < 0) return -3.141592653589793 / 2;
    return 0;
  }

  static double _atan(double x) {
    double result = x;
    double term = x;
    for (int i = 1; i <= 20; i++) {
      term *= -x * x;
      result += term / (2 * i + 1);
    }
    return result;
  }

  @override
  String formatCurrency(double amount) {
    return '\u{20B9}${amount.toStringAsFixed(2)}';
  }

  @override
  Future<Map<String, dynamic>?> fetchIncomingOrderData() async {
    try {
      final fs = _firestore;
      final user = _auth?.currentUser;
      if (fs != null && user != null) {
        final uid = user.uid;
        // Search assigned orders first
        var query = await fs
            .collection('orders')
            .where('riderId', isEqualTo: uid)
            .where('status', whereIn: ['assigned', 'searching_driver', 'Ready', 'ready', 'ready_for_pickup'])
            .limit(1)
            .get();

        if (query.docs.isEmpty) {
          // If no direct assigned order, check unassigned ready orders
          query = await fs
              .collection('orders')
              .where('status', whereIn: ['Ready', 'ready', 'ready_for_pickup', 'assigned', 'searching_driver'])
              .limit(1)
              .get();
        }

        if (query.docs.isNotEmpty) {
          return await _mapIncomingOrderDoc(query.docs.first);
        }
      }
    } catch (_) {}
    return null;
  }

  @override
  Stream<Map<String, dynamic>?> watchIncomingOrderData() {
    final fs = _firestore;
    final user = _auth?.currentUser;
    if (fs == null || user == null) {
      return Stream.value(null);
    }
    final uid = user.uid;
    return fs
        .collection('orders')
        .where('status', whereIn: ['Ready', 'ready', 'ready_for_pickup', 'assigned', 'searching_driver', 'Preparing', 'preparing'])
        .snapshots()
        .asyncMap((snapshot) async {
      if (snapshot.docs.isEmpty) return null;
      // Prefer order explicitly assigned to rider, else first ready order
      final doc = snapshot.docs.firstWhere(
        (d) => (d.data()['riderId'] == uid || d.data()['deliveryPartnerId'] == uid),
        orElse: () => snapshot.docs.first,
      );
      return await _mapIncomingOrderDoc(doc);
    });
  }

  Future<Map<String, dynamic>?> _mapIncomingOrderDoc(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) async {
    final data = doc.data() ?? {};
    final sellerId = data['sellerId'] as String? ?? '';

    String shopName = '';
    String shopAddress = '';
    final fs = _firestore;
    if (sellerId.isNotEmpty && fs != null) {
      final sellerDoc =
          await fs.collection('sellers').doc(sellerId).get();
      if (sellerDoc.exists) {
        final sData = sellerDoc.data()!;
        shopName = sData['shopName'] as String? ??
            sData['name'] as String? ??
            '';
        shopAddress = sData['address'] as String? ?? '';
      }
    }

    String customerName = data['customerName'] as String? ?? '';
    String customerAddress = data['deliveryAddress'] as String? ?? data['address'] as String? ?? '';
    String customerPhone = data['customerPhone'] as String? ?? data['phone'] as String? ?? data['userPhone'] as String? ?? '';

    final customerId = (data['customerId'] ?? data['customer_id'] ?? data['userId'] ?? data['user_id'] ?? data['buyerId'] ?? data['buyer_id'] ?? data['customerUid'] ?? data['buyerUid'] ?? data['uid'])?.toString();

    if ((customerName.isEmpty || customerName == 'Customer' || customerAddress.isEmpty || customerPhone.isEmpty) && customerId != null && customerId.isNotEmpty && fs != null) {
      try {
        final uDoc = await fs.collection('buyer_user').doc(customerId).get();
        if (uDoc.exists && uDoc.data() != null) {
          final uData = uDoc.data()!;
          final uName = uData['name'] ?? uData['displayName'] ?? uData['fullName'] ?? uData['userName'] ?? uData['buyerName'] ?? uData['customerName'] ?? '';
          final uPhone = uData['phone'] ?? uData['phoneNumber'] ?? uData['mobile'] ?? uData['userPhone'] ?? uData['contactNumber'] ?? '';

          if (customerName.isEmpty || customerName == 'Customer') {
            if (uName.toString().trim().isNotEmpty) {
              customerName = uName.toString().trim();
            }
          }
          if (customerPhone.isEmpty && uPhone.toString().trim().isNotEmpty) {
            customerPhone = uPhone.toString().trim();
          }
          if (customerAddress.isEmpty) {
            for (final k in ['address', 'primaryAddress', 'homeAddress', 'workAddress', 'deliveryAddress', 'shippingAddress']) {
              final val = uData[k];
              if (val != null && val is String && val.trim().isNotEmpty && val.trim() != 'Primary Address') {
                customerAddress = val.trim();
                break;
              }
            }
          }
        }
      } catch (_) {}
    }

    if (customerName.isEmpty) customerName = 'Customer';

    return {
      'orderId': doc.id,
      'storeName': shopName,
      'storeAddress': shopAddress,
      'customerName': customerName,
      'customerAddress': customerAddress,
      'customerPhone': customerPhone,
      'orderAmount': (data['amount'] as num?)?.toDouble() ?? 0.0,
      'distanceKm': (data['distance'] as num?)?.toDouble() ?? 0.0,
      'etaMins': (data['etaMins'] as num?)?.toInt() ?? (data['etaMinutes'] as num?)?.toInt() ?? 0,
      'paymentMethod': data['paymentMethod'] ?? data['paymentType'] ?? '',
      'remainingSeconds': 0,
    };
  }

  @override
  Future<bool> acceptIncomingOrder(String orderId) async {
    try {
      final fs = _firestore;
      if (fs != null) {
        final uid = _auth?.currentUser?.uid ?? '';
        String driverName = 'Delivery Partner';
        String driverPhone = '';
        if (uid.isNotEmpty) {
          final pDoc = await fs.collection('delivery_partners').doc(uid).get();
          if (pDoc.exists) {
            final pData = pDoc.data() ?? {};
            driverName = pData['displayName'] as String? ?? pData['name'] as String? ?? driverName;
            driverPhone = pData['phoneNumber'] as String? ?? pData['phone'] as String? ?? driverPhone;
          }
        }

        await fs.collection('orders').doc(orderId).update({
          'status': 'OutForDelivery',
          'riderId': uid,
          'deliveryPartnerId': uid,
          'deliveryPartnerName': driverName,
          'deliveryPartnerPhone': driverPhone,
          'deliveryPartnerStatus': 'accepted',
          'acceptedAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        });
        return true;
      }
    } catch (_) {}
    return false;
  }

  @override
  Future<bool> declineIncomingOrder(String orderId) async {
    try {
      final fs = _firestore;
      if (fs != null) {
        await fs.collection('orders').doc(orderId).update({
          'status': 'Ready',
          'riderId': FieldValue.delete(),
        });
        return true;
      }
    } catch (_) {}
    return false;
  }
}
