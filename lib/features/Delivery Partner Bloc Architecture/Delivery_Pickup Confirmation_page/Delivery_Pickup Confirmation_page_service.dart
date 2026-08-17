import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

abstract class DeliveryPickupConfirmationServiceBase {
  Future<Map<String, dynamic>> fetchPickupConfirmationData(String orderId);
  Stream<Map<String, dynamic>> watchPickupConfirmationData(String orderId);
  Future<Map<String, dynamic>> startDeliveryData(String orderId);
  Future<bool> arrivedAtStore(String orderId);
  String formatCurrency(double amount);
  bool isValidPhoneNumber(String phoneNumber);
  String buildWhatsAppLink(String phoneNumber);
  Map<String, String> getEnvironmentVariables();
  Future<bool> requestPhonePermission();
  Future<bool> requestLocationPermission();
}

class DeliveryPickupConfirmationService
    implements DeliveryPickupConfirmationServiceBase {
  static const Map<String, String> _environment = {
    'BASE_URL': 'https://api.fooddelivery.example',
    'PICKUP_URL':
        'https://api.fooddelivery.example/v1/delivery/pickup/confirmation',
    'WS_URL': 'wss://socket.fooddelivery.example',
  };

  final FirebaseFirestore? _firestore;
  final FirebaseAuth? _auth;

  DeliveryPickupConfirmationService({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  String _formatTimestamp(dynamic timestamp) {
    if (timestamp is Timestamp) {
      final date = timestamp.toDate();
      final hour = date.hour > 12 ? date.hour - 12 : (date.hour == 0 ? 12 : date.hour);
      final minute = date.minute.toString().padLeft(2, '0');
      final period = date.hour >= 12 ? 'PM' : 'AM';
      return '$hour:$minute $period';
    }
    return '';
  }

  @override
  Future<Map<String, dynamic>> fetchPickupConfirmationData(
    String orderId,
  ) async {
    try {
      final fs = _firestore;
      if (fs != null) {
        final orderDoc = await fs.collection('orders').doc(orderId).get();
        if (orderDoc.exists) {
          return await _mapPickupDoc(orderDoc);
        }
      }
    } catch (_) {}
    return {};
  }

  @override
  Stream<Map<String, dynamic>> watchPickupConfirmationData(String orderId) {
    final fs = _firestore;
    if (fs == null || orderId.isEmpty) {
      return Stream.value({});
    }
    return fs
        .collection('orders')
        .doc(orderId)
        .snapshots(includeMetadataChanges: true)
        .asyncMap((doc) async {
      if (!doc.exists) return <String, dynamic>{};
      return await _mapPickupDoc(doc);
    }).handleError((_) => <String, dynamic>{});
  }

  Future<Map<String, dynamic>> _mapPickupDoc(DocumentSnapshot<Map<String, dynamic>> orderDoc) async {
    final fs = _firestore;
    final data = orderDoc.data() ?? {};
    final sellerId = data['sellerId'] as String? ?? '';

    String shopName = 'Restaurant';
    String shopAddress = '';
    String shopPhone = '';

    if (sellerId.isNotEmpty && fs != null) {
      final sellerDoc = await fs.collection('sellers').doc(sellerId).get();
      if (sellerDoc.exists) {
        final sData = sellerDoc.data()!;
        shopName = sData['shopName'] as String? ?? sData['name'] as String? ?? 'Restaurant';
        shopAddress = sData['address'] as String? ?? '';
        shopPhone = sData['phoneNumber'] as String? ?? sData['contactNumber'] as String? ?? '';
      }
    }

    double walletBalance = 0.0;
    final user = _auth?.currentUser;
    if (user != null && fs != null) {
      final partnerDoc = await fs
          .collection('delivery_partners')
          .doc(user.uid)
          .get();
      if (partnerDoc.exists) {
        walletBalance = (partnerDoc.data()?['totalEarnings'] as num?)?.toDouble() ?? 0.0;
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
      'orderId': orderDoc.id,
      'pickupLocationName': shopName,
      'pickupAddress': shopAddress,
      'pickupContactName': shopName,
      'pickupContactPhone': shopPhone,
      'pickupInstructions': data['deliveryInstructions'] ?? 'Collect sealed bags.',
      'customerName': customerName,
      'customerAddress': customerAddress,
      'customerPhone': customerPhone,
      'pickupTime': _formatTimestamp(data['timestamp']),
      'paymentType': data['paymentMethod'] ?? 'Cash on Delivery',
      'orderAmount': (data['amount'] as num?)?.toDouble() ?? 0.0,
      'walletBalance': walletBalance,
    };
  }

  @override
  Future<bool> arrivedAtStore(String orderId) async {
    try {
      final fs = _firestore;
      if (fs != null) {
        await fs.collection('orders').doc(orderId).update({
          'pickupStatus': 'arrived_at_store',
          'arrivedAtStoreAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        });
        return true;
      }
    } catch (_) {}
    return false;
  }

  @override
  Future<Map<String, dynamic>> startDeliveryData(String orderId) async {
    try {
      final fs = _firestore;
      if (fs != null) {
        await fs.collection('orders').doc(orderId).update({
          'status': 'OutForDelivery',
          'deliveryPartnerStatus': 'picked_up',
          'deliveryStatus': 'picked_up',
          'pickupStatus': 'picked_up',
          'outForDeliveryAt': FieldValue.serverTimestamp(),
          'pickedUpAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }
    } catch (_) {}
    return fetchPickupConfirmationData(orderId);
  }

  @override
  String formatCurrency(double amount) {
    return '₹${amount.toStringAsFixed(2)}';
  }

  @override
  bool isValidPhoneNumber(String phoneNumber) {
    final digits = phoneNumber.replaceAll(RegExp(r'\D'), '');
    return digits.length >= 10;
  }

  @override
  String buildWhatsAppLink(String phoneNumber) {
    final digits = phoneNumber.replaceAll(RegExp(r'\D'), '');
    return 'https://wa.me/$digits';
  }

  @override
  Map<String, String> getEnvironmentVariables() {
    return Map<String, String>.unmodifiable(_environment);
  }

  @override
  Future<bool> requestPhonePermission() async {
    await Future.delayed(const Duration(milliseconds: 50));
    return true;
  }

  @override
  Future<bool> requestLocationPermission() async {
    await Future.delayed(const Duration(milliseconds: 50));
    return true;
  }
}
