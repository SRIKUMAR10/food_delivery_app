import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:food_delivery_app/core/models/order_status.dart';
import 'package:food_delivery_app/repositories/firebase_order_repository.dart';

abstract class DeliveryOrderDetailsServiceBase {
  Future<Map<String, dynamic>> fetchOrderDetailsData(String orderId);
  Stream<Map<String, dynamic>> watchOrderDetailsData(String orderId);
  Future<bool> updateOrderStatusRemote(String orderId, String status);
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

    if ((restaurantName.isEmpty || _isRawUid(restaurantName) || restaurantName == sellerId) && sellerId.isNotEmpty) {
      if (!_sellerCache.containsKey(sellerId)) {
        try {
          final sDoc = await firestore.collection('sellers').doc(sellerId).get();
          if (sDoc.exists && sDoc.data() != null) {
            final sData = sDoc.data()!;
            final sShopName = sData['shopName'] ?? sData['name'] ?? sData['storeName'] ?? sData['businessDetails'] ?? 'Partner Store';
            final sAddr = sData['address'] ?? sData['businessDetails'] ?? sData['shopAddress'] ?? sData['deliveryArea'] ?? sData['location'] ?? '';
            final sPhone = sData['phoneNumber'] ?? sData['phone'] ?? sData['contactNumber'] ?? sData['merchantPhone'] ?? '';
            _sellerCache[sellerId] = {
              'shopName': sShopName,
              'address': sAddr.toString().trim() == sShopName.toString().trim() ? '' : sAddr,
              'phone': sPhone,
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
      }
    }

    String customerName = rawMap['customerName']?.toString() ?? '';
    String dropoffAddress = rawMap['dropoffAddress']?.toString() ?? '';
    String customerPhone = rawMap['customerPhone']?.toString() ?? '';

    final orderDeliveryAddress = data['deliveryAddress'] as String?;

    if (customerId.isNotEmpty) {
      if (!_userCache.containsKey(customerId)) {
        try {
          final uDoc = await firestore.collection('buyer_user').doc(customerId).get();
          if (uDoc.exists && uDoc.data() != null) {
            final uData = uDoc.data()!;
            final uName = uData['name'] ?? uData['displayName'] ?? uData['fullName'] ?? uData['userName'] ?? uData['buyerName'] ?? uData['customerName'] ?? 'Customer';
            final uPhone = uData['phone'] ?? uData['phoneNumber'] ?? uData['mobile'] ?? uData['userPhone'] ?? uData['contactNumber'] ?? '';

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

    rawMap['restaurantName'] = restaurantName.isNotEmpty && !_isRawUid(restaurantName) ? restaurantName : 'Partner Store';
    rawMap['pickupAddress'] = pickupAddress;
    rawMap['merchantPhone'] = merchantPhone;
    rawMap['customerName'] = customerName;
    rawMap['dropoffAddress'] = dropoffAddress;
    rawMap['customerPhone'] = customerPhone;
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
        .map((e) {
          final map = e is Map<String, dynamic>
              ? e
              : (e is Map ? Map<String, dynamic>.from(e) : <String, dynamic>{});
          return {
            'name': map['name'] ?? map['title'] ?? map['itemName'] ?? '',
            'quantity': (map['quantity'] as num?)?.toInt() ?? 0,
            'price': (map['price'] as num?)?.toDouble() ?? 0.0,
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

    return {
      'orderId': orderId,
      'customerName': customerName,
      'restaurantName': restaurantName,
      'pickupAddress': pickupAddress,
      'dropoffAddress': dropoffAddress,
      'earnings': (data['deliveryFee'] as num?)?.toDouble() ?? 0.0,
      'distance': (data['distance'] as num?)?.toDouble() ?? 0.0,
      'status': data['status'] ?? 'pending',
      'customerPhone': customerPhone,
      'merchantPhone': merchantPhone,
      'orderValue': (data['amount'] as num?)?.toDouble() ??
          (data['totalAmount'] as num?)?.toDouble() ??
          (data['totalPrice'] as num?)?.toDouble() ??
          0.0,
      'items': items,
    };
  }

  @override
  Future<bool> updateOrderStatusRemote(String orderId, String status) async {
    if (_orderRepo != null) {
      try {
        final newStatus = OrderStatus.fromString(status);
        await _orderRepo.updateOrderStatus(orderId, newStatus);
        return true;
      } catch (_) {
        return false;
      }
    }
    return false;
  }
}
