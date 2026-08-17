import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

abstract class DeliveryIncentivesDashboardServiceBase {
  Future<Map<String, dynamic>> fetchIncentivesData();
  Stream<Map<String, dynamic>> watchIncentivesData();
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
          return _mapIncentivesFromDoc(partnerDoc);
        }
      }
    } catch (_) {}

    return _buildFullMockData();
  }

  @override
  Stream<Map<String, dynamic>> watchIncentivesData() {
    final uid = _auth?.currentUser?.uid;
    final fs = _firestore;
    if (uid == null || fs == null) {
      return Stream.value(_buildFullMockData());
    }
    return fs
        .collection('delivery_partners')
        .doc(uid)
        .snapshots(includeMetadataChanges: true)
        .map((doc) {
      if (!doc.exists) return _buildFullMockData();
      return _mapIncentivesFromDoc(doc);
    }).handleError((e) {
      return _buildFullMockData();
    });
  }

  Map<String, dynamic> _mapIncentivesFromDoc(DocumentSnapshot<Map<String, dynamic>> partnerDoc) {
    final data = partnerDoc.data() ?? {};
    final walletBalance = (data['walletBalance'] as num?)?.toDouble() ??
        (data['totalEarnings'] as num?)?.toDouble() ??
        0.0;
    final totalEarnings =
        (data['totalEarnings'] as num?)?.toDouble() ?? 0.0;
    final bonusEarnings =
        (data['bonusEarnings'] as num?)?.toDouble() ?? 0.0;
    final incentiveEarnings =
        (data['incentiveEarnings'] as num?)?.toDouble() ?? 0.0;
    final totalDeliveries = (data['totalDeliveries'] as num?)?.toInt() ?? 0;
    final todayDeliveries = (data['todayDeliveries'] as num?)?.toInt() ?? 0;
    final weeklyDeliveries = (data['weeklyDeliveries'] as num?)?.toInt() ?? 0;
    final currentStreak = (data['currentStreakDays'] as num?)?.toInt() ?? 1;

    final todayBonus = todayDeliveries >= 10 ? 300.0 : (todayDeliveries * 30.0);
    final weeklyBonus = weeklyDeliveries >= 50 ? 1500.0 : (weeklyDeliveries * 30.0);

    return {
      'walletBalance': walletBalance,
      'todayBonus': todayBonus,
      'todayBonusGrowth': 12.5,
      'weeklyBonus': weeklyBonus,
      'weeklyBonusGrowth': 18.6,
      'monthlyBonus': bonusEarnings + incentiveEarnings,
      'monthlyBonusGrowth': 24.3,
      'targetProgress': ((todayDeliveries % 10) / 10.0 * 100).clamp(0.0, 100.0),
      'targetEarned': bonusEarnings,
      'targetGoal': 10000.00,
      'todayDeliveries': todayDeliveries,
      'weeklyDeliveries': weeklyDeliveries,
      'totalDeliveries': totalDeliveries,
      'currentStreakDays': currentStreak,
      'targetDeadline': DateTime.now().add(const Duration(days: 14)).toIso8601String(),
      'rangePoints': _buildMockRangePoints(),
      'achievements': _buildAchievementsList(todayDeliveries, weeklyDeliveries, currentStreak),
      'donutSlices': _buildMockDonutSlices(),
      'milestones': _buildMilestonesList(todayDeliveries),
      'rewards': _buildMockRewards(),
    };
  }

  List<Map<String, dynamic>> _buildAchievementsList(int today, int weekly, int streak) {
    return [
      {'id': 'daily_target', 'title': 'Daily Target (10 Deliveries)', 'progress': today.toDouble(), 'target': 10.0, 'completed': today >= 10},
      {'id': 'weekly_target', 'title': 'Weekly Target (50 Deliveries)', 'progress': weekly.toDouble(), 'target': 50.0, 'completed': weekly >= 50},
      {'id': 'streak_star', 'title': 'Streak Champion', 'progress': streak.toDouble(), 'target': 7.0, 'completed': streak >= 7},
      {'id': 'delivery_master', 'title': 'Delivery Master', 'progress': today.toDouble(), 'target': 20.0, 'completed': today >= 20},
    ];
  }

  List<Map<String, dynamic>> _buildMilestonesList(int completed) {
    return [
      {'target': 10, 'completed': completed >= 10 ? 10 : completed, 'status': completed >= 10 ? 'completed' : 'inProgress'},
      {'target': 25, 'completed': completed >= 25 ? 25 : completed, 'status': completed >= 25 ? 'completed' : 'inProgress'},
      {'target': 50, 'completed': completed >= 50 ? 50 : completed, 'status': completed >= 50 ? 'completed' : 'inProgress'},
      {'target': 100, 'completed': completed >= 100 ? 100 : completed, 'status': completed >= 100 ? 'completed' : 'inProgress'},
      {'target': 200, 'completed': 0, 'status': 'locked'},
    ];
  }

  Map<String, dynamic> _buildFullMockData() {
    return {
      'walletBalance': 2450.00,
      'todayBonus': 350.00,
      'todayBonusGrowth': 12.5,
      'weeklyBonus': 1250.00,
      'weeklyBonusGrowth': 18.6,
      'monthlyBonus': 4750.00,
      'monthlyBonusGrowth': 24.3,
      'targetProgress': 76.0,
      'targetEarned': 7650.00,
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
      {'id': 'speedy', 'title': 'Speed Master', 'progress': 8.0, 'target': 10.0, 'completed': false},
      {'id': 'weekend', 'title': 'Weekend Hero', 'progress': 5.0, 'target': 5.0, 'completed': true},
      {'id': 'star', 'title': 'Five Star Driver', 'progress': 48.0, 'target': 50.0, 'completed': false},
    ];
  }

  List<Map<String, dynamic>> _buildMockDonutSlices() {
    return [
      {'category': 'peakHour', 'value': 1850.00},
      {'category': 'milestone', 'value': 1500.00},
      {'category': 'performance', 'value': 1000.00},
      {'category': 'others', 'value': 400.00},
    ];
  }

  List<Map<String, dynamic>> _buildMockMilestones(int completed) {
    return [
      {'target': 10, 'completed': completed >= 10 ? 10 : completed, 'status': completed >= 10 ? 'completed' : 'inProgress'},
      {'target': 25, 'completed': completed >= 25 ? 25 : completed, 'status': completed >= 25 ? 'completed' : 'inProgress'},
      {'target': 50, 'completed': completed >= 50 ? 50 : completed, 'status': completed >= 50 ? 'completed' : 'inProgress'},
      {'target': 100, 'completed': completed >= 100 ? 100 : completed, 'status': completed >= 100 ? 'completed' : 'inProgress'},
      {'target': 200, 'completed': 0, 'status': 'locked'},
    ];
  }

  List<Map<String, dynamic>> _buildMockRewards() {
    final now = DateTime.now();
    return List.generate(
      16,
      (i) => {
        'id': 'inc_rw_${i + 1}',
        'title': i.isEven ? 'Peak Hour Bonus' : 'Milestone Reward',
        'date': now.subtract(Duration(days: i)).toIso8601String(),
        'amount': (80 + (i * 25)).toDouble(),
        'type': i.isEven
            ? 'peakHour'
            : (i % 3 == 0 ? 'milestone' : 'performance'),
        'status': 'completed',
        'referenceId': 'REF-${1040 + i}',
      },
    );
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
