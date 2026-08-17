import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

abstract class DeliveryCompletedServiceBase {
  Future<Map<String, dynamic>> fetchCompletedOrderData(String orderId);
  Future<Map<String, dynamic>> completeOrderData(String orderId);
  Stream<double> chunkedMediaUpload(String orderId);
  String? validateMedia(String? filePath);
  Map<String, String> getEnvironmentVariables();
  Future<bool> requestMediaPermission();
  Future<bool> requestLocationPermission();
  String formatCurrency(double amount);
  String formatDistance(double distance);
}

class DeliveryCompletedService implements DeliveryCompletedServiceBase {
  static const Map<String, String> _environment = {
    'BASE_URL': 'https://api.fooddelivery.example',
    'COMPLETED_URL':
        'https://api.fooddelivery.example/v1/delivery/order/completed',
    'WS_URL': 'wss://socket.fooddelivery.example',
  };

  final FirebaseFirestore? _firestore;
  final FirebaseAuth? _auth;

  DeliveryCompletedService({
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
  Future<Map<String, dynamic>> fetchCompletedOrderData(
    String orderId,
  ) async {
    try {
      final fs = _firestore;
      if (fs != null) {
        final orderDoc = await fs.collection('orders').doc(orderId).get();
        if (orderDoc.exists) {
          final data = orderDoc.data()!;

          double walletBalance = 0.0;
          String partnerName = '';
          String partnerVehicleNo = '';
          final user = _auth?.currentUser;
          if (user != null) {
            final partnerDoc = await fs
                .collection('delivery_partners')
                .doc(user.uid)
                .get();
            if (partnerDoc.exists) {
              final pData = partnerDoc.data()!;
              walletBalance = (pData['totalEarnings'] as num?)?.toDouble() ?? 0.0;
              partnerName = pData['displayName'] ?? '';
              partnerVehicleNo = pData['vehicleNumber'] ?? '';
            }
          }

          String customerName = data['customerName'] as String? ?? '';
          String deliveryAddress = data['deliveryAddress'] as String? ?? data['address'] as String? ?? '';
          String customerPhone = data['customerPhone'] as String? ?? data['phone'] as String? ?? data['userPhone'] as String? ?? '';

          final customerId = (data['customerId'] ?? data['customer_id'] ?? data['userId'] ?? data['user_id'] ?? data['buyerId'] ?? data['buyer_id'] ?? data['customerUid'] ?? data['buyerUid'] ?? data['uid'])?.toString();

          if ((customerName.isEmpty || customerName == 'Customer' || deliveryAddress.isEmpty || customerPhone.isEmpty) && customerId != null && customerId.isNotEmpty) {
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
                if (deliveryAddress.isEmpty) {
                  for (final k in ['address', 'primaryAddress', 'homeAddress', 'workAddress', 'deliveryAddress', 'shippingAddress']) {
                    final val = uData[k];
                    if (val != null && val is String && val.trim().isNotEmpty && val.trim() != 'Primary Address') {
                      deliveryAddress = val.trim();
                      break;
                    }
                  }
                }
              }
            } catch (_) {}
          }

          if (customerName.isEmpty) customerName = 'Customer';

          final double earnings = ((data['amount'] as num?)?.toDouble() ?? 0.0) * 0.15;

          final double codAmount =
              ((data['codAmount'] ?? data['amount']) as num?)?.toDouble() ?? 0.0;
          final double collectedAmount =
              (data['collectedAmount'] as num?)?.toDouble() ?? 0.0;

          final double? baseFareRaw = (data['baseFare'] as num?)?.toDouble();
          final double? distanceFareRaw =
              (data['distanceFare'] as num?)?.toDouble();
          final double? surgeFareRaw = (data['surgeFare'] as num?)?.toDouble();
          final double? incentiveRaw =
              ((data['incentiveAmount'] ?? data['incentive']) as num?)
                  ?.toDouble();
          final double? bonusRaw =
              ((data['bonusAmount'] ?? data['bonus']) as num?)?.toDouble();
          final double? tipsRaw =
              ((data['tipsAmount'] ?? data['tipAmount'] ?? data['tips']) as num?)
                  ?.toDouble();
          final double? cancellationCompensationRaw =
              (data['cancellationCompensation'] as num?)?.toDouble();

          final bool hasBreakdown = baseFareRaw != null ||
              distanceFareRaw != null ||
              surgeFareRaw != null ||
              incentiveRaw != null ||
              bonusRaw != null ||
              tipsRaw != null ||
              cancellationCompensationRaw != null;

          final double baseFare = hasBreakdown ? (baseFareRaw ?? 0.0) : earnings;
          final double distanceFare =
              hasBreakdown ? (distanceFareRaw ?? 0.0) : 0.0;
          final double surgeFare = hasBreakdown ? (surgeFareRaw ?? 0.0) : 0.0;
          final double incentive = hasBreakdown ? (incentiveRaw ?? 0.0) : 0.0;
          final double bonus = hasBreakdown ? (bonusRaw ?? 0.0) : 0.0;
          final double tips = hasBreakdown ? (tipsRaw ?? 0.0) : 0.0;
          final double cancellationCompensation =
              hasBreakdown ? (cancellationCompensationRaw ?? 0.0) : 0.0;

          final double totalPartnerEarnings =
              (data['totalPartnerEarnings'] as num?)?.toDouble() ??
                  (hasBreakdown
                      ? baseFare +
                          distanceFare +
                          surgeFare +
                          incentive +
                          bonus +
                          tips +
                          cancellationCompensation
                      : earnings);

          return {
            'orderId': orderId,
            'walletBalance': walletBalance,
            'partnerName': partnerName,
            'partnerVehicleNo': partnerVehicleNo,
            'customerName': customerName,
            'deliveryAddress': deliveryAddress,
            'customerPhone': customerPhone,
            'timeTaken': data['timeTaken'] ?? '',
            'distanceCovered': (data['distance'] as num?)?.toDouble() ?? 0.0,
            'paymentStatus': data['paymentStatus'] ?? '',
            'paymentMethod': data['paymentMethod'] ?? '',
            'customerRating': (data['customerRating'] as num?)?.toDouble() ?? 0.0,
            'deliveryEarnings': earnings,
            'completedAt': data['deliveredAt'] != null
                ? _formatTimestamp(data['deliveredAt'])
                : '',
            'isCOD': (data['paymentMethod'] as String? ?? '')
                    .toUpperCase() ==
                'COD',
            'codAmount': codAmount,
            'collectedAmount': collectedAmount,
            'isCodCollected': data['isCodCollected'] == true,
            'codReconciliationStatus': data['codReconciliationStatus'] ?? '',
            'baseFare': baseFare,
            'distanceFare': distanceFare,
            'surgeFare': surgeFare,
            'incentive': incentive,
            'bonus': bonus,
            'tips': tips,
            'cancellationCompensation': cancellationCompensation,
            'totalPartnerEarnings': totalPartnerEarnings,
          };
        }
      }
    } catch (_) {}
    return {};
  }

  @override
  Future<Map<String, dynamic>> completeOrderData(String orderId) async {
    try {
      final fs = _firestore;
      if (fs != null) {
        final orderDoc = await fs.collection('orders').doc(orderId).get();
        final orderData = orderDoc.data() ?? {};
        final amount = (orderData['amount'] as num?)?.toDouble() ?? 0.0;
        final deliveryFee = (amount * 0.15) > 30.0 ? (amount * 0.15) : 35.0;
        final sellerId = orderData['sellerId'] as String? ?? '';
        final isCOD =
            (orderData['paymentMethod'] as String? ?? '').toUpperCase() == 'COD';
        final isCodCollected = orderData['isCodCollected'] == true;

        final double baseFare = 35.0;
        final double distanceFare =
            (deliveryFee - 35.0) > 0.0 ? (deliveryFee - 35.0) : 0.0;

        final batch = fs.batch();

        final orderRef = fs.collection('orders').doc(orderId);
        batch.update(orderRef, {
          'status': 'Delivered',
          'deliveryPartnerStatus': 'completed',
          'deliveryStatus': 'delivered',
          'pickupStatus': 'delivered',
          'deliveredAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
          'baseFare': baseFare,
          'distanceFare': distanceFare,
          'surgeFare': 0.0,
          'incentiveAmount': 0.0,
          'bonusAmount': 0.0,
          'tipsAmount': 0.0,
          'cancellationCompensation': 0.0,
          'totalPartnerEarnings': deliveryFee,
          if (isCOD && isCodCollected)
            'codReconciliationStatus': 'pending_submission',
        });

        final user = _auth?.currentUser;
        if (user != null) {
          final driverRef = fs.collection('delivery_partners').doc(user.uid);
          batch.set(
            driverRef,
            {
              'totalEarnings': FieldValue.increment(deliveryFee),
              'completedTrips': FieldValue.increment(1),
              'updatedAt': FieldValue.serverTimestamp(),
            },
            SetOptions(merge: true),
          );
        }

        if (sellerId.isNotEmpty) {
          final sellerRef = fs.collection('sellers').doc(sellerId);
          final sellerEarnings = amount - deliveryFee;
          batch.set(
            sellerRef,
            {
              'totalOrders': FieldValue.increment(1),
              'completedOrders': FieldValue.increment(1),
              if (sellerEarnings > 0) 'walletBalance': FieldValue.increment(sellerEarnings),
              'updatedAt': FieldValue.serverTimestamp(),
            },
            SetOptions(merge: true),
          );
        }

        await batch.commit();
      }
    } catch (_) {}
    return fetchCompletedOrderData(orderId);
  }

  @override
  Stream<double> chunkedMediaUpload(String orderId) async* {
    const int chunks = 10;
    for (var i = 1; i <= chunks; i++) {
      await Future<void>.delayed(const Duration(milliseconds: 40));
      yield i / chunks;
    }
  }

  @override
  String? validateMedia(String? filePath) {
    if (filePath == null || filePath.isEmpty) {
      return 'Please choose a file to upload';
    }
    final extension = filePath.split('.').last.toLowerCase();
    const allowed = ['jpg', 'jpeg', 'png', 'pdf', 'webp'];
    if (!allowed.contains(extension)) {
      return 'Unsupported file type: .$extension';
    }
    return null;
  }

  @override
  Map<String, String> getEnvironmentVariables() {
    return Map<String, String>.unmodifiable(_environment);
  }

  @override
  Future<bool> requestMediaPermission() async {
    await Future.delayed(const Duration(milliseconds: 50));
    return true;
  }

  @override
  Future<bool> requestLocationPermission() async {
    await Future.delayed(const Duration(milliseconds: 50));
    return true;
  }

  @override
  String formatCurrency(double amount) {
    return '₹${amount.toStringAsFixed(2)}';
  }

  @override
  String formatDistance(double distance) {
    return '${distance.toStringAsFixed(1)} km';
  }
}
