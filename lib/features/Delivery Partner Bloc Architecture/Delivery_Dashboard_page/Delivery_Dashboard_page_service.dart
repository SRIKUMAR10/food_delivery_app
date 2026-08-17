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

  @override
  Future<Map<String, dynamic>> fetchDashboardMetrics() async {
    try {
      final currentFirestore = _firestore ?? FirebaseFirestore.instance;
      final uid = await _resolveUid();
      if (uid != null && uid.isNotEmpty) {
        final partnerDoc = await currentFirestore
            .collection('delivery_partners')
            .doc(uid)
            .get();

        if (partnerDoc.exists) {
          final allDriverOrders = await currentFirestore
              .collection('orders')
              .where('riderId', isEqualTo: uid)
              .get();

          return _mapMetricsFromDocs(partnerDoc, allDriverOrders.docs, uid: uid);
        }
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

      final partnerStream = currentFirestore
          .collection('delivery_partners')
          .doc(uid)
          .snapshots()
          .handleError((e) => debugPrint('partnerStream error: $e'));

      final allOrdersStream = currentFirestore
          .collection('orders')
          .where('riderId', isEqualTo: uid)
          .snapshots()
          .handleError((e) => debugPrint('watchDashboardMetrics stream error: $e'));

      final sellerOrdersStream = currentFirestore
          .collection('orders')
          .where('status', whereIn: [
            'Ready',
            'ready',
            'ready_for_pickup',
            'assigned',
            'searching_driver',
            'placed',
          ])
          .snapshots()
          .handleError((e) => debugPrint('sellerOrdersStream error: $e'));

      final notificationsStream = currentFirestore
          .collection('delivery_partners')
          .doc(uid)
          .collection('notifications')
          .orderBy('createdAt', descending: true)
          .snapshots()
          .handleError((e) => debugPrint('notificationsStream error: $e'));

      return Rx.combineLatest4<
          DocumentSnapshot<Map<String, dynamic>>,
          QuerySnapshot<Map<String, dynamic>>,
          QuerySnapshot<Map<String, dynamic>>,
          QuerySnapshot<Map<String, dynamic>>,
          Map<String, dynamic>>(
        partnerStream,
        allOrdersStream,
        sellerOrdersStream,
        notificationsStream,
        (partnerDoc, ordersSnapshot, sellerOrdersSnapshot, notifsSnapshot) =>
            _mapMetricsFromDocs(
          partnerDoc,
          ordersSnapshot.docs,
          sellerOrdersSnapshot: sellerOrdersSnapshot.docs,
          uid: uid,
          notifsSnapshot: notifsSnapshot.docs,
        ),
      ).handleError((e) {
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
    DocumentSnapshot<Map<String, dynamic>> partnerDoc,
    List<QueryDocumentSnapshot<Map<String, dynamic>>> allDocs, {
    List<QueryDocumentSnapshot<Map<String, dynamic>>>? sellerOrdersSnapshot,
    String? uid,
    List<QueryDocumentSnapshot<Map<String, dynamic>>>? notifsSnapshot,
  }) {
    final data = partnerDoc.exists ? partnerDoc.data() ?? {} : {};
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

