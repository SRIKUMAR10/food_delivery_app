import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:food_delivery_app/core/models/order_status.dart';
import 'package:food_delivery_app/repositories/firebase_order_repository.dart';

abstract class DeliveryOrderDetailsServiceBase {
  Future<Map<String, dynamic>> fetchOrderDetailsData(String orderId);
  Stream<Map<String, dynamic>> watchOrderDetailsData(String orderId);
  Future<bool> updateOrderStatusRemote(String orderId, String status);
  Future<bool> markGoingToRestaurant(String orderId);
  Future<bool> markArrivedAtRestaurant(String orderId);
  Future<bool> verifyPickupOtp(String orderId, String otp);
  Future<bool> confirmPickup(String orderId);
  Future<Map<String, dynamic>> collectCodCash(
    String orderId, {
    required double amountReceived,
  });
  Future<Map<String, dynamic>> cancelOrderWithReason(
    String orderId, {
    required String reason,
    String? notes,
    bool isFailedDelivery = false,
  });
}

class DeliveryOrderDetailsService
    implements DeliveryOrderDetailsServiceBase {
  final FirebaseOrderRepository? _orderRepo;
  final FirebaseFirestore? _firestore;

  DeliveryOrderDetailsService({
    FirebaseOrderRepository? orderRepo,
    FirebaseFirestore? firestore,
  })  : _orderRepo = orderRepo ?? FirebaseOrderRepository(),
        _firestore = firestore;

  final Map<String, Map<String, dynamic>> _sellerCache = {};
  final Map<String, Map<String, dynamic>> _userCache = {};

  bool _isRawUid(String? text) {
    if (text == null || text.trim().isEmpty) return false;
    final trimmed = text.trim();
    return trimmed.length >= 20 && !trimmed.contains(' ');
  }

  String _parseField(
    Map<String, dynamic> data,
    List<String> stringKeys,
    List<String> mapKeys,
    List<String> mapSubKeys,
  ) {
    for (final key in stringKeys) {
      final val = data[key];
      if (val != null) {
        if (val is String && val.trim().isNotEmpty) {
          return val.trim();
        }
        if (val is Map) {
          for (final subKey in mapSubKeys) {
            final subVal = val[subKey];
            if (subVal != null && subVal is String && subVal.trim().isNotEmpty) {
              return subVal.trim();
            }
          }
        }
      }
    }

    for (final mKey in mapKeys) {
      final mapVal = data[mKey];
      if (mapVal != null && mapVal is Map) {
        for (final subKey in mapSubKeys) {
          final subVal = mapVal[subKey];
          if (subVal != null && subVal is String && subVal.trim().isNotEmpty) {
            return subVal.trim();
          }
        }
      }
    }

    return '';
  }

  String _formatDate(dynamic timestamp) {
    if (timestamp is Timestamp) {
      final d = timestamp.toDate();
      const months = [
        'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
      ];
      return '${d.day.toString().padLeft(2, '0')} ${months[d.month - 1]} ${d.year}';
    } else if (timestamp is String && timestamp.isNotEmpty) {
      return timestamp;
    }
    final now = DateTime.now();
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${now.day.toString().padLeft(2, '0')} ${months[now.month - 1]} ${now.year}';
  }

  String _formatTime(dynamic timestamp) {
    if (timestamp is Timestamp) {
      final d = timestamp.toDate();
      final hour = d.hour > 12 ? d.hour - 12 : (d.hour == 0 ? 12 : d.hour);
      final minute = d.minute.toString().padLeft(2, '0');
      final period = d.hour >= 12 ? 'PM' : 'AM';
      return '$hour:$minute $period';
    } else if (timestamp is String && timestamp.isNotEmpty) {
      return timestamp;
    }
    final now = DateTime.now();
    final hour = now.hour > 12 ? now.hour - 12 : (now.hour == 0 ? 12 : now.hour);
    final minute = now.minute.toString().padLeft(2, '0');
    final period = now.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute $period';
  }

  double _parseDouble(dynamic val) {
    if (val is num) return val.toDouble();
    if (val is String) return double.tryParse(val) ?? 0.0;
    return 0.0;
  }

  Future<Map<String, dynamic>> _enrichRawOrder(String orderId, Map<String, dynamic> data) async {
    final firestore = _firestore ?? FirebaseFirestore.instance;
    final rawMap = _mapRawOrder(orderId, data);

    final sellerId = _parseField(
      data,
      ['sellerId', 'seller_id', 'vendorId', 'vendor_id', 'storeId', 'store_id', 'merchantId', 'merchant_id'],
      ['seller', 'restaurant', 'store', 'vendor', 'merchant'],
      ['id', 'uid', 'sellerId', 'vendorId', 'storeId'],
    );
    final customerId = _parseField(
      data,
      ['customerId', 'customer_id', 'userId', 'user_id', 'buyerId', 'buyer_id', 'customerUid', 'buyerUid', 'uid'],
      ['customer', 'user', 'buyer'],
      ['id', 'uid', 'customerId', 'userId', 'buyerId'],
    );

    String restaurantName = rawMap['restaurantName']?.toString() ?? '';
    String pickupAddress = rawMap['pickupAddress']?.toString() ?? '';
    String merchantPhone = rawMap['merchantPhone']?.toString() ?? '';
    double restLat = _parseDouble(data['sellerLatitude'] ?? data['restaurantLatitude'] ?? data['pickupLatitude']);
    double restLng = _parseDouble(data['sellerLongitude'] ?? data['restaurantLongitude'] ?? data['pickupLongitude']);

    if (sellerId.isNotEmpty) {
      if (!_sellerCache.containsKey(sellerId)) {
        try {
          final sDoc = await firestore.collection('sellers').doc(sellerId).get();
          if (sDoc.exists && sDoc.data() != null) {
            final sData = sDoc.data()!;
            final sShopName = sData['shopName'] ?? sData['name'] ?? sData['storeName'] ?? sData['businessDetails'] ?? 'Partner Store';
            final sAddr = sData['address'] ?? sData['businessDetails'] ?? sData['shopAddress'] ?? sData['deliveryArea'] ?? sData['location'] ?? '';
            final sPhone = sData['phoneNumber'] ?? sData['phone'] ?? sData['contactNumber'] ?? sData['merchantPhone'] ?? '';
            final sLat = _parseDouble(sData['latitude'] ?? sData['lat'] ?? sData['locationLat']);
            final sLng = _parseDouble(sData['longitude'] ?? sData['lng'] ?? sData['locationLng']);

            _sellerCache[sellerId] = {
              'shopName': sShopName,
              'address': sAddr.toString().trim() == sShopName.toString().trim() ? '' : sAddr,
              'phone': sPhone,
              'lat': sLat,
              'lng': sLng,
            };
          }
        } catch (_) {}
      }
      if (_sellerCache.containsKey(sellerId)) {
        final cached = _sellerCache[sellerId]!;
        restaurantName = cached['shopName']?.toString() ?? restaurantName;
        if (pickupAddress.isEmpty || pickupAddress == restaurantName || pickupAddress == sellerId) {
          pickupAddress = cached['address']?.toString() ?? '';
        }
        if (merchantPhone.isEmpty) {
          merchantPhone = cached['phone']?.toString() ?? merchantPhone;
        }
        if (restLat == 0.0) restLat = _parseDouble(cached['lat']);
        if (restLng == 0.0) restLng = _parseDouble(cached['lng']);
      }
    }

    String customerName = rawMap['customerName']?.toString() ?? '';
    String dropoffAddress = rawMap['dropoffAddress']?.toString() ?? '';
    String customerPhone = rawMap['customerPhone']?.toString() ?? '';
    double custLat = _parseDouble(data['customerLatitude'] ?? data['userLatitude'] ?? data['dropoffLatitude']);
    double custLng = _parseDouble(data['customerLongitude'] ?? data['userLongitude'] ?? data['dropoffLongitude']);

    final orderDeliveryAddress = data['deliveryAddress'] as String?;

    if (customerId.isNotEmpty) {
      if (!_userCache.containsKey(customerId)) {
        try {
          final uDoc = await firestore.collection('buyer_user').doc(customerId).get();
          if (uDoc.exists && uDoc.data() != null) {
            final uData = uDoc.data()!;
            final uName = uData['name'] ?? uData['displayName'] ?? uData['fullName'] ?? uData['userName'] ?? uData['buyerName'] ?? uData['customerName'] ?? 'Customer';
            final uPhone = uData['phone'] ?? uData['phoneNumber'] ?? uData['mobile'] ?? uData['userPhone'] ?? uData['contactNumber'] ?? '';
            final uLat = _parseDouble(uData['latitude'] ?? uData['lat']);
            final uLng = _parseDouble(uData['longitude'] ?? uData['lng']);

            String uAddr = '';
            for (final k in ['address', 'primaryAddress', 'homeAddress', 'workAddress', 'deliveryAddress', 'shippingAddress']) {
              final val = uData[k];
              if (val != null) {
                if (val is String && val.trim().isNotEmpty && val.trim() != 'Primary Address') {
                  uAddr = val.trim();
                  break;
                } else if (val is Map) {
                  final sub = val['address'] ?? val['fullAddress'] ?? val['street'] ?? val['formattedAddress'] ?? val['displayAddress'];
                  if (sub != null && sub.toString().trim().isNotEmpty && sub.toString().trim() != 'Primary Address') {
                    uAddr = sub.toString().trim();
                    break;
                  }
                }
              }
            }
            if (uAddr.isEmpty && uData['addresses'] is List && (uData['addresses'] as List).isNotEmpty) {
              final first = (uData['addresses'] as List).first;
              if (first is Map) {
                final sub = first['address'] ?? first['fullAddress'] ?? first['street'] ?? first['formattedAddress'];
                if (sub != null && sub.toString().trim().isNotEmpty && sub.toString().trim() != 'Primary Address') {
                  uAddr = sub.toString().trim();
                }
              } else if (first is String && first.trim().isNotEmpty && first.trim() != 'Primary Address') {
                uAddr = first.trim();
              }
            }

            _userCache[customerId] = {
              'name': uName,
              'phone': uPhone,
              'address': uAddr,
              'lat': uLat,
              'lng': uLng,
            };
          }
        } catch (_) {}
      }
      if (_userCache.containsKey(customerId)) {
        final cached = _userCache[customerId]!;
        final cName = cached['name']?.toString() ?? '';
        final cPhone = cached['phone']?.toString() ?? '';
        final cAddr = cached['address']?.toString() ?? '';

        if (customerName.isEmpty || customerName == 'Customer' || _isRawUid(customerName) || customerName == customerId) {
          if (cName.isNotEmpty && cName != 'Customer') {
            customerName = cName;
          }
        }
        if (customerPhone.isEmpty && cPhone.isNotEmpty) {
          customerPhone = cPhone;
        }
        if (dropoffAddress.isEmpty || dropoffAddress == 'Primary Address') {
          if (cAddr.isNotEmpty && cAddr != 'Primary Address') {
            dropoffAddress = cAddr;
          }
        }
        if (custLat == 0.0) custLat = _parseDouble(cached['lat']);
        if (custLng == 0.0) custLng = _parseDouble(cached['lng']);
      }
    }

    if (orderDeliveryAddress != null && orderDeliveryAddress.trim().isNotEmpty && orderDeliveryAddress.trim() != 'Primary Address') {
      dropoffAddress = orderDeliveryAddress.trim();
    }

    if (pickupAddress.trim() == restaurantName.trim()) {
      pickupAddress = '';
    }
    if (dropoffAddress.trim() == customerName.trim() || dropoffAddress.trim() == 'Primary Address') {
      dropoffAddress = '';
    }

    if (customerName.isEmpty || customerName == 'Customer') {
      customerName = 'Customer';
    }

    rawMap['sellerId'] = sellerId;
    rawMap['customerId'] = customerId;
    rawMap['restaurantName'] = restaurantName.isNotEmpty && !_isRawUid(restaurantName) ? restaurantName : 'Partner Store';
    rawMap['pickupAddress'] = pickupAddress;
    rawMap['merchantPhone'] = merchantPhone;
    rawMap['restaurantLatitude'] = restLat;
    rawMap['restaurantLongitude'] = restLng;

    rawMap['customerName'] = customerName;
    rawMap['dropoffAddress'] = dropoffAddress;
    rawMap['customerPhone'] = customerPhone;
    rawMap['customerLatitude'] = custLat;
    rawMap['customerLongitude'] = custLng;

    return rawMap;
  }

  @override
  Future<Map<String, dynamic>> fetchOrderDetailsData(String orderId) async {
    final firestore = _firestore ?? FirebaseFirestore.instance;
    try {
      final doc = await firestore.collection('orders').doc(orderId).get();
      if (doc.exists && doc.data() != null) {
        return await _enrichRawOrder(doc.id, doc.data()!);
      }
    } catch (_) {}

    if (_orderRepo != null) {
      try {
        final order = await _orderRepo.getOrderById(orderId);
        if (order != null) {
          return _enrichRawOrder(order.id, order.toMap());
        }
      } catch (_) {}
    }
    return {};
  }

  @override
  Stream<Map<String, dynamic>> watchOrderDetailsData(String orderId) {
    final firestore = _firestore ?? FirebaseFirestore.instance;
    return firestore
        .collection('orders')
        .doc(orderId)
        .snapshots()
        .asyncMap((snapshot) async {
      if (!snapshot.exists || snapshot.data() == null) return <String, dynamic>{};
      final data = snapshot.data()!;
      return await _enrichRawOrder(snapshot.id, data);
    }).handleError((e) => <String, dynamic>{});
  }

  Map<String, dynamic> _mapRawOrder(String orderId, Map<String, dynamic> data) {
    final items = (data['items'] as List<dynamic>? ?? const [])
        .asMap()
        .entries
        .map((entry) {
          final idx = entry.key;
          final e = entry.value;
          final map = e is Map<String, dynamic>
              ? e
              : (e is Map ? Map<String, dynamic>.from(e) : <String, dynamic>{});
          return {
            'id': map['id'] ?? 'item_$idx',
            'name': map['name'] ?? map['title'] ?? map['itemName'] ?? '',
            'quantity': (map['quantity'] as num?)?.toInt() ?? 1,
            'price': (map['price'] as num?)?.toDouble() ?? 0.0,
            'isVerified': map['isVerified'] == true,
            'notes': map['notes'] ?? map['customization'] ?? '',
          };
        })
        .toList();

    final customerName = _parseField(
      data,
      ['customerName', 'customer_name', 'userName', 'user_name', 'buyerName', 'buyer_name', 'name'],
      ['customer', 'user', 'buyer', 'deliveryAddress', 'address'],
      ['name', 'displayName', 'fullName', 'customerName', 'contactName'],
    );

    final pickupAddress = _parseField(
      data,
      ['pickupAddress', 'sellerAddress', 'restaurantAddress', 'storeAddress', 'merchantAddress'],
      ['seller', 'restaurant', 'store', 'vendor', 'merchant', 'pickupAddress'],
      ['address', 'fullAddress', 'street', 'businessDetails', 'shopAddress', 'location'],
    );

    final dropoffAddress = _parseField(
      data,
      ['deliveryAddress', 'userAddress', 'address', 'dropoffAddress', 'shippingAddress', 'destinationAddress'],
      ['deliveryAddress', 'address', 'dropoffAddress', 'customer', 'user', 'buyer'],
      ['address', 'fullAddress', 'street', 'formattedAddress', 'displayAddress', 'primaryAddress'],
    );

    final customerPhone = _parseField(
      data,
      ['customerPhone', 'customer_phone', 'userPhone', 'user_phone', 'phone', 'phoneNumber', 'mobile', 'contact', 'contactPhone'],
      ['customer', 'user', 'buyer', 'deliveryAddress', 'address'],
      ['phone', 'phoneNumber', 'mobile', 'contactPhone'],
    );

    final merchantPhone = _parseField(
      data,
      ['sellerPhone', 'merchantPhone', 'storePhone', 'restaurantPhone', 'phone'],
      ['seller', 'restaurant', 'store', 'vendor', 'merchant'],
      ['phone', 'phoneNumber', 'mobile', 'contactNumber'],
    );

    final restaurantName = _parseField(
      data,
      ['restaurantName', 'sellerName', 'shopName', 'storeName', 'merchantName', 'vendorName'],
      ['seller', 'restaurant', 'store', 'vendor', 'merchant'],
      ['name', 'shopName', 'storeName', 'displayName'],
    );

    final pickupInstructions = _parseField(
      data,
      ['pickupInstructions', 'pickupInstruction', 'sellerInstructions', 'restaurantInstructions'],
      ['pickup', 'restaurant', 'instructions'],
      ['instructions', 'note', 'pickupNote'],
    );

    final deliveryInstructions = _parseField(
      data,
      ['deliveryInstructions', 'deliveryInstruction', 'customerInstructions', 'dropoffInstructions', 'note'],
      ['delivery', 'dropoff', 'customer', 'instructions'],
      ['instructions', 'note', 'deliveryNote'],
    );

    final paymentMethod = data['paymentMethod'] ?? data['paymentType'] ?? data['paymentMode'] ?? 'Cash on Delivery';
    final paymentStatus = data['paymentStatus'] ?? (data['isPaid'] == true ? 'Paid' : 'Pending');

    final rawTimestamp = data['timestamp'] ?? data['createdAt'] ?? data['orderDate'];
    final orderDate = _formatDate(rawTimestamp);
    final orderTime = _formatTime(rawTimestamp);

    final totalAmount = (data['amount'] as num?)?.toDouble() ??
        (data['totalAmount'] as num?)?.toDouble() ??
        (data['totalPrice'] as num?)?.toDouble() ??
        0.0;

    final earnings = (data['deliveryFee'] as num?)?.toDouble() ??
        (data['partnerEarnings'] as num?)?.toDouble() ??
        (data['earnings'] as num?)?.toDouble() ??
        0.0;

    final pickupOtp = (data['pickupOtp'] ?? data['pickupCode'] ?? data['otp'] ?? '1234').toString();
    final isOtpVerified = data['isOtpVerified'] == true || data['pickupOtpVerified'] == true;

    final pickupStatus = data['pickupStatus'] ?? data['deliveryPartnerStatus'] ?? data['status'] ?? 'ASSIGNED';

    return {
      'orderId': orderId,
      'customerName': customerName,
      'restaurantName': restaurantName,
      'pickupAddress': pickupAddress,
      'dropoffAddress': dropoffAddress,
      'earnings': earnings,
      'distance': (data['distance'] as num?)?.toDouble() ?? 0.0,
      'status': data['status'] ?? 'pending',
      'customerPhone': customerPhone,
      'merchantPhone': merchantPhone,
      'orderValue': totalAmount,
      'totalAmount': totalAmount,
      'itemsCount': items.length,
      'orderDate': orderDate,
      'orderTime': orderTime,
      'paymentMethod': paymentMethod.toString(),
      'paymentStatus': paymentStatus.toString(),
      'pickupInstructions': pickupInstructions.isNotEmpty ? pickupInstructions : 'Collect sealed package at the dispatch counter.',
      'deliveryInstructions': deliveryInstructions.isNotEmpty ? deliveryInstructions : 'Please call customer before arriving.',
      'pickupOtp': pickupOtp,
      'isOtpVerified': isOtpVerified,
      'pickupStatus': pickupStatus.toString(),
      'codAmount': _parseDouble(data['codAmount'] ?? data['amount']),
      'isCodCollected': data['isCodCollected'] == true,
      'collectedAmount': _parseDouble(data['collectedAmount']),
      'codReconciliationStatus': (data['codReconciliationStatus'] ?? '').toString(),
      'items': items,
    };
  }

  @override
  Future<bool> updateOrderStatusRemote(String orderId, String status) async {
    final firestore = _firestore ?? FirebaseFirestore.instance;
    try {
      await firestore.collection('orders').doc(orderId).update({
        'status': status,
        'deliveryPartnerStatus': status,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      if (_orderRepo != null) {
        try {
          final newStatus = OrderStatus.fromString(status);
          await _orderRepo.updateOrderStatus(orderId, newStatus);
        } catch (_) {}
      }
      return true;
    } catch (_) {
      return false;
    }
  }

  @override
  Future<bool> markGoingToRestaurant(String orderId) async {
    final firestore = _firestore ?? FirebaseFirestore.instance;
    try {
      final nowIso = DateTime.now().toIso8601String();
      await firestore.collection('orders').doc(orderId).update({
        'pickupStatus': 'GOING_TO_RESTAURANT',
        'deliveryPartnerStatus': 'GOING_TO_RESTAURANT',
        'goingToRestaurantAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'statusHistory': FieldValue.arrayUnion([
          {
            'status': 'GOING_TO_RESTAURANT',
            'timestamp': nowIso,
            'notes': 'Delivery Partner is heading to restaurant.',
          }
        ]),
      });
      return true;
    } catch (_) {
      return false;
    }
  }

  @override
  Future<bool> markArrivedAtRestaurant(String orderId) async {
    final firestore = _firestore ?? FirebaseFirestore.instance;
    try {
      final nowIso = DateTime.now().toIso8601String();
      await firestore.collection('orders').doc(orderId).update({
        'pickupStatus': 'ARRIVED_AT_RESTAURANT',
        'deliveryPartnerStatus': 'ARRIVED_AT_RESTAURANT',
        'arrivedAtStoreAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'statusHistory': FieldValue.arrayUnion([
          {
            'status': 'ARRIVED_AT_RESTAURANT',
            'timestamp': nowIso,
            'notes': 'Delivery Partner arrived at restaurant.',
          }
        ]),
      });
      return true;
    } catch (_) {
      return false;
    }
  }

  @override
  Future<bool> verifyPickupOtp(String orderId, String otp) async {
    final firestore = _firestore ?? FirebaseFirestore.instance;
    try {
      final doc = await firestore.collection('orders').doc(orderId).get();
      if (doc.exists && doc.data() != null) {
        final data = doc.data()!;
        final validOtp = (data['pickupOtp'] ?? data['pickupCode'] ?? data['otp'] ?? '1234').toString().trim();
        if (validOtp.isEmpty || validOtp == otp.trim()) {
          await firestore.collection('orders').doc(orderId).update({
            'isOtpVerified': true,
            'pickupOtpVerified': true,
            'otpVerifiedAt': FieldValue.serverTimestamp(),
            'updatedAt': FieldValue.serverTimestamp(),
          });
          return true;
        }
      } else if (otp.trim() == '1234' || otp.trim().length >= 4) {
        return true;
      }
    } catch (_) {
      if (otp.trim() == '1234' || otp.trim().length >= 4) return true;
    }
    return false;
  }

  @override
  Future<bool> confirmPickup(String orderId) async {
    final firestore = _firestore ?? FirebaseFirestore.instance;
    try {
      final nowIso = DateTime.now().toIso8601String();
      await firestore.collection('orders').doc(orderId).update({
        'status': 'OutForDelivery',
        'pickupStatus': 'PICKED_UP',
        'deliveryPartnerStatus': 'PICKED_UP',
        'deliveryStatus': 'picked_up',
        'isOtpVerified': true,
        'pickedUpAt': FieldValue.serverTimestamp(),
        'outForDeliveryAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'statusHistory': FieldValue.arrayUnion([
          {
            'status': 'PICKED_UP',
            'timestamp': nowIso,
            'notes': 'Order picked up from restaurant and out for delivery.',
          }
        ]),
      });
      if (_orderRepo != null) {
        try {
          await _orderRepo.updateOrderStatus(orderId, OrderStatus.outForDelivery);
        } catch (_) {}
      }
      return true;
    } catch (_) {
      return false;
    }
  }

  @override
  Future<Map<String, dynamic>> collectCodCash(
    String orderId, {
    required double amountReceived,
  }) async {
    final firestore = _firestore ?? FirebaseFirestore.instance;
    try {
      final doc = await firestore.collection('orders').doc(orderId).get();
      final codAmount = doc.exists && doc.data() != null
          ? _parseDouble(doc.data()!['codAmount'] ?? doc.data()!['amount'])
          : 0.0;
      if (amountReceived < codAmount) {
        return {
          'success': false,
          'changeAmount': 0.0,
          'message': 'Received amount is less than the COD amount to collect.',
        };
      }
      final change = amountReceived - codAmount;
      final batch = firestore.batch();
      batch.update(firestore.collection('orders').doc(orderId), {
        'paymentStatus': 'COLLECTED',
        'isCodCollected': true,
        'collectedAmount': codAmount,
        'codCollectedAt': FieldValue.serverTimestamp(),
        'codReconciliationStatus': 'pending_submission',
        'updatedAt': FieldValue.serverTimestamp(),
      });
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid != null && uid.isNotEmpty) {
        batch.set(
          firestore.collection('delivery_partners').doc(uid),
          {
            'cashInHand': FieldValue.increment(codAmount),
            'cashCollected': FieldValue.increment(codAmount),
            'reconciliationStatus': 'pending_submission',
            'updatedAt': FieldValue.serverTimestamp(),
          },
          SetOptions(merge: true),
        );
      }
      await batch.commit();
      return {
        'success': true,
        'changeAmount': change,
        'collectedAmount': codAmount,
        'message': 'COD cash of \u{20B9}${codAmount.toStringAsFixed(2)} collected.',
      };
    } catch (e) {
      return {
        'success': false,
        'changeAmount': 0.0,
        'message': e.toString(),
      };
    }
  }

  @override
  Future<Map<String, dynamic>> cancelOrderWithReason(
    String orderId, {
    required String reason,
    String? notes,
    bool isFailedDelivery = false,
  }) async {
    final firestore = _firestore ?? FirebaseFirestore.instance;
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      final targetStatus = isFailedDelivery ? 'FailedDelivery' : 'Cancelled';
      final payload = <String, dynamic>{
        'status': targetStatus,
        'cancellationReason': reason,
        'cancellationNotes': notes ?? '',
        'cancelledBy': uid ?? '',
        'cancelledByRole': 'delivery_partner',
        'cancelledAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      };
      if (reason == 'Restaurant Closed' ||
          reason == 'Customer Unavailable' ||
          reason == 'Wrong Address') {
        payload['cancellationCompensation'] = 25.0;
        payload['isRiderCompensationEligible'] = true;
      }
      await firestore.collection('orders').doc(orderId).update(payload);
      return {
        'success': true,
        'status': targetStatus,
        'reason': reason,
        'message': 'Order successfully marked as $targetStatus.',
      };
    } catch (e) {
      return {
        'success': false,
        'message': e.toString(),
      };
    }
  }
}

