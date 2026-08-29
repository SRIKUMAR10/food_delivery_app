import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:rxdart/rxdart.dart';
import 'Delivery_Order History_page_state.dart';
import '../../../core/utils/app_date_formatter.dart';

abstract class DeliveryOrderHistoryServiceBase {
  Future<Map<String, dynamic>> fetchOrderHistoryData();
  Stream<Map<String, dynamic>> watchOrderHistoryData();
  List<DeliveryOrderHistoryModel> filterOrderHistory({
    required List<DeliveryOrderHistoryModel> orders,
    required String query,
    DeliveryOrderHistoryStatusFilter statusFilter =
        DeliveryOrderHistoryStatusFilter.all,
    DeliveryOrderHistoryPaymentFilter paymentFilter =
        DeliveryOrderHistoryPaymentFilter.all,
    int? startEpoch,
    int? endEpoch,
  });
  ({List<DeliveryOrderHistoryModel> items, int totalPages}) paginate({
    required List<DeliveryOrderHistoryModel> orders,
    required int page,
    required int pageSize,
  });
  DeliveryOrderHistoryStats computeStats(
    List<DeliveryOrderHistoryModel> orders,
  );
  String formatCurrency(double amount, String localeCode);
  String formatDistance(double distanceKm);
  Map<String, String> getEnvironmentVariables();
  Future<bool> requestNotificationPermission();
  Future<bool> requestLocationPermission();
}

class DeliveryOrderHistoryService
    implements DeliveryOrderHistoryServiceBase {
  static const Map<String, String> _environment = {
    'BASE_URL': 'https://api.fooddelivery.example',
    'ORDERS_HISTORY_URL':
        'https://api.fooddelivery.example/v1/delivery/orders/history',
    'WS_URL': 'wss://socket.fooddelivery.example',
  };

  final FirebaseFirestore? _firestore;
  final FirebaseAuth? _auth;

  DeliveryOrderHistoryService({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  @override
  Future<Map<String, dynamic>> fetchOrderHistoryData() async {
    try {
      final uid = _auth?.currentUser?.uid;
      if (uid != null && _firestore != null) {
        final Map<String, QueryDocumentSnapshot<Map<String, dynamic>>> docMap = {};

        try {
          final q1 = await _firestore!.collection('orders').where('riderId', isEqualTo: uid).get();
          for (var doc in q1.docs) {
            docMap[doc.id] = doc;
          }
        } catch (_) {}

        try {
          final q2 = await _firestore!.collection('orders').where('deliveryPartnerId', isEqualTo: uid).get();
          for (var doc in q2.docs) {
            docMap[doc.id] = doc;
          }
        } catch (_) {}

        try {
          final q3 = await _firestore!.collection('orders').where('driverId', isEqualTo: uid).get();
          for (var doc in q3.docs) {
            docMap[doc.id] = doc;
          }
        } catch (_) {}

        if (docMap.isNotEmpty) {
          final docs = docMap.values.toList();
          docs.sort((a, b) {
            final aTs = a.data()['timestamp'] as Timestamp?;
            final bTs = b.data()['timestamp'] as Timestamp?;
            if (aTs == null && bTs == null) return 0;
            if (aTs == null) return 1;
            if (bTs == null) return -1;
            return bTs.compareTo(aTs);
          });
          return await _buildHistoryData(docs);
        }
      }
    } catch (e) {
      debugPrint('fetchOrderHistoryData error: $e');
    }

    return _emptyHistoryData();
  }

  @override
  Stream<Map<String, dynamic>> watchOrderHistoryData() {
    final currentFirestore =
        _firestore ??
        (FirebaseAuth.instance.app != null
            ? FirebaseFirestore.instance
            : null);
    final currentAuth =
        _auth ??
        (FirebaseAuth.instance.app != null ? FirebaseAuth.instance : null);
    final uid = currentAuth?.currentUser?.uid;

    if (uid == null || uid.isEmpty || currentFirestore == null) {
      return Stream.value(_emptyHistoryData());
    }

    final Stream<QuerySnapshot<Map<String, dynamic>>?> s1 = currentFirestore
        .collection('orders')
        .where('riderId', isEqualTo: uid)
        .snapshots()
        .map<QuerySnapshot<Map<String, dynamic>>?>((s) => s)
        .onErrorReturnWith((e, st) => null);

    final Stream<QuerySnapshot<Map<String, dynamic>>?> s2 = currentFirestore
        .collection('orders')
        .where('deliveryPartnerId', isEqualTo: uid)
        .snapshots()
        .map<QuerySnapshot<Map<String, dynamic>>?>((s) => s)
        .onErrorReturnWith((e, st) => null);

    final Stream<QuerySnapshot<Map<String, dynamic>>?> s3 = currentFirestore
        .collection('orders')
        .where('driverId', isEqualTo: uid)
        .snapshots()
        .map<QuerySnapshot<Map<String, dynamic>>?>((s) => s)
        .onErrorReturnWith((e, st) => null);

    return Rx.combineLatest3<
      QuerySnapshot<Map<String, dynamic>>?,
      QuerySnapshot<Map<String, dynamic>>?,
      QuerySnapshot<Map<String, dynamic>>?,
      List<QueryDocumentSnapshot<Map<String, dynamic>>>
    >(s1, s2, s3, (snap1, snap2, snap3) {
      final Map<String, QueryDocumentSnapshot<Map<String, dynamic>>> docMap =
          {};

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
          docMap[doc.id] = doc;
        }
      }

      final targetDocs = docMap.values.toList();

      targetDocs.sort((a, b) {
        final aTs = a.data()['timestamp'] as Timestamp?;
        final bTs = b.data()['timestamp'] as Timestamp?;
        if (aTs == null && bTs == null) return 0;
        if (aTs == null) return 1;
        if (bTs == null) return -1;
        return bTs.compareTo(aTs);
      });

      return targetDocs;
    }).asyncMap((targetDocs) async {
      return await _buildHistoryData(targetDocs);
    }).onErrorReturnWith((error, stackTrace) {
      debugPrint('watchOrderHistoryData stream error: $error');
      return _emptyHistoryData();
    });
  }

  static final Map<String, Map<String, dynamic>> _sellerCache = {};
  static final Map<String, Map<String, dynamic>> _userCache = {};

  bool _isRawUid(String? text) {
    if (text == null || text.trim().isEmpty) return false;
    final trimmed = text.trim();
    return trimmed.length >= 20 && !trimmed.contains(' ');
  }

  Future<Map<String, dynamic>> _enrichFirestoreOrder(
    String docId,
    Map<String, dynamic> data,
  ) async {
    final currentFirestore = _firestore ?? FirebaseFirestore.instance;

    final sellerId = (data['sellerId'] ??
            data['seller_id'] ??
            data['vendorId'] ??
            data['vendor_id'] ??
            data['storeId'] ??
            data['store_id'] ??
            data['merchantId'] ??
            data['merchant_id'])
        ?.toString();

    final customerId = (data['customerId'] ??
            data['customer_id'] ??
            data['userId'] ??
            data['user_id'] ??
            data['buyerId'] ??
            data['buyer_id'] ??
            data['customerUid'] ??
            data['buyerUid'] ??
            data['uid'])
        ?.toString();

    String restaurantName = (data['restaurantName'] ??
            data['sellerName'] ??
            data['shopName'] ??
            data['storeName'])
        ?.toString() ??
        '';

    String pickupAddress = (data['pickupAddress'] ??
            data['sellerAddress'] ??
            data['restaurantAddress'] ??
            data['storeAddress'])
        ?.toString() ??
        '';

    String merchantPhone = (data['sellerPhone'] ??
            data['merchantPhone'] ??
            data['storePhone'])
        ?.toString() ??
        '';

    if ((restaurantName.isEmpty ||
            _isRawUid(restaurantName) ||
            restaurantName == sellerId) &&
        sellerId != null &&
        sellerId.isNotEmpty) {
      if (!_sellerCache.containsKey(sellerId)) {
        try {
          final sDoc =
              await currentFirestore.collection('sellers').doc(sellerId).get();
          if (sDoc.exists && sDoc.data() != null) {
            final sData = sDoc.data()!;
            final sShopName = sData['shopName'] ??
                sData['name'] ??
                sData['storeName'] ??
                sData['businessDetails'] ??
                '';
            final sAddr = sData['address'] ??
                sData['businessDetails'] ??
                sData['shopAddress'] ??
                sData['deliveryArea'] ??
                sData['location'] ??
                '';
            final sPhone = sData['phoneNumber'] ??
                sData['phone'] ??
                sData['contactNumber'] ??
                sData['merchantPhone'] ??
                '';
            _sellerCache[sellerId] = {
              'shopName': sShopName,
              'address':
                  sAddr.toString().trim() == sShopName.toString().trim()
                      ? ''
                      : sAddr,
              'phone': sPhone,
            };
          }
        } catch (e) {
          debugPrint('Error looking up seller $sellerId: $e');
        }
      }
      if (_sellerCache.containsKey(sellerId)) {
        final cached = _sellerCache[sellerId]!;
        final cShopName = cached['shopName']?.toString() ?? '';
        if (cShopName.isNotEmpty) {
          restaurantName = cShopName;
        }
        if (pickupAddress.isEmpty ||
            pickupAddress == restaurantName ||
            pickupAddress == sellerId) {
          pickupAddress = cached['address']?.toString() ?? '';
        }
        if (merchantPhone.isEmpty) {
          merchantPhone = cached['phone']?.toString() ?? '';
        }
      }
    }

    String _extractStringOrMap(Map<String, dynamic> source,
        List<String> stringKeys, List<String> subKeys) {
      for (final key in stringKeys) {
        final val = source[key];
        if (val != null) {
          if (val is String && val.trim().isNotEmpty) {
            return val.trim();
          }
          if (val is Map) {
            for (final subKey in subKeys) {
              final subVal = val[subKey];
              if (subVal != null &&
                  subVal is String &&
                  subVal.trim().isNotEmpty) {
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
      [
        'customerName',
        'userName',
        'user_name',
        'buyerName',
        'buyer_name',
        'name'
      ],
      ['name', 'displayName', 'fullName', 'customerName', 'userName'],
    );

    if (customerName.isEmpty || _isRawUid(customerName)) {
      customerName = _extractStringOrMap(
        data,
        ['customer', 'user', 'buyer'],
        ['name', 'displayName', 'fullName', 'customerName', 'userName'],
      );
    }

    String deliveryAddress = _extractStringOrMap(
      data,
      [
        'deliveryAddress',
        'userAddress',
        'address',
        'dropoffAddress',
        'shippingAddress',
        'primaryAddress',
        'destinationAddress'
      ],
      [
        'address',
        'fullAddress',
        'street',
        'formattedAddress',
        'displayAddress',
        'primaryAddress'
      ],
    );

    if (deliveryAddress.isEmpty || deliveryAddress == 'Primary Address') {
      deliveryAddress = _extractStringOrMap(
        data,
        ['customer', 'user', 'buyer', 'deliveryAddressDetails'],
        [
          'address',
          'fullAddress',
          'street',
          'formattedAddress',
          'displayAddress',
          'primaryAddress'
        ],
      );
    }

    String customerPhone = _extractStringOrMap(
      data,
      [
        'customerPhone',
        'phone',
        'userPhone',
        'phoneNumber',
        'mobile',
        'contact',
        'contactPhone',
        'contactNumber'
      ],
      ['phone', 'phoneNumber', 'mobile', 'contactNumber'],
    );

    if (customerPhone.isEmpty) {
      customerPhone = _extractStringOrMap(
        data,
        ['customer', 'user', 'buyer'],
        ['phone', 'phoneNumber', 'mobile', 'contactNumber'],
      );
    }

    if ((customerName.isEmpty ||
            customerName == 'Customer' ||
            _isRawUid(customerName) ||
            customerName == customerId ||
            deliveryAddress.isEmpty ||
            deliveryAddress == 'Primary Address' ||
            customerPhone.isEmpty) &&
        customerId != null &&
        customerId.isNotEmpty) {
      if (!_userCache.containsKey(customerId)) {
        try {
          final uDoc = await currentFirestore
              .collection('buyer_user')
              .doc(customerId)
              .get();
          if (uDoc.exists && uDoc.data() != null) {
            final uData = uDoc.data()!;
            final uName = uData['name'] ??
                uData['displayName'] ??
                uData['fullName'] ??
                uData['userName'] ??
                uData['buyerName'] ??
                uData['customerName'] ??
                '';
            final uPhone = uData['phone'] ??
                uData['phoneNumber'] ??
                uData['mobile'] ??
                uData['userPhone'] ??
                uData['contactNumber'] ??
                '';

            String uAddr = '';
            for (final k in [
              'address',
              'primaryAddress',
              'homeAddress',
              'workAddress',
              'deliveryAddress',
              'shippingAddress'
            ]) {
              final val = uData[k];
              if (val != null) {
                if (val is String &&
                    val.trim().isNotEmpty &&
                    val.trim() != 'Primary Address') {
                  uAddr = val.trim();
                  break;
                } else if (val is Map) {
                  final sub = val['address'] ??
                      val['fullAddress'] ??
                      val['street'] ??
                      val['formattedAddress'] ??
                      val['displayAddress'];
                  if (sub != null &&
                      sub.toString().trim().isNotEmpty &&
                      sub.toString().trim() != 'Primary Address') {
                    uAddr = sub.toString().trim();
                    break;
                  }
                }
              }
            }
            if (uAddr.isEmpty &&
                uData['addresses'] is List &&
                (uData['addresses'] as List).isNotEmpty) {
              final first = (uData['addresses'] as List).first;
              if (first is Map) {
                final sub = first['address'] ??
                    first['fullAddress'] ??
                    first['street'] ??
                    first['formattedAddress'];
                if (sub != null &&
                    sub.toString().trim().isNotEmpty &&
                    sub.toString().trim() != 'Primary Address') {
                  uAddr = sub.toString().trim();
                }
              } else if (first is String &&
                  first.trim().isNotEmpty &&
                  first.trim() != 'Primary Address') {
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

        if (customerName.isEmpty ||
            customerName == 'Customer' ||
            _isRawUid(customerName) ||
            customerName == customerId) {
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

    String fullPickupLabel = '';
    if (restaurantName.isNotEmpty && pickupAddress.isNotEmpty) {
      if (pickupAddress.contains(restaurantName)) {
        fullPickupLabel = pickupAddress;
      } else {
        fullPickupLabel = '$restaurantName \u2022 $pickupAddress';
      }
    } else if (restaurantName.isNotEmpty) {
      fullPickupLabel = restaurantName;
    } else if (pickupAddress.isNotEmpty) {
      fullPickupLabel = pickupAddress;
    }

    if (customerName.isEmpty || _isRawUid(customerName)) {
      customerName = 'Customer';
    }

    final ts = data['timestamp'] as Timestamp? ??
        data['createdAt'] as Timestamp? ??
        data['created_at'] as Timestamp?;
    final date = ts?.toDate() ?? DateTime.now();

    double distanceKm = (data['distance'] as num?)?.toDouble() ??
        (data['distanceKm'] as num?)?.toDouble() ??
        (data['distance_km'] as num?)?.toDouble() ??
        (data['totalDistance'] as num?)?.toDouble() ??
        0.0;
    if (distanceKm == 0.0 && data['distance'] is String) {
      distanceKm = double.tryParse(data['distance'] as String) ?? 0.0;
    }

    double amount = (data['amount'] as num?)?.toDouble() ??
        (data['totalAmount'] as num?)?.toDouble() ??
        (data['totalPrice'] as num?)?.toDouble() ??
        (data['price'] as num?)?.toDouble() ??
        0.0;

    final orderId = (data['orderId'] ??
            data['order_id'] ??
            data['displayId'] ??
            data['orderNumber'] ??
            docId)
        .toString();

    return {
      'orderId': orderId,
      'customerName': customerName,
      'phoneNumber': customerPhone,
      'pickupAddress': fullPickupLabel,
      'dropAddress': deliveryAddress,
      'dateLabel': _formatDate(date),
      'epochSeconds': date.millisecondsSinceEpoch ~/ 1000,
      'distanceKm': distanceKm,
      'amount': amount,
      'status': data['status'] ?? 'pending',
      'paymentType': data['paymentMethod'] ?? data['paymentType'] ?? 'COD',
    };
  }

  Future<Map<String, dynamic>> _buildHistoryData(
    List<QueryDocumentSnapshot<Map<String, dynamic>>> docs,
  ) async {
    final orders = await Future.wait(
      docs.map((doc) => _enrichFirestoreOrder(doc.id, doc.data())),
    );

    final completed = orders.where((o) {
      final s = o['status'].toString().toLowerCase();
      return s == 'delivered' || s == 'completed';
    }).length;
    final cancelled = orders.where((o) {
      final s = o['status'].toString().toLowerCase();
      return s == 'cancelled' || s == 'rejected';
    }).length;
    final pending = orders.length - completed - cancelled;
    final totalEarnings = orders.fold<double>(0.0, (sum, o) => sum + (o['amount'] as double));

    return {
      'orders': orders,
      'stats': {
        'totalOrders': orders.length,
        'completed': completed,
        'cancelled': cancelled,
        'pending': pending,
        'totalEarnings': totalEarnings,
        'totalOrdersDelta': 0.0,
        'earningsDelta': 0.0,
      },
    };
  }

  Map<String, dynamic> _emptyHistoryData() {
    return {
      'orders': const <Map<String, dynamic>>[],
      'stats': const {
        'totalOrders': 0,
        'completed': 0,
        'cancelled': 0,
        'pending': 0,
        'totalEarnings': 0.0,
        'totalOrdersDelta': 0.0,
        'earningsDelta': 0.0,
      },
    };
  }

  String _formatDate(DateTime date) {
    return AppDateFormatter.formatDisplayDateTime(date);
  }

  @override
  List<DeliveryOrderHistoryModel> filterOrderHistory({
    required List<DeliveryOrderHistoryModel> orders,
    required String query,
    DeliveryOrderHistoryStatusFilter statusFilter =
        DeliveryOrderHistoryStatusFilter.all,
    DeliveryOrderHistoryPaymentFilter paymentFilter =
        DeliveryOrderHistoryPaymentFilter.all,
    int? startEpoch,
    int? endEpoch,
  }) {
    List<DeliveryOrderHistoryModel> result = orders;

    switch (statusFilter) {
      case DeliveryOrderHistoryStatusFilter.all:
        break;
      case DeliveryOrderHistoryStatusFilter.completed:
        result = result
            .where((o) => o.status == DeliveryOrderHistoryStatus.completed)
            .toList();
      case DeliveryOrderHistoryStatusFilter.pending:
        result = result
            .where((o) => o.status == DeliveryOrderHistoryStatus.pending)
            .toList();
      case DeliveryOrderHistoryStatusFilter.cancelled:
        result = result
            .where((o) => o.status == DeliveryOrderHistoryStatus.cancelled)
            .toList();
    }

    switch (paymentFilter) {
      case DeliveryOrderHistoryPaymentFilter.all:
        break;
      case DeliveryOrderHistoryPaymentFilter.cod:
        result = result
            .where((o) => o.paymentType.toUpperCase() == 'COD')
            .toList();
      case DeliveryOrderHistoryPaymentFilter.online:
        result = result
            .where((o) => o.paymentType.toUpperCase() == 'ONLINE')
            .toList();
    }

    if (startEpoch != null) {
      result = result.where((o) => o.epochSeconds >= startEpoch).toList();
    }
    if (endEpoch != null) {
      result = result.where((o) => o.epochSeconds <= endEpoch).toList();
    }

    final trimmed = query.trim().toLowerCase();
    if (trimmed.isNotEmpty) {
      result = result.where((o) {
        return o.orderId.toLowerCase().contains(trimmed) ||
            o.customerName.toLowerCase().contains(trimmed) ||
            o.phoneNumber.toLowerCase().contains(trimmed) ||
            o.pickupAddress.toLowerCase().contains(trimmed) ||
            o.dropAddress.toLowerCase().contains(trimmed);
      }).toList();
    }

    return result;
  }

  @override
  ({List<DeliveryOrderHistoryModel> items, int totalPages}) paginate({
    required List<DeliveryOrderHistoryModel> orders,
    required int page,
    required int pageSize,
  }) {
    final int safePage = page < 1 ? 1 : page;
    final int safeSize = pageSize < 1 ? 1 : pageSize;
    final int totalPages =
        orders.isEmpty ? 1 : (orders.length / safeSize).ceil();
    final int clampedPage = safePage > totalPages ? totalPages : safePage;
    final int start = (clampedPage - 1) * safeSize;
    final int end = start + safeSize > orders.length
        ? orders.length
        : start + safeSize;
    final List<DeliveryOrderHistoryModel> items = start >= orders.length
        ? <DeliveryOrderHistoryModel>[]
        : orders.sublist(start, end);
    return (items: items, totalPages: totalPages);
  }

  @override
  DeliveryOrderHistoryStats computeStats(
    List<DeliveryOrderHistoryModel> orders,
  ) {
    final int completedCount = orders
        .where((o) => o.status == DeliveryOrderHistoryStatus.completed)
        .length;
    final int cancelledCount = orders
        .where((o) => o.status == DeliveryOrderHistoryStatus.cancelled)
        .length;
    final int pendingCount = orders.length - completedCount - cancelledCount;
    return DeliveryOrderHistoryStats(
      totalOrders: orders.length,
      completedCount: completedCount,
      cancelledCount: cancelledCount,
      pendingCount: pendingCount,
      totalEarnings: orders.fold<double>(0, (sum, o) => sum + o.amount),
    );
  }

  @override
  String formatCurrency(double amount, String localeCode) =>
      '\u{20B9}${amount.toStringAsFixed(2)}';

  @override
  String formatDistance(double distanceKm) =>
      '${distanceKm.toStringAsFixed(1)} km';

  @override
  Map<String, String> getEnvironmentVariables() =>
      Map<String, String>.unmodifiable(_environment);

  @override
  Future<bool> requestNotificationPermission() async => true;

  @override
  Future<bool> requestLocationPermission() async => true;
}
