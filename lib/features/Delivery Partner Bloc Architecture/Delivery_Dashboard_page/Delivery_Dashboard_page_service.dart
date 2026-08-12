import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:rxdart/rxdart.dart';
import '../../../repositories/delivery_partner_repository.dart';

class DeliveryDashboardServiceBase {
  Future<Map<String, dynamic>> fetchDashboardMetrics() async => {};
  Stream<Map<String, dynamic>> watchDashboardMetrics() => const Stream.empty();
  Future<bool> updateOnlineStatus(bool isOnline) async => isOnline;
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

          return _mapMetricsFromDocs(partnerDoc, allDriverOrders.docs);
        }
      }
    } catch (e) {
      debugPrint('fetchDashboardMetrics error: $e');
    }

    return {
      'partnerName': 'Delivery Partner',
      'isOnline': false,
      'todayEarnings': 0.0,
      'todayOrdersCount': 0,
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
          'todayEarnings': 0.0,
          'todayOrdersCount': 0,
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
    
    final activeDocs = allDocs.where((doc) {
      final st = (doc.data()['status'] ?? '').toString().toLowerCase();
      return st == 'outfordelivery' || st == 'accepted' || st == 'active' || st == 'preparing' || st == 'ready';
    }).toList();

    final completedTodayDocs = allDocs.where((doc) {
      final st = (doc.data()['status'] ?? '').toString().toLowerCase();
      return st == 'delivered' || st == 'completed';
    }).toList();

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

    return {
      'isOnline': data['isOnline'] ?? false,
      'walletBalance': (data['walletBalance'] as num?)?.toDouble() ?? 0.0,
      'todayEarnings': (data['totalEarnings'] as num?)?.toDouble() ?? todayEarnings,
      'earningsGrowth': (data['earningsGrowth'] as num?)?.toDouble() ?? 0.0,
      'todayOrdersCount': completedTodayDocs.length,
      'activeOrdersCount': activeDocs.length,
      'incentiveEarned': (data['incentiveEarned'] as num?)?.toDouble() ?? 0.0,
      'incentiveTarget': (data['incentiveTarget'] as num?)?.toDouble() ?? 0.0,
      'incentives': (data['incentives'] as List?) ?? const [],
      'workingHours': data['workingHours'] ?? '',
      'acceptanceRate': (data['acceptanceRate'] as num?)?.toInt() ?? 0,
      'performanceScore': (data['rating'] as num?)?.toDouble() ?? 0.0,
      'distanceTravelled': distanceTravelled,
      'weeklyEarnings': weeklyEarnings,
      'partnerName': data['displayName'] ?? '',
      'vehicleNumber': data['vehicleNumber'] ?? '',
      'activities': _buildFirestoreActivitiesFromDocs(allDocs),
      'incomingSellerOrders': _buildSellerOrderActivities(incomingSellerOrders),
      'unreadNotificationCount': unreadNotificationCount,
    };
  }

  Map<String, dynamic> _mapMetrics(
    DocumentSnapshot<Map<String, dynamic>> partnerDoc,
    QuerySnapshot<Map<String, dynamic>> activeOrders,
    QuerySnapshot<Map<String, dynamic>> completedToday,
  ) {
    final data = partnerDoc.exists ? partnerDoc.data() ?? {} : {};
    final todayEarnings = completedToday.docs.fold<double>(
      0.0,
      (sum, doc) =>
          sum + ((doc.data()['amount'] as num?)?.toDouble() ?? 0.0) * 0.15,
    );

    return {
      'todayEarnings': (data['totalEarnings'] as num?)?.toDouble() ?? todayEarnings,
      'earningsGrowth': (data['earningsGrowth'] as num?)?.toDouble() ?? 0.0,
      'todayOrdersCount': completedToday.docs.length,
      'activeOrdersCount': activeOrders.docs.length,
      'walletBalance': (data['totalEarnings'] as num?)?.toDouble() ?? 0.0,
      'incentiveEarned': (data['incentiveEarned'] as num?)?.toDouble() ?? 0.0,
      'incentiveTarget': (data['incentiveTarget'] as num?)?.toDouble() ?? 0.0,
      'workingHours': data['workingHours'] ?? '',
      'acceptanceRate': (data['acceptanceRate'] as num?)?.toInt() ?? 0,
      'performanceScore': (data['rating'] as num?)?.toDouble() ?? 0.0,
      'partnerName': data['displayName'] ?? '',
      'vehicleNumber': data['vehicleNumber'] ?? '',
      'isOnline': data['isOnline'] ?? false,
      'activities': _buildFirestoreActivities(activeOrders),
      'incentives': (data['incentives'] as List?) ?? const [],
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

  List<Map<String, dynamic>> _buildFirestoreActivities(QuerySnapshot orders) {
    final activities = <Map<String, dynamic>>[];
    for (final doc in orders.docs) {
      final data = doc.data() as Map<String, dynamic>;
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
        await currentFirestore
            .collection('delivery_partners')
            .doc(currentAuth.currentUser!.uid)
            .set({'isOnline': isOnline, 'updatedAt': FieldValue.serverTimestamp()}, SetOptions(merge: true));

        // sync to riders collection
        await currentFirestore
            .collection('riders')
            .doc(currentAuth.currentUser!.uid)
            .set({'isOnline': isOnline}, SetOptions(merge: true)).catchError((_) {});
      }
    } catch (_) {}
    return isOnline;
  }
}
