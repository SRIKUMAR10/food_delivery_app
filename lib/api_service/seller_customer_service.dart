import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SellerCustomerService {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  SellerCustomerService({FirebaseFirestore? firestore, FirebaseAuth? auth})
      : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  Future<Map<String, dynamic>> fetchCustomerStats() async {
    final sellerId = _auth.currentUser?.uid;
    if (sellerId == null) {
      throw Exception('User not logged in');
    }

    try {
      final snapshot = await _firestore
          .collection('orders')
          .where('sellerId', isEqualTo: sellerId)
          .get();

      final customerCounts = <String, int>{};

      for (var doc in snapshot.docs) {
        final data = doc.data();
        final rawCustomerId = data['customerId'] ?? data['buyerId'] ?? data['userId'] ?? data['uid'];
        final customerId = (rawCustomerId != null && rawCustomerId.toString().isNotEmpty)
            ? rawCustomerId.toString()
            : 'unknown';
        customerCounts[customerId] = (customerCounts[customerId] ?? 0) + 1;
      }

      int totalCustomers = customerCounts.length;
      int repeatCustomers = customerCounts.values.where((count) => count > 1).length;

      return {
        'totalCustomers': totalCustomers,
        'repeatCustomers': repeatCustomers,
      };
    } catch (e) {
      debugPrint('SellerCustomerService.fetchCustomerStats error: $e');
      return {
        'totalCustomers': 0,
        'repeatCustomers': 0,
      };
    }
  }

  Future<List<Map<String, dynamic>>> fetchCustomerList({required int offset, required int limit}) async {
    final sellerId = _auth.currentUser?.uid;
    if (sellerId == null) {
      throw Exception('User not logged in');
    }

    try {
      final snapshot = await _firestore
          .collection('orders')
          .where('sellerId', isEqualTo: sellerId)
          .get();

      final customerDataMap = <String, Map<String, dynamic>>{};
      final customerLatestOrderMap = <String, Map<String, dynamic>>{};

      for (var doc in snapshot.docs) {
        final data = doc.data();
        final rawCustomerId = data['customerId'] ?? data['buyerId'] ?? data['userId'] ?? data['uid'];
        final customerId = (rawCustomerId != null && rawCustomerId.toString().isNotEmpty)
            ? rawCustomerId.toString()
            : 'customer_${doc.id}';

        final orderTime = (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.fromMillisecondsSinceEpoch(0);

        if (!customerDataMap.containsKey(customerId)) {
          customerDataMap[customerId] = {
            'id': customerId,
            'name': '',
            'orderCount': 0,
            'avatarUrl': '',
            'lastOrderTime': orderTime,
          };
          customerLatestOrderMap[customerId] = data;
        } else {
          final currentLastOrder = customerDataMap[customerId]!['lastOrderTime'] as DateTime;
          if (orderTime.isAfter(currentLastOrder)) {
            customerDataMap[customerId]!['lastOrderTime'] = orderTime;
            customerLatestOrderMap[customerId] = data;
          }
        }
        customerDataMap[customerId]!['orderCount'] = (customerDataMap[customerId]!['orderCount'] as int) + 1;
      }

      final userIdsToFetch = customerDataMap.keys.toList();

      final nameFutures = userIdsToFetch.map((customerId) async {
        String? resolvedName;
        String? resolvedAvatar;

        // 1. Try name from the latest order document for this customer
        final latestOrderData = customerLatestOrderMap[customerId];
        if (latestOrderData != null) {
          final candidateName = latestOrderData['customerName'] ??
              latestOrderData['buyerName'] ??
              latestOrderData['userName'] ??
              latestOrderData['name'] ??
              (latestOrderData['address'] is Map ? latestOrderData['address']['name'] : null) ??
              (latestOrderData['deliveryAddress'] is Map ? latestOrderData['deliveryAddress']['name'] : null) ??
              (latestOrderData['shippingAddress'] is Map ? latestOrderData['shippingAddress']['name'] : null);

          if (candidateName != null && _isValidName(candidateName.toString())) {
            resolvedName = candidateName.toString().trim();
          }

          final candidateAvatar = latestOrderData['customerImage'] ??
              latestOrderData['buyerImage'] ??
              latestOrderData['avatarUrl'] ??
              latestOrderData['photoUrl'];
          if (candidateAvatar != null && candidateAvatar.toString().trim().isNotEmpty) {
            resolvedAvatar = candidateAvatar.toString().trim();
          }
        }

        // 2. Query users collection by customerId (Firebase Auth UID)
        if (resolvedName == null || resolvedAvatar == null) {
          try {
            final userDoc = await _firestore.collection('buyer_user').doc(customerId).get();
            if (userDoc.exists && userDoc.data() != null) {
              final userData = userDoc.data()!;
              if (resolvedName == null) {
                final uName = userData['name'] ??
                    userData['displayName'] ??
                    userData['fullName'] ??
                    userData['userName'];
                if (uName != null && _isValidName(uName.toString())) {
                  resolvedName = uName.toString().trim();
                }
              }
              if (resolvedAvatar == null) {
                final uAvatar = userData['imageUrl'] ??
                    userData['photoUrl'] ??
                    userData['avatarUrl'] ??
                    userData['profileImage'] ??
                    userData['profilePic'];
                if (uAvatar != null && uAvatar.toString().trim().isNotEmpty) {
                  resolvedAvatar = uAvatar.toString().trim();
                }
              }
            }
          } catch (e) {
            debugPrint('SellerCustomerService: failed to resolve buyer name for $customerId: $e');
          }
        }

        return (customerId, resolvedName ?? 'Customer', resolvedAvatar ?? '');
      });

      final resolvedProfiles = await Future.wait(nameFutures);

      for (final (customerId, name, avatarUrl) in resolvedProfiles) {
        customerDataMap[customerId]!['name'] = name;
        customerDataMap[customerId]!['avatarUrl'] = avatarUrl;
      }

      final allCustomers = customerDataMap.values.toList();
      allCustomers.sort((a, b) {
        final countComparison = (b['orderCount'] as int).compareTo(a['orderCount'] as int);
        if (countComparison != 0) return countComparison;
        final timeA = a['lastOrderTime'] as DateTime;
        final timeB = b['lastOrderTime'] as DateTime;
        return timeB.compareTo(timeA);
      });

      if (offset >= allCustomers.length) {
        return [];
      }
      final end = (offset + limit) > allCustomers.length ? allCustomers.length : (offset + limit);
      return allCustomers.sublist(offset, end);
    } catch (e) {
      debugPrint('SellerCustomerService.fetchCustomerList error: $e');
      return [];
    }
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
