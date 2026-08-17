import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SellerCustomerService {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  SellerCustomerService({FirebaseFirestore? firestore, FirebaseAuth? auth})
      : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  String? get currentSellerId => _auth.currentUser?.uid;

  /// Real-time stream of customer bundle & stats for the logged-in seller.
  Stream<Map<String, dynamic>> streamCustomerData({String? sellerId}) {
    final sId = sellerId ?? currentSellerId;
    if (sId == null || sId.isEmpty) {
      return Stream.value({
        'stats': {
          'totalCustomers': 0,
          'repeatCustomers': 0,
          'totalRevenue': 0.0,
          'averageOrderValue': 0.0,
        },
        'customers': <Map<String, dynamic>>[],
      });
    }

    return _firestore
        .collection('orders')
        .where('sellerId', isEqualTo: sId)
        .snapshots()
        .asyncMap((orderSnapshot) async {
      return await _processOrderSnapshot(orderSnapshot, sId);
    });
  }

  Future<Map<String, dynamic>> fetchCustomerStats({String? sellerId}) async {
    final sId = sellerId ?? currentSellerId;
    if (sId == null || sId.isEmpty) {
      return {
        'totalCustomers': 0,
        'repeatCustomers': 0,
        'totalRevenue': 0.0,
        'averageOrderValue': 0.0,
      };
    }

    try {
      final snapshot = await _firestore
          .collection('orders')
          .where('sellerId', isEqualTo: sId)
          .get();

      final customerCounts = <String, int>{};
      double totalRevenue = 0.0;
      int totalOrders = snapshot.docs.length;

      for (var doc in snapshot.docs) {
        final data = doc.data();
        final rawCustomerId =
            data['customerId'] ?? data['buyerId'] ?? data['userId'] ?? data['uid'];
        final customerId = (rawCustomerId != null && rawCustomerId.toString().isNotEmpty)
            ? rawCustomerId.toString()
            : 'unknown';
        customerCounts[customerId] = (customerCounts[customerId] ?? 0) + 1;

        final amount = (data['amount'] as num?)?.toDouble() ?? 0.0;
        totalRevenue += amount;
      }

      int totalCustomers = customerCounts.length;
      int repeatCustomers = customerCounts.values.where((count) => count > 1).length;
      double avgOrderValue = totalOrders > 0 ? (totalRevenue / totalOrders) : 0.0;

      return {
        'totalCustomers': totalCustomers,
        'repeatCustomers': repeatCustomers,
        'totalRevenue': totalRevenue,
        'averageOrderValue': avgOrderValue,
      };
    } catch (e) {
      debugPrint('SellerCustomerService.fetchCustomerStats error: $e');
      return {
        'totalCustomers': 0,
        'repeatCustomers': 0,
        'totalRevenue': 0.0,
        'averageOrderValue': 0.0,
      };
    }
  }

  Future<List<Map<String, dynamic>>> fetchCustomerList({
    required int offset,
    required int limit,
    String? sellerId,
  }) async {
    final sId = sellerId ?? currentSellerId;
    if (sId == null || sId.isEmpty) {
      return [];
    }

    try {
      final snapshot = await _firestore
          .collection('orders')
          .where('sellerId', isEqualTo: sId)
          .get();

      final bundle = await _processOrderSnapshot(snapshot, sId);
      final allCustomers = (bundle['customers'] as List<dynamic>?)
              ?.cast<Map<String, dynamic>>() ??
          [];

      if (offset >= allCustomers.length) {
        return [];
      }
      final end = (offset + limit) > allCustomers.length
          ? allCustomers.length
          : (offset + limit);
      return allCustomers.sublist(offset, end);
    } catch (e) {
      debugPrint('SellerCustomerService.fetchCustomerList error: $e');
      return [];
    }
  }

  Future<Map<String, dynamic>> _processOrderSnapshot(
    QuerySnapshot<Map<String, dynamic>> snapshot,
    String sId,
  ) async {
    final customerDataMap = <String, Map<String, dynamic>>{};
    final customerOrdersMap = <String, List<Map<String, dynamic>>>{};
    final productFrequencyMap = <String, Map<String, Map<String, dynamic>>>{};

    double globalRevenue = 0.0;

    for (var doc in snapshot.docs) {
      final data = doc.data();
      final docId = doc.id;
      final rawCustomerId =
          data['customerId'] ?? data['buyerId'] ?? data['userId'] ?? data['uid'];
      final customerId = (rawCustomerId != null && rawCustomerId.toString().isNotEmpty)
          ? rawCustomerId.toString()
          : 'customer_$docId';

      final amount = (data['amount'] as num?)?.toDouble() ?? 0.0;
      globalRevenue += amount;

      DateTime orderTime;
      final ts = data['timestamp'] ?? data['createdAt'];
      if (ts is Timestamp) {
        orderTime = ts.toDate();
      } else if (ts is String) {
        orderTime = DateTime.tryParse(ts) ?? DateTime.now();
      } else {
        orderTime = DateTime.now();
      }

      // Order items extraction
      final itemsList = <String>[];
      final rawItems = data['items'] as List<dynamic>? ?? [];
      for (final rawItem in rawItems) {
        if (rawItem is Map) {
          final itemName = (rawItem['foodName'] ??
                  rawItem['name'] ??
                  rawItem['title'] ??
                  rawItem['productName'] ??
                  'Item')
              .toString();
          final qty = (rawItem['quantity'] ?? rawItem['qty'] ?? 1) as num;
          final price = (rawItem['price'] ?? 0.0) as num;
          final pId = (rawItem['foodId'] ??
                  rawItem['productId'] ??
                  rawItem['id'] ??
                  itemName)
              .toString();
          final img = (rawItem['foodImage'] ??
                  rawItem['imageUrl'] ??
                  rawItem['image'] ??
                  '')
              .toString();

          itemsList.add('$qty x $itemName');

          productFrequencyMap.putIfAbsent(customerId, () => {});
          if (!productFrequencyMap[customerId]!.containsKey(pId)) {
            productFrequencyMap[customerId]![pId] = {
              'productId': pId,
              'productName': itemName,
              'orderCount': qty.toInt(),
              'imageUrl': img,
              'price': price.toDouble(),
            };
          } else {
            productFrequencyMap[customerId]![pId]!['orderCount'] =
                (productFrequencyMap[customerId]![pId]!['orderCount'] as int) +
                    qty.toInt();
          }
        }
      }

      final orderSummary = {
        'orderId': docId,
        'amount': amount,
        'status': (data['status'] ?? 'Completed').toString(),
        'timestamp': orderTime,
        'itemNames': itemsList,
        'itemsCount': itemsList.length,
      };

      customerOrdersMap.putIfAbsent(customerId, () => []).add(orderSummary);

      if (!customerDataMap.containsKey(customerId)) {
        customerDataMap[customerId] = {
          'id': customerId,
          'name': '',
          'orderCount': 0,
          'totalSpent': 0.0,
          'avatarUrl': '',
          'phone': '',
          'rawPhone': '',
          'lastOrderTime': orderTime,
          'lastOrderId': docId,
          'lastOrderStatus': data['status'] ?? 'Completed',
          'lastOrderAmount': amount,
          'lastOrderItems': itemsList,
          'latestOrderDoc': data,
        };
      } else {
        final currentLast =
            customerDataMap[customerId]!['lastOrderTime'] as DateTime;
        if (orderTime.isAfter(currentLast)) {
          customerDataMap[customerId]!['lastOrderTime'] = orderTime;
          customerDataMap[customerId]!['lastOrderId'] = docId;
          customerDataMap[customerId]!['lastOrderStatus'] =
              data['status'] ?? 'Completed';
          customerDataMap[customerId]!['lastOrderAmount'] = amount;
          customerDataMap[customerId]!['lastOrderItems'] = itemsList;
          customerDataMap[customerId]!['latestOrderDoc'] = data;
        }
      }

      customerDataMap[customerId]!['orderCount'] =
          (customerDataMap[customerId]!['orderCount'] as int) + 1;
      customerDataMap[customerId]!['totalSpent'] =
          (customerDataMap[customerId]!['totalSpent'] as double) + amount;
    }

    final userIds = customerDataMap.keys.toList();

    // Fetch user profiles and seller-scoped reviews concurrently
    final futures = userIds.map((customerId) async {
      String? resolvedName;
      String? resolvedAvatar;
      String? resolvedPhone;

      final latestDoc =
          customerDataMap[customerId]!['latestOrderDoc'] as Map<String, dynamic>?;

      if (latestDoc != null) {
        final candName = latestDoc['customerName'] ??
            latestDoc['buyerName'] ??
            latestDoc['userName'] ??
            latestDoc['name'] ??
            (latestDoc['address'] is Map ? latestDoc['address']['name'] : null) ??
            (latestDoc['deliveryAddress'] is Map
                ? latestDoc['deliveryAddress']['name']
                : null);
        if (candName != null && _isValidName(candName.toString())) {
          resolvedName = candName.toString().trim();
        }

        final candAvatar = latestDoc['customerImage'] ??
            latestDoc['buyerImage'] ??
            latestDoc['avatarUrl'] ??
            latestDoc['photoUrl'];
        if (candAvatar != null && candAvatar.toString().trim().isNotEmpty) {
          resolvedAvatar = candAvatar.toString().trim();
        }

        final candPhone = latestDoc['customerPhone'] ??
            latestDoc['phone'] ??
            latestDoc['phoneNumber'] ??
            latestDoc['mobile'] ??
            (latestDoc['address'] is Map ? latestDoc['address']['phone'] : null) ??
            (latestDoc['deliveryAddress'] is Map
                ? latestDoc['deliveryAddress']['phone']
                : null);
        if (candPhone != null && candPhone.toString().trim().isNotEmpty) {
          resolvedPhone = candPhone.toString().trim();
        }
      }

      // Query buyer_user collection by customerId
      try {
        final userDoc =
            await _firestore.collection('buyer_user').doc(customerId).get();
        if (userDoc.exists && userDoc.data() != null) {
          final uData = userDoc.data()!;
          if (resolvedName == null) {
            final uName = uData['name'] ??
                uData['displayName'] ??
                uData['fullName'] ??
                uData['userName'];
            if (uName != null && _isValidName(uName.toString())) {
              resolvedName = uName.toString().trim();
            }
          }
          if (resolvedAvatar == null) {
            final uImg = uData['imageUrl'] ??
                uData['photoUrl'] ??
                uData['avatarUrl'] ??
                uData['profileImage'] ??
                uData['profilePic'];
            if (uImg != null && uImg.toString().trim().isNotEmpty) {
              resolvedAvatar = uImg.toString().trim();
            }
          }
          if (resolvedPhone == null) {
            final uPhone = uData['phone'] ??
                uData['phoneNumber'] ??
                uData['mobileNumber'] ??
                uData['mobile'];
            if (uPhone != null && uPhone.toString().trim().isNotEmpty) {
              resolvedPhone = uPhone.toString().trim();
            }
          }
        }
      } catch (e) {
        debugPrint('SellerCustomerService: failed to fetch buyer_user profile: $e');
      }

      // Fetch reviews written by this customer for this seller
      final customerReviews = <Map<String, dynamic>>[];
      try {
        final reviewSnap = await _firestore
            .collection('reviews')
            .where('sellerId', isEqualTo: sId)
            .where('customerId', isEqualTo: customerId)
            .get();

        for (var rDoc in reviewSnap.docs) {
          final rData = rDoc.data();
          DateTime rDate;
          final rTs = rData['createdAt'] ?? rData['timestamp'];
          if (rTs is Timestamp) {
            rDate = rTs.toDate();
          } else if (rTs is String) {
            rDate = DateTime.tryParse(rTs) ?? DateTime.now();
          } else {
            rDate = DateTime.now();
          }

          customerReviews.add({
            'reviewId': rDoc.id,
            'rating': (rData['rating'] as num?)?.toDouble() ?? 5.0,
            'content': (rData['content'] ?? rData['reviewText'] ?? '').toString(),
            'createdAt': rDate,
            'productName': (rData['productName'] ?? rData['foodName'] ?? '').toString(),
          });
        }
      } catch (e) {
        debugPrint('SellerCustomerService: failed to fetch customer reviews: $e');
      }

      return (
        customerId,
        resolvedName ?? 'Customer',
        resolvedAvatar ?? '',
        resolvedPhone ?? '',
        customerReviews,
      );
    });

    final resolvedResults = await Future.wait(futures);

    for (final (customerId, name, avatarUrl, rawPhone, reviews) in resolvedResults) {
      final custMap = customerDataMap[customerId]!;
      custMap['name'] = name;
      custMap['avatarUrl'] = avatarUrl;
      custMap['rawPhone'] = rawPhone;
      custMap['phone'] = _maskPhone(rawPhone);
      custMap['reviews'] = reviews;

      // Sort order history descending by timestamp
      final orders = customerOrdersMap[customerId] ?? [];
      orders.sort((a, b) => (b['timestamp'] as DateTime).compareTo(a['timestamp'] as DateTime));
      custMap['orderHistory'] = orders;

      // Favorite products
      final favList = productFrequencyMap[customerId]?.values.toList() ?? [];
      favList.sort((a, b) => (b['orderCount'] as int).compareTo(a['orderCount'] as int));
      custMap['favouriteProducts'] = favList;

      // Average rating from reviews if any
      if (reviews.isNotEmpty) {
        final sum = reviews.fold<double>(0.0, (acc, r) => acc + (r['rating'] as double));
        custMap['averageRating'] = double.parse((sum / reviews.length).toStringAsFixed(1));
      } else {
        custMap['averageRating'] = null;
      }
    }

    final allCustomers = customerDataMap.values.toList();
    allCustomers.sort((a, b) {
      final countComp = (b['orderCount'] as int).compareTo(a['orderCount'] as int);
      if (countComp != 0) return countComp;
      final timeA = a['lastOrderTime'] as DateTime;
      final timeB = b['lastOrderTime'] as DateTime;
      return timeB.compareTo(timeA);
    });

    final totalCustomers = allCustomers.length;
    final repeatCustomers = allCustomers.where((c) => (c['orderCount'] as int) > 1).length;
    final totalOrders = snapshot.docs.length;
    final avgOrderValue = totalOrders > 0 ? (globalRevenue / totalOrders) : 0.0;

    return {
      'stats': {
        'totalCustomers': totalCustomers,
        'repeatCustomers': repeatCustomers,
        'totalRevenue': globalRevenue,
        'averageOrderValue': avgOrderValue,
      },
      'customers': allCustomers,
    };
  }

  String _maskPhone(String? phone) {
    if (phone == null || phone.trim().isEmpty) return '';
    final trimmed = phone.trim();
    if (trimmed.length <= 4) return '****';
    if (trimmed.length <= 7) {
      return '${trimmed.substring(0, 2)}***${trimmed.substring(trimmed.length - 2)}';
    }
    final prefix = trimmed.substring(0, trimmed.length > 10 ? 6 : 3);
    final suffix = trimmed.substring(trimmed.length - 3);
    return '$prefix****$suffix';
  }

  bool _isValidName(String name) {
    final trimmed = name.trim();
    return trimmed.isNotEmpty &&
        trimmed != 'Customer' &&
        trimmed != 'Buyer' &&
        trimmed != 'Unknown' &&
        trimmed != 'Unknown Customer' &&
        trimmed != 'null';
  }
}
