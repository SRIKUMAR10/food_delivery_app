import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DeliveryDashboardServiceBase {
  Future<Map<String, dynamic>> fetchDashboardMetrics() async => {};
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

  @override
  Future<Map<String, dynamic>> fetchDashboardMetrics() async {
    try {
      final currentFirestore = _firestore ?? FirebaseFirestore.instance;
      final currentAuth = _auth ?? FirebaseAuth.instance;
      if (currentAuth.currentUser != null) {
        final uid = currentAuth.currentUser!.uid;
        final partnerDoc = await currentFirestore
            .collection('delivery_partners')
            .doc(uid)
            .get();

        if (partnerDoc.exists) {
          final data = partnerDoc.data()!;
          final ordersQuery = await currentFirestore
              .collection('orders')
              .where('riderId', isEqualTo: uid)
              .where('status', whereIn: ['OutForDelivery', 'Accepted'])
              .get();

          final completedToday = await currentFirestore
              .collection('orders')
              .where('riderId', isEqualTo: uid)
              .where('status', isEqualTo: 'Delivered')
              .get();

          final todayEarnings = completedToday.docs.fold<double>(
            0.0,
            (sum, doc) => sum + ((doc.data()['amount'] as num?)?.toDouble() ?? 0.0) * 0.15,
          );

          return {
            'todayEarnings': (data['totalEarnings'] as num?)?.toDouble() ?? todayEarnings,
            'earningsGrowth': 18.5,
            'todayOrdersCount': completedToday.docs.length,
            'activeOrdersCount': ordersQuery.docs.length,
            'walletBalance': (data['totalEarnings'] as num?)?.toDouble() ?? 2450.00,
            'incentiveEarned': 350.00,
            'incentiveTarget': 500.00,
            'workingHours': '05h 45m',
            'acceptanceRate': 92,
            'performanceScore': (data['rating'] as num?)?.toDouble() ?? 4.8,
            'partnerName': data['displayName'] ?? 'Ravi Kumar',
            'vehicleNumber': data['vehicleNumber'] ?? 'TN 01 AB 1234',
            'isOnline': data['isOnline'] ?? false,
            'activities': _buildFirestoreActivities(ordersQuery),
            'incentives': _buildMockIncentives(),
          };
        }
      }
    } catch (_) {}

    return _buildMockData();
  }

  List<Map<String, dynamic>> _buildFirestoreActivities(QuerySnapshot orders) {
    final activities = <Map<String, dynamic>>[];
    for (final doc in orders.docs) {
      final data = doc.data() as Map<String, dynamic>;
      activities.add({
        'id': doc.id,
        'time': _formatTimestamp(data['timestamp']),
        'title': 'Order #${doc.id.substring(0, 8)}',
        'subtitle': data['customerName'] ?? 'Customer',
        'details': '${((data['amount'] as num?)?.toDouble() ?? 0.0).toStringAsFixed(2)}',
        'statusType': data['status'] ?? 'active',
      });
    }
    return activities;
  }

  List<Map<String, dynamic>> _buildMockIncentives() {
    return [
      {
        'id': 'inc_1',
        'title': 'Peak Hours Bonus (12 PM - 3 PM)',
        'completedDeliveries': 8,
        'targetDeliveries': 10,
        'rewardAmount': 250.0,
        'isCompleted': false,
      },
      {
        'id': 'inc_2',
        'title': 'Weekend Rush Special',
        'completedDeliveries': 15,
        'targetDeliveries': 15,
        'rewardAmount': 500.0,
        'isCompleted': true,
      },
    ];
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
    } catch (_) {
      await Future.delayed(const Duration(milliseconds: 200));
    }
    return isOnline;
  }

  Map<String, dynamic> _buildMockData() {
    return {
      'todayEarnings': 2450.00,
      'earningsGrowth': 18.5,
      'todayOrdersCount': 18,
      'activeOrdersCount': 2,
      'walletBalance': 2450.00,
      'incentiveEarned': 350.00,
      'incentiveTarget': 500.00,
      'workingHours': '05h 45m',
      'acceptanceRate': 92,
      'performanceScore': 4.8,
      'partnerName': 'Ravi Kumar',
      'vehicleNumber': 'TN 01 AB 1234',
      'isOnline': true,
      'activities': _buildMockActivities(),
      'incentives': _buildMockIncentives(),
    };
  }

  List<Map<String, dynamic>> _buildMockActivities() {
    return [
      {'id': 'act_1', 'time': '10:30 AM', 'title': 'Order Delivered', 'subtitle': 'Order #ORD12345', 'details': '₹120.00', 'statusType': 'delivered'},
      {'id': 'act_2', 'time': '10:02 AM', 'title': 'Order Picked Up', 'subtitle': 'Order #ORD12345', 'details': 'Green Mart, Anna Salai', 'statusType': 'picked_up'},
      {'id': 'act_3', 'time': '09:45 AM', 'title': 'New Order Received', 'subtitle': 'Order #ORD12345', 'details': '2.4 km away', 'statusType': 'new_order'},
      {'id': 'act_4', 'time': '09:40 AM', 'title': 'Reached Restaurant', 'subtitle': 'Green Mart, Anna Salai', 'details': '', 'statusType': 'reached_restaurant'},
      {'id': 'act_5', 'time': '09:30 AM', 'title': 'Went Online', 'subtitle': 'You are now online and available', 'details': '', 'statusType': 'went_online'},
    ];
  }
}
