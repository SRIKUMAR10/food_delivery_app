import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:rxdart/rxdart.dart';
import 'Delivery_Orders_page_state.dart';

abstract class DeliveryOrdersServiceBase {
  Future<Map<String, dynamic>> fetchOrdersData();
  Stream<Map<String, dynamic>> watchOrdersData();
  List<DeliveryOrderCardModel> filterOrders({
    required List<DeliveryOrderCardModel> orders,
    required DeliveryOrdersTab tab,
    required String query,
    DeliveryOrdersPaymentFilter paymentFilter = DeliveryOrdersPaymentFilter.all,
    DeliveryOrdersSort sortBy = DeliveryOrdersSort.time,
  });
  String formatCurrency(double amount, String localeCode);
  String formatDistance(double distance);
  double calculateEarnings(double orderAmount);
  double haversineDistanceKm(double lat1, double lon1, double lat2, double lon2);
  double calculateEstimatedEarnings(double distanceKm, {double peakBonus = 0.0});
  DeliveryOrderStatus? getNextStatus(DeliveryOrderStatus status);
  Map<String, String> getEnvironmentVariables();
  Future<bool> requestNotificationPermission();
  Future<bool> requestLocationPermission();
}

class DeliveryOrdersService implements DeliveryOrdersServiceBase {
  static const Map<String, String> _environment = {
    'BASE_URL': 'https://api.fooddelivery.example',
    'ORDERS_URL': 'https://api.fooddelivery.example/v1/delivery/orders',
    'WS_URL': 'wss://socket.fooddelivery.example',
  };

  static const double _earningRate = 0.18;
  static const double _baseEarningsRate = 30.0;
  static const double _perKmRate = 6.0;

  static const List<String> _availableStatuses = [
    'ready',
    'ready_for_pickup',
    'order_ready',
    'searching_driver',
    'pending',
    'new',
    'neworder',
    'confirmed',
    'preparing',
  ];

  final FirebaseFirestore? _firestore;
  final FirebaseAuth? _auth;

  DeliveryOrdersService({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  })  : _firestore = firestore,
        _auth = auth;

  @override
  Future<Map<String, dynamic>> fetchOrdersData() async {
    try {
      final currentFirestore = _firestore ?? FirebaseFirestore.instance;
      final currentAuth = _auth ?? FirebaseAuth.instance;
      final uid = currentAuth.currentUser?.uid;
      final Map<String, QueryDocumentSnapshot<Map<String, dynamic>>> docMap = {};
      
      if (uid != null && uid.isNotEmpty) {
        try {
          final q1 = await currentFirestore.collection('orders').where('riderId', isEqualTo: uid).get();
          for (var doc in q1.docs) {
            docMap[doc.id] = doc;
          }
        } catch (e) {
          debugPrint('fetchOrdersData riderId query fallback: $e');
        }

        try {
          final q2 = await currentFirestore.collection('orders').where('deliveryPartnerId', isEqualTo: uid).get();
          for (var doc in q2.docs) {
            docMap[doc.id] = doc;
          }
        } catch (e) {
          debugPrint('fetchOrdersData deliveryPartnerId query fallback: $e');
        }
      }

      if (docMap.isEmpty) {
        try {
          final q3 = await currentFirestore
              .collection('orders')
              .where('status', whereIn: _availableStatuses)
              .get();
          for (var doc in q3.docs) {
            docMap[doc.id] = doc;
          }
        } catch (e) {
          debugPrint('fetchOrdersData status query fallback: $e');
        }
      }

      final docs = docMap.values.toList();
      docs.sort((a, b) {
        final aTs = a.data()['timestamp'] as Timestamp?;
        final bTs = b.data()['timestamp'] as Timestamp?;
        if (aTs == null && bTs == null) return 0;
        if (aTs == null) return 1;
        if (bTs == null) return -1;
        return bTs.compareTo(aTs);
      });

      final orders = await Future.wait(
        docs.map((doc) => _enrichFirestoreOrder(doc.id, doc.data())),
      );
      return {'orders': orders};
    } catch (e) {
      debugPrint('fetchOrdersData error: $e');
    }

    return {'orders': const <Map<String, dynamic>>[]};
  }

  static final Map<String, Map<String, dynamic>> _sellerCache = {};
  static final Map<String, Map<String, dynamic>> _userCache = {};

  bool _isRawUid(String? text) {
    if (text == null || text.trim().isEmpty) return false;
    final trimmed = text.trim();
    return trimmed.length >= 20 && !trimmed.contains(' ');
  }

  Future<Map<String, dynamic>> _enrichFirestoreOrder(String docId, Map<String, dynamic> data) async {
    final currentFirestore = _firestore ?? FirebaseFirestore.instance;

    final sellerId = (data['sellerId'] ?? data['seller_id'] ?? data['vendorId'] ?? data['vendor_id'] ?? data['storeId'] ?? data['store_id'] ?? data['merchantId'] ?? data['merchant_id'])?.toString();
    final customerId = (data['customerId'] ?? data['customer_id'] ?? data['userId'] ?? data['user_id'] ?? data['buyerId'] ?? data['buyer_id'] ?? data['customerUid'] ?? data['buyerUid'] ?? data['uid'])?.toString();

    String restaurantName = (data['restaurantName'] ?? data['sellerName'] ?? data['shopName'] ?? data['storeName'])?.toString() ?? '';
    String pickupAddress = (data['pickupAddress'] ?? data['sellerAddress'] ?? data['restaurantAddress'] ?? data['storeAddress'])?.toString() ?? '';
    String merchantPhone = (data['sellerPhone'] ?? data['merchantPhone'] ?? data['storePhone'])?.toString() ?? '';

    if ((restaurantName.isEmpty || _isRawUid(restaurantName) || restaurantName == sellerId) && sellerId != null && sellerId.isNotEmpty) {
      if (!_sellerCache.containsKey(sellerId)) {
        try {
          final sDoc = await currentFirestore.collection('sellers').doc(sellerId).get();
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
        } catch (e) {
          debugPrint('Error looking up seller $sellerId: $e');
        }
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

    if (restaurantName.isEmpty || _isRawUid(restaurantName)) {
      restaurantName = 'Partner Store';
    }

    String _extractStringOrMap(Map<String, dynamic> source, List<String> stringKeys, List<String> subKeys) {
      for (final key in stringKeys) {
        final val = source[key];
        if (val != null) {
          if (val is String && val.trim().isNotEmpty) {
            return val.trim();
          }
          if (val is Map) {
            for (final subKey in subKeys) {
              final subVal = val[subKey];
              if (subVal != null && subVal is String && subVal.trim().isNotEmpty) {
                return subVal.trim();
              }
            }
          }
        }
      }
      return '';
    }

    String customerName = _extractStringOrMap(
      data,
      ['customerName', 'userName', 'user_name', 'buyerName', 'buyer_name', 'name'],
      ['name', 'displayName', 'fullName', 'customerName', 'userName'],
    );
    if (customerName.isEmpty) {
      customerName = _extractStringOrMap(
        data,
        ['customer', 'user', 'buyer'],
        ['name', 'displayName', 'fullName', 'customerName', 'userName'],
      );
    }

    String deliveryAddress = _extractStringOrMap(
      data,
      ['deliveryAddress', 'userAddress', 'address', 'dropoffAddress', 'shippingAddress', 'primaryAddress', 'destinationAddress'],
      ['address', 'fullAddress', 'street', 'formattedAddress', 'displayAddress', 'primaryAddress'],
    );
    if (deliveryAddress.isEmpty || deliveryAddress == 'Primary Address') {
      deliveryAddress = _extractStringOrMap(
        data,
        ['customer', 'user', 'buyer', 'deliveryAddressDetails'],
        ['address', 'fullAddress', 'street', 'formattedAddress', 'displayAddress', 'primaryAddress'],
      );
    }

    String customerPhone = _extractStringOrMap(
      data,
      ['customerPhone', 'phone', 'userPhone', 'phoneNumber', 'mobile', 'contact', 'contactPhone', 'contactNumber'],
      ['phone', 'phoneNumber', 'mobile', 'contactNumber'],
    );
    if (customerPhone.isEmpty) {
      customerPhone = _extractStringOrMap(
        data,
        ['customer', 'user', 'buyer'],
        ['phone', 'phoneNumber', 'mobile', 'contactNumber'],
      );
    }

    if ((customerName.isEmpty || customerName == 'Customer' || _isRawUid(customerName) || customerName == customerId || deliveryAddress.isEmpty || deliveryAddress == 'Primary Address' || customerPhone.isEmpty) && customerId != null && customerId.isNotEmpty) {
      if (!_userCache.containsKey(customerId)) {
        try {
          final uDoc = await currentFirestore.collection('buyer_user').doc(customerId).get();
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
        } catch (e) {
          // Graceful fallback if user profile doc is restricted by cloud security rules
        }
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
        if (deliveryAddress.isEmpty || deliveryAddress == 'Primary Address') {
          if (cAddr.isNotEmpty && cAddr != 'Primary Address') {
            deliveryAddress = cAddr;
          }
        }
      }
    }

    if ((customerName.isEmpty || customerName == 'Customer') && customerPhone.isNotEmpty) {
      try {
        final q = await currentFirestore.collection('buyer_user').where('phone', isEqualTo: customerPhone).limit(1).get();
        if (q.docs.isNotEmpty) {
          final uData = q.docs.first.data();
          customerName = uData['name'] ?? uData['displayName'] ?? uData['fullName'] ?? customerName;
          if (deliveryAddress.isEmpty || deliveryAddress == 'Primary Address') {
            deliveryAddress = uData['address'] ?? uData['homeAddress'] ?? uData['workAddress'] ?? uData['primaryAddress'] ?? deliveryAddress;
          }
        }
      } catch (_) {}
    }

    if (pickupAddress.trim() == restaurantName.trim()) {
      pickupAddress = '';
    }
    if (deliveryAddress.trim() == customerName.trim()) {
      deliveryAddress = '';
    }

    final rawOrderMap = _mapFirestoreOrder(docId, data);
    rawOrderMap['restaurantName'] = restaurantName;
    rawOrderMap['pickupAddress'] = pickupAddress;
    rawOrderMap['customerName'] = customerName.isNotEmpty && customerName != 'Customer' ? customerName : 'Customer';
    rawOrderMap['deliveryAddress'] = deliveryAddress;
    if (customerPhone.isNotEmpty) {
      rawOrderMap['phoneNumber'] = customerPhone;
    }
    return rawOrderMap;
  }

  @override
  Stream<Map<String, dynamic>> watchOrdersData() {
    final currentFirestore = _firestore ?? FirebaseFirestore.instance;
    final currentAuth = _auth ?? FirebaseAuth.instance;
    final uid = currentAuth.currentUser?.uid;

    final Stream<QuerySnapshot<Map<String, dynamic>>?> s1 = (uid != null && uid.isNotEmpty)
        ? currentFirestore
            .collection('orders')
            .where('riderId', isEqualTo: uid)
            .snapshots()
            .map<QuerySnapshot<Map<String, dynamic>>?>((s) => s)
            .onErrorReturnWith((e, st) {
              debugPrint('watchOrdersData riderId stream fallback: $e');
              return null;
            })
        : Stream.value(null);

    final Stream<QuerySnapshot<Map<String, dynamic>>?> s2 = (uid != null && uid.isNotEmpty)
        ? currentFirestore
            .collection('orders')
            .where('deliveryPartnerId', isEqualTo: uid)
            .snapshots()
            .map<QuerySnapshot<Map<String, dynamic>>?>((s) => s)
            .onErrorReturnWith((e, st) {
              debugPrint('watchOrdersData deliveryPartnerId stream fallback: $e');
              return null;
            })
        : Stream.value(null);

    final Stream<QuerySnapshot<Map<String, dynamic>>?> s3 = currentFirestore
        .collection('orders')
        .where('status', whereIn: _availableStatuses)
        .snapshots()
        .map<QuerySnapshot<Map<String, dynamic>>?>((s) => s)
        .onErrorReturnWith((e, st) {
          return null;
        });

    return Rx.combineLatest3<
        QuerySnapshot<Map<String, dynamic>>?,
        QuerySnapshot<Map<String, dynamic>>?,
        QuerySnapshot<Map<String, dynamic>>?,
        Map<String, dynamic>>(
      s1,
      s2,
      s3,
      (snap1, snap2, snap3) {
        final Map<String, QueryDocumentSnapshot<Map<String, dynamic>>> docMap = {};

        if (snap1 != null) {
          for (var doc in snap1.docs) {
            docMap[doc.id] = doc;
          }
        }
        if (snap2 != null) {
          for (var doc in snap2.docs) {
            docMap[doc.id] = doc;
          }
        }

        if (snap3 != null) {
          for (var doc in snap3.docs) {
            final data = doc.data();
            final assigned = data['riderId'] ?? data['deliveryPartnerId'] ?? data['driverId'];
            final isUnassigned = assigned == null || assigned.toString().trim().isEmpty;
            final rejectedBy = data['rejectedBy'];
            final wasRejectedByMe = rejectedBy is List &&
                uid != null &&
                uid.isNotEmpty &&
                rejectedBy.any((e) => e?.toString() == uid);
            if (isUnassigned && !wasRejectedByMe) {
              docMap[doc.id] = doc;
            }
          }
        }

        final docs = docMap.values.toList();
        docs.sort((a, b) {
          final aTs = a.data()['timestamp'] as Timestamp?;
          final bTs = b.data()['timestamp'] as Timestamp?;
          if (aTs == null && bTs == null) return 0;
          if (aTs == null) return 1;
          if (bTs == null) return -1;
          return bTs.compareTo(aTs);
        });

        final rawOrders = docs.map((doc) => {'id': doc.id, 'data': doc.data()}).toList();
        return {'_rawDocs': rawOrders};
      },
    ).asyncMap((map) async {
      final rawDocs = map['_rawDocs'] as List<Map<String, dynamic>>? ?? [];
      final enrichedOrders = await Future.wait(
        rawDocs.map((item) => _enrichFirestoreOrder(item['id'] as String, item['data'] as Map<String, dynamic>)),
      );
      return {'orders': enrichedOrders};
    }).onErrorReturnWith((error, stackTrace) {
      debugPrint('watchOrdersData stream error: $error');
      return {'orders': const <Map<String, dynamic>>[]};
    });
  }

  Map<String, dynamic> _mapFirestoreOrder(String docId, Map<String, dynamic> data) {
    final distance = (data['distance'] as num?)?.toDouble() ?? 0.0;
    final pickupDistance = (data['pickupDistance'] as num?)?.toDouble() ?? 0.0;
    final deliveryDistance =
        (data['deliveryDistance'] as num?)?.toDouble() ?? 0.0;
    final routeDistance = distance > 0
        ? distance
        : (pickupDistance + deliveryDistance);

    final sellerId = (data['sellerId'] ?? data['seller_id'] ?? data['vendorId'] ??
        data['storeId'] ?? data['store_id'] ?? data['merchantId'] ?? '')
        ?.toString() ?? '';
    final customerId = (data['customerId'] ?? data['customer_id'] ?? data['userId'] ??
        data['user_id'] ?? data['buyerId'] ?? data['buyer_id'] ?? '')
        ?.toString() ?? '';

    final rawStatus = data['status']?.toString() ?? 'pending';
    final assignmentStatus =
        (data['deliveryAssignmentStatus'] ?? data['assignmentStatus'] ?? '')
            ?.toString() ?? '';
    final isAvailable = assignmentStatus == 'available' ||
        _isAvailableStatus(rawStatus);

    final rejectedByRaw = data['rejectedBy'];
    final rejectedBy = rejectedByRaw is List
        ? rejectedByRaw.map((e) => e?.toString() ?? '').where((e) => e.isNotEmpty).toList()
        : <String>[];

    return {
      'orderId': docId,
      'customerName': data['customerName'] ?? data['userName'] ?? data['user_name'] ?? '',
      'restaurantName': data['restaurantName'] ?? data['sellerName'] ?? '',
      'pickupAddress': data['pickupAddress'] ?? data['sellerAddress'] ?? data['restaurantAddress'] ?? '',
      'deliveryAddress': data['deliveryAddress'] ?? data['userAddress'] ?? data['address'] ?? '',
      'amount': (data['amount'] as num?)?.toDouble() ?? (data['totalAmount'] as num?)?.toDouble() ?? (data['totalPrice'] as num?)?.toDouble() ?? 0.0,
      'itemsCount': (data['items'] as List?)?.length ?? (data['itemCount'] as num?)?.toInt() ?? 0,
      'status': _mapFirestoreStatus(rawStatus),
      'distance': routeDistance,
      'time': _formatTimestamp(data['timestamp'] ?? data['createdAt'] ?? data['created_at']),
      'paymentType': data['paymentMethod'] ?? data['paymentType'] ?? '',
      'phoneNumber': data['customerPhone'] ?? data['phone'] ?? data['userPhone'] ?? '',
      'etaMins': (data['etaMins'] as num?)?.toInt() ?? (data['estimatedDeliveryTime'] as num?)?.toInt() ?? 0,
      'lateMins': (data['lateMins'] as num?)?.toInt() ?? 0,
      'priority': data['priority'] ?? false,
      'restaurantRating': (data['restaurantRating'] as num?)?.toDouble() ?? 0.0,
      'expectedTip': (data['expectedTip'] as num?)?.toDouble() ?? (data['tip'] as num?)?.toDouble() ?? 0.0,
      'preparationTimeMins': (data['preparationTimeMins'] as num?)?.toInt() ?? 0,
      'deliveryBonus': (data['deliveryBonus'] as num?)?.toDouble() ?? 0.0,
      'restaurantLocation': data['restaurantLocation'] ?? data['pickupAddress'] ?? data['sellerAddress'] ?? data['restaurantAddress'] ?? '',
      'customerArea': data['customerArea'] ?? data['deliveryAddress'] ?? data['userAddress'] ?? data['address'] ?? '',
      'estimatedEarnings': _estimatedEarningsFromData(data, routeDistance),
      'pickupDistance': pickupDistance,
      'deliveryDistance': deliveryDistance,
      'sellerId': sellerId,
      'customerId': customerId,
      'assignedTime': _formatTimestamp(data['assignedAt'] ?? data['assignedTime']),
      'acceptedTime': _formatTimestamp(data['acceptedAt'] ?? data['acceptedTime']),
      'assignmentStatus': assignmentStatus,
      'rejectedBy': rejectedBy,
      'isAvailable': isAvailable,
    };
  }

  bool _isAvailableStatus(String status) {
    switch (status.toLowerCase()) {
      case 'ready':
      case 'ready_for_pickup':
      case 'order_ready':
      case 'searching_driver':
      case 'pending':
      case 'new':
      case 'neworder':
      case 'confirmed':
        return true;
      default:
        return false;
    }
  }

  double _estimatedEarningsFromData(Map<String, dynamic> data, double routeDistance) {
    final stored = data['estimatedEarnings'] ?? data['deliveryEarnings'];
    if (stored is num) return stored.toDouble();
    final peakBonus = (data['peakBonus'] as num?)?.toDouble() ?? 0.0;
    return calculateEstimatedEarnings(routeDistance, peakBonus: peakBonus);
  }

  String _mapFirestoreStatus(String status) {
    switch (status.toLowerCase()) {
      case 'accepted':
      case 'preparing':
      case 'ready':
      case 'ready_for_pickup':
      case 'outfordelivery':
      case 'active':
      case 'on_the_way':
      case 'in_progress':
      case 'picked_up':
        return 'active';
      case 'new':
      case 'neworder':
      case 'pending':
      case 'assigned':
      case 'searching_driver':
        return 'pending';
      case 'delivered':
      case 'completed':
        return 'completed';
      case 'cancelled':
        return 'cancelled';
      default:
        return 'pending';
    }
  }

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
  List<DeliveryOrderCardModel> filterOrders({
    required List<DeliveryOrderCardModel> orders,
    required DeliveryOrdersTab tab,
    required String query,
    DeliveryOrdersPaymentFilter paymentFilter = DeliveryOrdersPaymentFilter.all,
    DeliveryOrdersSort sortBy = DeliveryOrdersSort.time,
  }) {
    final List<DeliveryOrderCardModel> tabFiltered;
    switch (tab) {
      case DeliveryOrdersTab.active:
        tabFiltered = orders.where((o) => o.status == DeliveryOrderStatus.active).toList();
      case DeliveryOrdersTab.pending:
        tabFiltered = orders.where((o) => o.status == DeliveryOrderStatus.pending).toList();
      case DeliveryOrdersTab.completed:
        tabFiltered = orders.where((o) => o.status == DeliveryOrderStatus.completed).toList();
      case DeliveryOrdersTab.all:
        tabFiltered = List<DeliveryOrderCardModel>.of(orders);
    }

    final List<DeliveryOrderCardModel> paymentFiltered;
    switch (paymentFilter) {
      case DeliveryOrdersPaymentFilter.all:
        paymentFiltered = tabFiltered;
      case DeliveryOrdersPaymentFilter.cash:
        paymentFiltered = tabFiltered.where((o) => o.paymentType.toLowerCase() == 'cash').toList();
      case DeliveryOrdersPaymentFilter.card:
        paymentFiltered = tabFiltered.where((o) => o.paymentType.toLowerCase() == 'card').toList();
      case DeliveryOrdersPaymentFilter.online:
        paymentFiltered = tabFiltered.where((o) => o.paymentType.toLowerCase() == 'online').toList();
    }

    final trimmed = query.trim().toLowerCase();
    List<DeliveryOrderCardModel> queryFiltered;
    if (trimmed.isEmpty) {
      queryFiltered = paymentFiltered;
    } else {
      queryFiltered = paymentFiltered.where((o) {
        return o.orderId.toLowerCase().contains(trimmed) ||
            o.customerName.toLowerCase().contains(trimmed) ||
            o.restaurantName.toLowerCase().contains(trimmed) ||
            o.phoneNumber.toLowerCase().contains(trimmed);
      }).toList();
    }

    switch (sortBy) {
      case DeliveryOrdersSort.time:
        return queryFiltered;
      case DeliveryOrdersSort.distance:
        return List<DeliveryOrderCardModel>.of(queryFiltered)..sort((a, b) => a.distance.compareTo(b.distance));
      case DeliveryOrdersSort.amountHigh:
        return List<DeliveryOrderCardModel>.of(queryFiltered)..sort((a, b) => b.amount.compareTo(a.amount));
    }
  }

  @override
  String formatCurrency(double amount, String localeCode) => '\u{20B9}${amount.toStringAsFixed(2)}';

  @override
  String formatDistance(double distance) => '${distance.toStringAsFixed(1)} km';

  @override
  double calculateEarnings(double orderAmount) => orderAmount * _earningRate;

  @override
  double haversineDistanceKm(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    const earthRadiusKm = 6371.0;
    final dLat = _toRadians(lat2 - lat1);
    final dLon = _toRadians(lon2 - lon1);
    final a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(_toRadians(lat1)) *
            math.cos(_toRadians(lat2)) *
            math.sin(dLon / 2) *
            math.sin(dLon / 2);
    final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    return earthRadiusKm * c;
  }

  double _toRadians(double degrees) => degrees * math.pi / 180.0;

  @override
  double calculateEstimatedEarnings(double distanceKm, {double peakBonus = 0.0}) {
    return _baseEarningsRate + (distanceKm * _perKmRate) + peakBonus;
  }

  @override
  DeliveryOrderStatus? getNextStatus(DeliveryOrderStatus status) {
    switch (status) {
      case DeliveryOrderStatus.pending:
        return DeliveryOrderStatus.active;
      case DeliveryOrderStatus.active:
        return DeliveryOrderStatus.completed;
      default:
        return null;
    }
  }

  @override
  Map<String, String> getEnvironmentVariables() => Map<String, String>.unmodifiable(_environment);

  @override
  Future<bool> requestNotificationPermission() async => true;

  @override
  Future<bool> requestLocationPermission() async => true;
}
