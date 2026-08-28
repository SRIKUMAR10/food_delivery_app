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
          return await _mapIncentivesFromDoc(partnerDoc);
        }
      }
    } catch (_) {}

    return _buildEmptyIncentivesData();
  }

  @override
  Stream<Map<String, dynamic>> watchIncentivesData() {
    final uid = _auth?.currentUser?.uid;
    final fs = _firestore;
    if (uid == null || fs == null) {
      return Stream.value(_buildEmptyIncentivesData());
    }
    return fs
        .collection('delivery_partners')
        .doc(uid)
        .snapshots(includeMetadataChanges: true)
        .asyncMap((doc) async {
      if (!doc.exists) return _buildEmptyIncentivesData();
      return await _mapIncentivesFromDoc(doc);
    }).handleError((e) {
      return _buildEmptyIncentivesData();
    });
  }

  Future<Map<String, dynamic>> _mapIncentivesFromDoc(DocumentSnapshot<Map<String, dynamic>> partnerDoc) async {
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
    final currentStreak = (data['currentStreakDays'] as num?)?.toInt() ?? 0;

    final todayBonus = todayDeliveries >= 10 ? 300.0 : (todayDeliveries * 30.0);
    final weeklyBonus = weeklyDeliveries >= 50 ? 1500.0 : (weeklyDeliveries * 30.0);

    // Query real rewards from subcollection
    List<Map<String, dynamic>> rewardsList = [];
    try {
      final rewardsSnapshot = await partnerDoc.reference
          .collection('incentives_rewards')
          .orderBy('date', descending: true)
          .limit(20)
          .get();
      rewardsList = rewardsSnapshot.docs.map((d) {
        final rData = d.data();
        return {
          'id': d.id,
          'title': rData['title'] ?? 'Incentive Reward',
          'date': rData['date'] ?? DateTime.now().toIso8601String(),
          'amount': (rData['amount'] as num?)?.toDouble() ?? 0.0,
          'type': rData['type'] ?? 'performance',
          'status': rData['status'] ?? 'completed',
          'referenceId': rData['referenceId'] ?? 'REF-${d.id.substring(0, 4)}',
        };
      }).toList();
    } catch (_) {}

    return {
      'walletBalance': walletBalance,
      'todayBonus': todayBonus,
      'todayBonusGrowth': 0.0,
      'weeklyBonus': weeklyBonus,
      'weeklyBonusGrowth': 0.0,
      'monthlyBonus': bonusEarnings + incentiveEarnings,
      'monthlyBonusGrowth': 0.0,
      'targetProgress': ((todayDeliveries % 10) / 10.0 * 100).clamp(0.0, 100.0),
      'targetEarned': bonusEarnings,
      'targetGoal': 10000.00,
      'todayDeliveries': todayDeliveries,
      'weeklyDeliveries': weeklyDeliveries,
      'totalDeliveries': totalDeliveries,
      'currentStreakDays': currentStreak,
      'targetDeadline': DateTime.now().add(const Duration(days: 14)).toIso8601String(),
      'rangePoints': _buildRangePoints(todayDeliveries, weeklyDeliveries, totalDeliveries),
      'achievements': _buildAchievementsList(todayDeliveries, weeklyDeliveries, currentStreak),
      'donutSlices': _buildDonutSlices(bonusEarnings, incentiveEarnings, todayBonus),
      'milestones': _buildMilestonesList(todayDeliveries),
      'rewards': rewardsList,
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

  Map<String, dynamic> _buildEmptyIncentivesData() {
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
      'todayDeliveries': 0,
      'weeklyDeliveries': 0,
      'totalDeliveries': 0,
      'currentStreakDays': 0,
      'targetDeadline': DateTime.now().add(const Duration(days: 14)).toIso8601String(),
      'rangePoints': _buildRangePoints(0, 0, 0),
      'achievements': _buildAchievementsList(0, 0, 0),
      'donutSlices': _buildDonutSlices(0.0, 0.0, 0.0),
      'milestones': _buildMilestonesList(0),
      'rewards': <Map<String, dynamic>>[],
    };
  }

  Map<String, dynamic> _buildRangePoints(int today, int weekly, int total) {
    final now = DateTime.now();
    return {
      'today': [
        {'label': 'Today', 'value': (today * 30.0), 'date': now.toIso8601String()},
      ],
      'last7Days': [
        {'label': '7 Days', 'value': (weekly * 30.0), 'date': now.toIso8601String()},
      ],
      'thisWeek': [
        {'label': 'Week', 'value': (weekly * 30.0), 'date': now.toIso8601String()},
      ],
      'thisMonth': [
        {'label': 'Month', 'value': (total * 30.0), 'date': now.toIso8601String()},
      ],
    };
  }

  List<Map<String, dynamic>> _buildDonutSlices(double bonus, double incentive, double todayBonus) {
    if (bonus == 0.0 && incentive == 0.0 && todayBonus == 0.0) {
      return [];
    }
    return [
      if (todayBonus > 0) {'category': 'todayBonus', 'value': todayBonus},
      if (bonus > 0) {'category': 'performance', 'value': bonus},
      if (incentive > 0) {'category': 'milestone', 'value': incentive},
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
