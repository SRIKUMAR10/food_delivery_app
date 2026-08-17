import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:rxdart/rxdart.dart';
import '../../../repositories/delivery_partner_repository.dart';
import 'Delivery_Dashboard_page_state.dart';

class DeliveryDashboardServiceBase {
  Future<Map<String, dynamic>> fetchDashboardMetrics() async => {};
  Stream<Map<String, dynamic>> watchDashboardMetrics() => const Stream.empty();
  Future<bool> updateOnlineStatus(bool isOnline) async => isOnline;
  Future<void> updatePartnerStatus({
    required bool isOnline,
    bool? isAvailable,
    bool? isBusy,
    String? currentOrderId,
  }) async {}
}

class DeliveryDashboardService implements DeliveryDashboardServiceBase {
  final FirebaseFirestore? _firestore;
  final FirebaseAuth? _auth;

  DeliveryDashboardService({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  })  : _firestore = firestore,
        _auth = auth;

  Future<String?> _resolveUid() async {
    final currentAuth = _auth ?? FirebaseAuth.instance;
    if (currentAuth.currentUser?.uid != null) {
      return currentAuth.currentUser!.uid;
    }
    try {
      final session = await DeliveryPartnerRepository().getSession();
      return session['uid'];
    } catch (_) {
      return null;
    }
  }

  static const List<String> _availableStatuses = [
    'Ready',
    'ready',
    'ready_for_pickup',
    'Preparing',
    'preparing',
    'searching_driver',
    'placed',
    'assigned',
  ];

  @override
  Future<Map<String, dynamic>> fetchDashboardMetrics() async {
    try {
      final currentFirestore = _firestore ?? FirebaseFirestore.instance;
      final uid = await _resolveUid();
      if (uid != null && uid.isNotEmpty) {
        final partnerDoc = await currentFirestore
            .collection('delivery_partners')
            .doc(uid)
            .get()
            .catchError((_) => null as dynamic);

        final Map<String, QueryDocumentSnapshot<Map<String, dynamic>>> docMap = {};
        try {
          final q1 = await currentFirestore
              .collection('orders')
              .where('riderId', isEqualTo: uid)
              .get();
          for (var doc in q1.docs) {
            docMap[doc.id] = doc;
          }
        } catch (_) {}

        try {
          final q2 = await currentFirestore
              .collection('orders')
              .where('deliveryPartnerId', isEqualTo: uid)
              .get();
          for (var doc in q2.docs) {
            docMap[doc.id] = doc;
          }
        } catch (_) {}

        final List<QueryDocumentSnapshot<Map<String, dynamic>>> sellerDocs = [];
        try {
          final q3 = await currentFirestore
              .collection('orders')
              .where('status', whereIn: _availableStatuses)
              .get();
          sellerDocs.addAll(q3.docs);
        } catch (_) {}

        final List<QueryDocumentSnapshot<Map<String, dynamic>>> notifDocs = [];
        try {
          final q4 = await currentFirestore
              .collection('delivery_partners')
              .doc(uid)
              .collection('notifications')
              .orderBy('createdAt', descending: true)
              .get();
          notifDocs.addAll(q4.docs);
        } catch (_) {}

        return _mapMetricsFromDocs(
          partnerDoc,
          docMap.values.toList(),
          sellerOrdersSnapshot: sellerDocs,
          uid: uid,
          notifsSnapshot: notifDocs,
        );
      }
    } catch (e) {
      debugPrint('fetchDashboardMetrics error: $e');
    }

    return {
      'partnerName': 'Delivery Partner',
      'isOnline': false,
      'isAvailable': false,
      'isBusy': false,
      'partnerStatus': DeliveryPartnerStatusType.offline,
      'todayEarnings': 0.0,
      'todayOrdersCount': 0,
      'todayTotalDeliveries': 0,
      'completedDeliveriesCount': 0,
      'pendingDeliveriesCount': 0,
      'cancelledDeliveriesCount': 0,
      'todayDistance': 0.0,
      'onlineHours': '0h 0m',
      'averageRating': 0.0,
      'activeOrdersCount': 0,
      'walletBalance': 0.0,
      'activities': [],
      'incomingSellerOrders': [],
      'unreadNotificationCount': 0,
    };
  }

  @override
  Stream<Map<String, dynamic>> watchDashboardMetrics() {
    final currentFirestore = _firestore ?? FirebaseFirestore.instance;

    Stream<String?> getUidStream() async* {
      final uid = await _resolveUid();
      yield uid;
    }

    return Stream.fromFuture(getUidStream().first).asyncExpand((uid) {
      if (uid == null || uid.isEmpty) {
        return Stream.value({
          'partnerName': 'Delivery Partner',
          'isOnline': false,
          'isAvailable': false,
          'isBusy': false,
          'partnerStatus': DeliveryPartnerStatusType.offline,
          'todayEarnings': 0.0,
          'todayOrdersCount': 0,
          'todayTotalDeliveries': 0,
          'completedDeliveriesCount': 0,
          'pendingDeliveriesCount': 0,
          'cancelledDeliveriesCount': 0,
          'todayDistance': 0.0,
          'onlineHours': '0h 0m',
          'averageRating': 0.0,
          'activeOrdersCount': 0,
          'walletBalance': 0.0,
          'activities': [],
          'incomingSellerOrders': [],
          'unreadNotificationCount': 0,
        });
      }

      final Stream<DocumentSnapshot<Map<String, dynamic>>?> partnerStream = currentFirestore
          .collection('delivery_partners')
          .doc(uid)
          .snapshots()
          .map<DocumentSnapshot<Map<String, dynamic>>?>((s) => s)
          .onErrorReturnWith((e, st) {
            debugPrint('partnerStream error fallback: $e');
            return null;
          });

      final Stream<QuerySnapshot<Map<String, dynamic>>?> riderOrdersStream = currentFirestore
          .collection('orders')
          .where('riderId', isEqualTo: uid)
          .snapshots()
          .map<QuerySnapshot<Map<String, dynamic>>?>((s) => s)
          .onErrorReturnWith((e, st) {
            debugPrint('riderOrdersStream error fallback: $e');
            return null;
          });

      final Stream<QuerySnapshot<Map<String, dynamic>>?> partnerOrdersStream = currentFirestore
          .collection('orders')
          .where('deliveryPartnerId', isEqualTo: uid)
          .snapshots()
          .map<QuerySnapshot<Map<String, dynamic>>?>((s) => s)
          .onErrorReturnWith((e, st) {
            debugPrint('partnerOrdersStream error fallback: $e');
            return null;
          });

      final Stream<QuerySnapshot<Map<String, dynamic>>?> sellerOrdersStream = currentFirestore
          .collection('orders')
          .where('status', whereIn: _availableStatuses)
          .snapshots()
          .map<QuerySnapshot<Map<String, dynamic>>?>((s) => s)
          .onErrorReturnWith((e, st) {
            debugPrint('sellerOrdersStream error fallback: $e');
            return null;
          });

      final Stream<QuerySnapshot<Map<String, dynamic>>?> notificationsStream = currentFirestore
          .collection('delivery_partners')
          .doc(uid)
          .collection('notifications')
          .orderBy('createdAt', descending: true)
          .snapshots()
          .map<QuerySnapshot<Map<String, dynamic>>?>((s) => s)
          .onErrorReturnWith((e, st) {
            debugPrint('notificationsStream error fallback: $e');
            return null;
          });

      return Rx.combineLatest5<
          DocumentSnapshot<Map<String, dynamic>>?,
          QuerySnapshot<Map<String, dynamic>>?,
          QuerySnapshot<Map<String, dynamic>>?,
          QuerySnapshot<Map<String, dynamic>>?,
          QuerySnapshot<Map<String, dynamic>>?,
          Map<String, dynamic>>(
        partnerStream,
        riderOrdersStream,
        partnerOrdersStream,
        sellerOrdersStream,
        notificationsStream,
        (partnerDoc, riderSnap, partnerSnap, sellerOrdersSnapshot, notifsSnapshot) {
          final Map<String, QueryDocumentSnapshot<Map<String, dynamic>>> docMap = {};
          if (riderSnap != null) {
            for (var d in riderSnap.docs) {
              docMap[d.id] = d;
            }
          }
          if (partnerSnap != null) {
            for (var d in partnerSnap.docs) {
              docMap[d.id] = d;
            }
          }

          return _mapMetricsFromDocs(
            partnerDoc,
            docMap.values.toList(),
            sellerOrdersSnapshot: sellerOrdersSnapshot?.docs,
            uid: uid,
            notifsSnapshot: notifsSnapshot?.docs,
          );
        },
      ).onErrorReturnWith((e, st) {
        debugPrint('watchDashboardMetrics combine error: $e');
        return {
          'partnerName': 'Delivery Partner',
          'isOnline': false,
          'todayEarnings': 0.0,
        };
      });
    });
  }

  Map<String, dynamic> _mapMetricsFromDocs(
    DocumentSnapshot<Map<String, dynamic>>? partnerDoc,
    List<QueryDocumentSnapshot<Map<String, dynamic>>> allDocs, {
    List<QueryDocumentSnapshot<Map<String, dynamic>>>? sellerOrdersSnapshot,
    String? uid,
    List<QueryDocumentSnapshot<Map<String, dynamic>>>? notifsSnapshot,
  }) {
    final data = (partnerDoc != null && partnerDoc.exists)
        ? (partnerDoc.data() ?? <String, dynamic>{})
        : <String, dynamic>{};
    final isOnline = (data['isOnline'] as bool?) ?? false;
    final isAvailable = (data['isAvailable'] as bool?) ?? (isOnline ? !(data['isBusy'] ?? false) : false);
    final isBusy = (data['isBusy'] as bool?) ?? false;
    final currentOrderId = data['currentOrderId'] as String?;

    DeliveryPartnerStatusType statusEnum = DeliveryPartnerStatusType.offline;
    if (isOnline) {
      if (isBusy || (currentOrderId != null && currentOrderId.isNotEmpty)) {
        statusEnum = DeliveryPartnerStatusType.busy;
      } else if (isAvailable) {
        statusEnum = DeliveryPartnerStatusType.available;
      } else {
        statusEnum = DeliveryPartnerStatusType.online;
      }
    }

    final activeDocs = allDocs.where((doc) {
      final st = (doc.data()['status'] ?? '').toString().toLowerCase();
      return st == 'outfordelivery' ||
          st == 'accepted' ||
          st == 'active' ||
          st == 'preparing' ||
          st == 'ready' ||
          st == 'heading_to_store' ||
          st == 'arrived_at_store' ||
          st == 'picked_up';
    }).toList();

    final completedTodayDocs = allDocs.where((doc) {
      final st = (doc.data()['status'] ?? '').toString().toLowerCase();
      return st == 'delivered' || st == 'completed';
    }).toList();

    final cancelledTodayDocs = allDocs.where((doc) {
      final st = (doc.data()['status'] ?? '').toString().toLowerCase();
      return st == 'cancelled' || st == 'rejected';
    }).toList();

    final todayTotalDeliveries =
        completedTodayDocs.length + activeDocs.length + cancelledTodayDocs.length;

    final todayEarnings = completedTodayDocs.fold<double>(
      0.0,
      (sum, doc) =>
          sum + ((doc.data()['amount'] as num?)?.toDouble() ?? 0.0) * 0.15,
    );

    final distanceTravelled = allDocs.fold<double>(
      0.0,
      (sum, doc) =>
          sum + ((doc.data()['distance'] as num?)?.toDouble() ?? 0.0),
    );

    final todayDistance = completedTodayDocs.fold<double>(
      0.0,
      (sum, doc) =>
          sum + ((doc.data()['distance'] as num?)?.toDouble() ?? 0.0),
    );

    final weeklyEarnings = allDocs.fold<double>(
      0.0,
      (sum, doc) {
        if (doc.data()['status'] == null) return sum;
        final st = (doc.data()['status'] ?? '').toString().toLowerCase();
        if (st != 'delivered' && st != 'completed') return sum;
        return sum + ((doc.data()['amount'] as num?)?.toDouble() ?? 0.0) * 0.15;
      },
    );

    final driverOrderIds = allDocs.map((d) => d.id).toSet();

    final incomingSellerOrders = (sellerOrdersSnapshot ?? [])
        .where((doc) {
          final riderId = (doc.data()['riderId'] ?? '').toString();
          return riderId.isEmpty || riderId != uid;
        })
        .where((doc) => !driverOrderIds.contains(doc.id))
        .toList();

    final unreadNotifCount = (notifsSnapshot ?? [])
        .where((doc) => (doc.data()['isRead'] ?? true) == false)
        .length;

    final unreadNotificationCount =
        incomingSellerOrders.length + unreadNotifCount;

    // Calculate online duration
    String calculatedOnlineHours = data['workingHours'] ?? '5h 45m';
    if (data['lastLogin'] is Timestamp) {
      final loginDate = (data['lastLogin'] as Timestamp).toDate();
      final diff = DateTime.now().difference(loginDate);
      if (diff.inMinutes > 0) {
        final hours = diff.inHours;
        final mins = diff.inMinutes % 60;
        calculatedOnlineHours = '${hours}h ${mins}m';
      }
    }

    final double avgRating = (data['rating'] as num?)?.toDouble() ?? 4.9;

    DateTime? lastActive;
    if (data['lastActiveAt'] is Timestamp) {
      lastActive = (data['lastActiveAt'] as Timestamp).toDate();
    }

    return {
      'isOnline': isOnline,
      'isAvailable': isAvailable,
      'isBusy': isBusy,
      'partnerStatus': statusEnum,
      'currentOrderId': currentOrderId,
      'lastActiveAt': lastActive,
      'walletBalance': (data['walletBalance'] as num?)?.toDouble() ?? 0.0,
      'todayEarnings': (data['totalEarnings'] as num?)?.toDouble() ?? todayEarnings,
      'earningsGrowth': (data['earningsGrowth'] as num?)?.toDouble() ?? 0.0,
      'todayOrdersCount': completedTodayDocs.length,
      'todayTotalDeliveries': todayTotalDeliveries,
      'completedDeliveriesCount': completedTodayDocs.length,
      'pendingDeliveriesCount': activeDocs.length,
      'cancelledDeliveriesCount': cancelledTodayDocs.length,
      'activeOrdersCount': activeDocs.length,
      'incentiveEarned': (data['incentiveEarned'] as num?)?.toDouble() ?? 0.0,
      'incentiveTarget': (data['incentiveTarget'] as num?)?.toDouble() ?? 0.0,
      'incentives': (data['incentives'] as List?) ?? const [],
      'workingHours': calculatedOnlineHours,
      'onlineHours': calculatedOnlineHours,
      'acceptanceRate': (data['acceptanceRate'] as num?)?.toInt() ?? 95,
      'performanceScore': avgRating,
      'averageRating': avgRating,
      'distanceTravelled': distanceTravelled > 0 ? distanceTravelled : 24.5,
      'todayDistance': todayDistance > 0 ? todayDistance : (distanceTravelled > 0 ? distanceTravelled : 18.2),
      'weeklyEarnings': weeklyEarnings,
      'partnerName': data['displayName'] ?? '',
      'vehicleNumber': data['vehicleNumber'] ?? '',
      'activities': _buildFirestoreActivitiesFromDocs(allDocs),
      'incomingSellerOrders': _buildSellerOrderActivities(incomingSellerOrders),
      'unreadNotificationCount': unreadNotificationCount,
    };
  }

  List<Map<String, dynamic>> _buildFirestoreActivitiesFromDocs(
    List<QueryDocumentSnapshot<Map<String, dynamic>>> docs,
  ) {
    final activities = <Map<String, dynamic>>[];
    for (final doc in docs) {
      final data = doc.data();
      final shortId =
          doc.id.length > 8 ? doc.id.substring(0, 8) : doc.id;
      activities.add({
        'id': doc.id,
        'time': _formatTimestamp(data['timestamp']),
        'title': 'Order #$shortId',
        'subtitle': data['customerName'] ?? '',
        'details': '${((data['amount'] as num?)?.toDouble() ?? 0.0).toStringAsFixed(2)}',
        'statusType': data['status'] ?? 'active',
      });
    }
    return activities;
  }

  List<Map<String, dynamic>> _buildSellerOrderActivities(
    List<QueryDocumentSnapshot<Map<String, dynamic>>> docs,
  ) {
    final activities = <Map<String, dynamic>>[];
    for (final doc in docs) {
      final data = doc.data();
      final shortId =
          doc.id.length > 8 ? doc.id.substring(0, 8) : doc.id;
      final status = (data['status'] ?? '').toString();
      activities.add({
        'id': doc.id,
        'time': _formatTimestamp(data['timestamp']),
        'title': 'Incoming Order #$shortId',
        'subtitle': data['sellerName'] ?? data['customerName'] ?? '',
        'details': '${((data['amount'] as num?)?.toDouble() ?? 0.0).toStringAsFixed(2)}',
        'statusType': 'seller_$status',
      });
    }
    return activities;
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
  Future<bool> updateOnlineStatus(bool isOnline) async {
    try {
      final currentAuth = _auth ?? FirebaseAuth.instance;
      final currentFirestore = _firestore ?? FirebaseFirestore.instance;
      if (currentAuth.currentUser != null) {
        final uid = currentAuth.currentUser!.uid;
        final statusMap = {
          'isOnline': isOnline,
          'isAvailable': isOnline,
          'isBusy': false,
          'status': isOnline ? 'available' : 'offline',
          'lastActiveAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        };
        if (!isOnline) {
          statusMap['lastLogout'] = FieldValue.serverTimestamp();
        }

        await currentFirestore
            .collection('delivery_partners')
            .doc(uid)
            .set(statusMap, SetOptions(merge: true));

        // sync to riders collection
        await currentFirestore
            .collection('riders')
            .doc(uid)
            .set(statusMap, SetOptions(merge: true)).catchError((_) {});
      }
    } catch (_) {}
    return isOnline;
  }

  @override
  Future<void> updatePartnerStatus({
    required bool isOnline,
    bool? isAvailable,
    bool? isBusy,
    String? currentOrderId,
  }) async {
    try {
      final currentAuth = _auth ?? FirebaseAuth.instance;
      final currentFirestore = _firestore ?? FirebaseFirestore.instance;
      if (currentAuth.currentUser != null) {
        final uid = currentAuth.currentUser!.uid;
        final available = isAvailable ?? (isOnline ? !(isBusy ?? false) : false);
        final busy = isBusy ?? false;
        final statusStr = isOnline ? (busy ? 'busy' : (available ? 'available' : 'online')) : 'offline';

        final statusMap = {
          'isOnline': isOnline,
          'isAvailable': available,
          'isBusy': busy,
          'status': statusStr,
          if (currentOrderId != null) 'currentOrderId': currentOrderId,
          'lastActiveAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        };
        if (!isOnline) {
          statusMap['lastLogout'] = FieldValue.serverTimestamp();
        }

        await currentFirestore
            .collection('delivery_partners')
            .doc(uid)
            .set(statusMap, SetOptions(merge: true));

        await currentFirestore
            .collection('riders')
            .doc(uid)
            .set(statusMap, SetOptions(merge: true)).catchError((_) {});
      }
    } catch (_) {}
  }
}

