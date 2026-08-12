import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

abstract class DeliveryIncentivesDashboardServiceBase {
  Future<Map<String, dynamic>> fetchIncentivesData();
  Future<String> exportRewardHistory(List<Map<String, dynamic>> records);
}

class DeliveryIncentivesDashboardService
    implements DeliveryIncentivesDashboardServiceBase {
  final FirebaseFirestore? _firestoreParam;
  final FirebaseAuth? _authParam;

  DeliveryIncentivesDashboardService({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  })  : _firestoreParam = firestore,
        _authParam = auth;

  FirebaseFirestore? get _firestore =>
      _firestoreParam ?? (FirebaseAuth.instance.app != null ? FirebaseFirestore.instance : null);
  FirebaseAuth? get _auth =>
      _authParam ?? (FirebaseAuth.instance.app != null ? FirebaseAuth.instance : null);

  @override
  Future<Map<String, dynamic>> fetchIncentivesData() async {
    try {
      final uid = _auth?.currentUser?.uid;
      if (uid != null && _firestore != null) {
        final partnerDoc = await _firestore!
            .collection('delivery_partners')
            .doc(uid)
            .get();

        if (partnerDoc.exists) {
          final data = partnerDoc.data()!;
          final totalEarnings =
              (data['totalEarnings'] as num?)?.toDouble() ?? 0.0;
          final totalDeliveries = data['totalDeliveries'] ?? 0;

          final todayQuery = await _firestore!
              .collection('orders')
              .where('riderId', isEqualTo: uid)
              .where('status', isEqualTo: 'Delivered')
              .get();

          final todayStart = DateTime(
            DateTime.now().year,
            DateTime.now().month,
            DateTime.now().day,
          );
          final todayDeliveries = todayQuery.docs.where((doc) {
            final ts = doc.data()['timestamp'] as Timestamp?;
            return ts != null && ts.toDate().isAfter(todayStart);
          }).length;

          final todayBonus = todayDeliveries * 25.0;
          final weeklyDeliveries = totalDeliveries;

          return {
            'walletBalance': totalEarnings,
            'todayBonus': todayBonus,
            'todayBonusGrowth': 12.5,
            'weeklyBonus': weeklyDeliveries * 25.0,
            'weeklyBonusGrowth': 18.6,
            'monthlyBonus': totalDeliveries * 25.0,
            'monthlyBonusGrowth': 24.3,
            'targetProgress': ((totalDeliveries % 100) / 100.0 * 100),
            'targetEarned': totalDeliveries * 25.0,
            'targetGoal': 10000.00,
            'targetDeadline': DateTime(2026, 8, 31).toIso8601String(),
            'rangePoints': _buildMockRangePoints(),
            'achievements': _buildMockAchievements(),
            'donutSlices': _buildMockDonutSlices(),
            'milestones': _buildMockMilestones(totalDeliveries),
            'rewards': _buildMockRewards(),
          };
        }
      }
    } catch (_) {}

    return _buildFullMockData();
  }

  Map<String, dynamic> _buildFullMockData() {
    return {
      'walletBalance': 0.0,
      'todayBonus': 0.0,
      'todayBonusGrowth': 0.0,
      'weeklyBonus': 0.0,
      'weeklyBonusGrowth': 0.0,
      'monthlyBonus': 0.0,
      'monthlyBonusGrowth': 0.0,
      'targetProgress': 0.0,
      'targetEarned': 0.0,
      'targetGoal': 10000.00,
      'targetDeadline': DateTime(2026, 8, 31).toIso8601String(),
      'rangePoints': _buildMockRangePoints(),
      'achievements': _buildMockAchievements(),
      'donutSlices': _buildMockDonutSlices(),
      'milestones': _buildMockMilestones(0),
      'rewards': _buildMockRewards(),
    };
  }

  Map<String, dynamic> _buildMockRangePoints() {
    final now = DateTime.now();
    return {
      'today': [
        {'label': '6AM', 'value': 40.0, 'date': now.toIso8601String()},
        {'label': '9AM', 'value': 55.0, 'date': now.toIso8601String()},
        {'label': '12PM', 'value': 35.0, 'date': now.toIso8601String()},
        {'label': '3PM', 'value': 70.0, 'date': now.toIso8601String()},
        {'label': '6PM', 'value': 90.0, 'date': now.toIso8601String()},
        {'label': '9PM', 'value': 60.0, 'date': now.toIso8601String()},
      ],
      'last7Days': [
        {'label': 'Mon', 'value': 210.0, 'date': now.toIso8601String()},
        {'label': 'Tue', 'value': 240.0, 'date': now.toIso8601String()},
        {'label': 'Wed', 'value': 190.0, 'date': now.toIso8601String()},
        {'label': 'Thu', 'value': 300.0, 'date': now.toIso8601String()},
        {'label': 'Fri', 'value': 280.0, 'date': now.toIso8601String()},
        {'label': 'Sat', 'value': 350.0, 'date': now.toIso8601String()},
        {'label': 'Sun', 'value': 320.0, 'date': now.toIso8601String()},
      ],
      'thisWeek': [
        {'label': 'Mon', 'value': 210.0, 'date': now.toIso8601String()},
        {'label': 'Tue', 'value': 240.0, 'date': now.toIso8601String()},
        {'label': 'Wed', 'value': 190.0, 'date': now.toIso8601String()},
        {'label': 'Thu', 'value': 300.0, 'date': now.toIso8601String()},
        {'label': 'Fri', 'value': 280.0, 'date': now.toIso8601String()},
        {'label': 'Sat', 'value': 350.0, 'date': now.toIso8601String()},
        {'label': 'Sun', 'value': 320.0, 'date': now.toIso8601String()},
      ],
      'thisMonth': [
        {'label': 'W1', 'value': 950.0, 'date': now.toIso8601String()},
        {'label': 'W2', 'value': 1100.0, 'date': now.toIso8601String()},
        {'label': 'W3', 'value': 1250.0, 'date': now.toIso8601String()},
        {'label': 'W4', 'value': 1450.0, 'date': now.toIso8601String()},
      ],
    };
  }

  List<Map<String, dynamic>> _buildMockAchievements() {
    return [
      {'id': 'early_bird', 'title': 'Early Bird', 'progress': 1.0, 'target': 1.0, 'completed': true},
      {'id': 'consistent_star', 'title': 'Consistent Star', 'progress': 15.0, 'target': 20.0, 'completed': false},
      {'id': 'weekend_warrior', 'title': 'Weekend Warrior', 'progress': 10.0, 'target': 25.0, 'completed': false},
      {'id': 'delivery_master', 'title': 'Delivery Master', 'progress': 62.0, 'target': 100.0, 'completed': false},
    ];
  }

  List<Map<String, dynamic>> _buildMockDonutSlices() {
    return [
      {'category': 'performance', 'value': 2100.00},
      {'category': 'peakHour', 'value': 1350.00},
      {'category': 'incentive', 'value': 900.00},
      {'category': 'others', 'value': 400.00},
    ];
  }

  List<Map<String, dynamic>> _buildMockMilestones(int completed) {
    return [
      {'target': 10, 'completed': completed >= 10 ? 10 : completed, 'status': completed >= 10 ? 'completed' : 'inProgress'},
      {'target': 25, 'completed': completed >= 25 ? 25 : completed, 'status': completed >= 25 ? 'completed' : 'inProgress'},
      {'target': 50, 'completed': completed >= 50 ? 50 : completed, 'status': completed >= 50 ? 'completed' : 'inProgress'},
      {'target': 100, 'completed': completed, 'status': completed >= 100 ? 'completed' : 'inProgress'},
      {'target': 200, 'completed': 0, 'status': 'locked'},
    ];
  }

  List<Map<String, dynamic>> _buildMockRewards() {
    final now = DateTime.now();
    return [
      {'id': 'inc_rw_1', 'title': 'Peak Hour Bonus', 'date': now.toIso8601String(), 'amount': 120.0, 'type': 'peakHour', 'status': 'completed', 'referenceId': 'REF-1040'},
      {'id': 'inc_rw_2', 'title': 'On-Time Delivery Incentive', 'date': now.toIso8601String(), 'amount': 85.0, 'type': 'incentive', 'status': 'completed', 'referenceId': 'REF-1041'},
      {'id': 'inc_rw_3', 'title': 'Performance Bonus', 'date': now.toIso8601String(), 'amount': 200.0, 'type': 'performance', 'status': 'completed', 'referenceId': 'REF-1042'},
      {'id': 'inc_rw_4', 'title': 'Weekend Surge Bonus', 'date': now.toIso8601String(), 'amount': 175.0, 'type': 'peakHour', 'status': 'completed', 'referenceId': 'REF-1043'},
      {'id': 'inc_rw_5', 'title': 'Night Shift Bonus', 'date': now.toIso8601String(), 'amount': 110.0, 'type': 'others', 'status': 'completed', 'referenceId': 'REF-1044'},
    ];
  }

  @override
  Future<String> exportRewardHistory(
    List<Map<String, dynamic>> records,
  ) async {
    await Future.delayed(const Duration(milliseconds: 150));
    final buffer = StringBuffer('Reference,Title,Date,Amount,Type,Status\n');
    for (final record in records) {
      buffer.writeln(
        '${record['referenceId']},'
        '${record['title']},'
        '${record['date']},'
        '${record['amount']},'
        '${record['type']},'
        '${record['status']}',
      );
    }
    return buffer.toString();
  }
}
