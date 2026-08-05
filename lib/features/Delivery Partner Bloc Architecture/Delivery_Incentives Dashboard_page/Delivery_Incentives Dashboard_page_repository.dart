import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'Delivery_Incentives Dashboard_page_service.dart';
import 'Delivery_Incentives Dashboard_page_state.dart';

abstract class DeliveryIncentivesDashboardRepositoryBase {
  Future<DeliveryIncentivesDashboardLoadedState> loadIncentivesData();
  Future<DeliveryIncentivesDashboardLoadedState?> loadCachedIncentives();
  Future<String> exportRewardHistory(
    List<DeliveryIncentivesRewardRecord> records,
  );
  Future<void> clearCache();
}

class DeliveryIncentivesDashboardRepository
    implements DeliveryIncentivesDashboardRepositoryBase {
  static const String _cacheKey = 'dp_incentives_cache_v1';

  final DeliveryIncentivesDashboardServiceBase _service;
  final SharedPreferences? _prefs;

  DeliveryIncentivesDashboardRepository({
    DeliveryIncentivesDashboardServiceBase? service,
    SharedPreferences? prefs,
  })  : _service = service ?? DeliveryIncentivesDashboardService(
            firestore: FirebaseFirestore.instance,
            auth: FirebaseAuth.instance,
        ),
        _prefs = prefs;

  Future<SharedPreferences> _getPrefs() async =>
      _prefs ?? await SharedPreferences.getInstance();

  @override
  Future<DeliveryIncentivesDashboardLoadedState> loadIncentivesData() async {
    try {
      final raw = await _service.fetchIncentivesData();
      await _saveCache(raw);
      return _buildState(raw);
    } catch (_) {
      final cached = await loadCachedIncentives();
      if (cached != null) return cached;
      rethrow;
    }
  }

  Future<void> _saveCache(Map<String, dynamic> raw) async {
    try {
      final prefs = await _getPrefs();
      await prefs.setString(_cacheKey, jsonEncode(raw));
    } catch (_) {
      // Cache writes must never break the primary data flow.
    }
  }

  @override
  Future<DeliveryIncentivesDashboardLoadedState?> loadCachedIncentives() async {
    try {
      final prefs = await _getPrefs();
      final cached = prefs.getString(_cacheKey);
      if (cached == null) return null;
      final raw = jsonDecode(cached) as Map<String, dynamic>;
      return _buildState(raw).copyWith(isFromCache: true);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> clearCache() async {
    final prefs = await _getPrefs();
    await prefs.remove(_cacheKey);
  }

  @override
  Future<String> exportRewardHistory(
    List<DeliveryIncentivesRewardRecord> records,
  ) async {
    final rows = records
        .map(
          (r) => {
            'referenceId': r.referenceId,
            'title': r.title,
            'date': r.date.toIso8601String(),
            'amount': r.amount,
            'type': r.type.name,
            'status': r.status,
          },
        )
        .toList();
    return _service.exportRewardHistory(rows);
  }

  DeliveryIncentivesDashboardLoadedState _buildState(
    Map<String, dynamic> raw,
  ) {
    final rangeMap = <IncentivesDateRange, List<DeliveryIncentivesBonusPoint>>{};
    final ranges = raw['rangePoints'] as Map<String, dynamic>? ?? {};
    ranges.forEach((key, value) {
      final points = (value as List? ?? []).map((e) {
        final map = e as Map<String, dynamic>;
        return DeliveryIncentivesBonusPoint(
          label: map['label'] ?? '',
          value: (map['value'] as num?)?.toDouble() ?? 0.0,
          date: DateTime.tryParse(map['date'] ?? '') ?? DateTime.now(),
        );
      }).toList();
      rangeMap[_rangeFromString(key)] = points;
    });

    final achievements =
        (raw['achievements'] as List? ?? []).map((e) {
          final map = e as Map<String, dynamic>;
          return DeliveryIncentivesAchievement(
            id: map['id'] ?? '',
            title: map['title'] ?? '',
            progress: (map['progress'] as num?)?.toDouble() ?? 0.0,
            target: (map['target'] as num?)?.toDouble() ?? 1.0,
            completed: map['completed'] as bool? ?? false,
          );
        }).toList();

    final donutSlices =
        (raw['donutSlices'] as List? ?? []).map((e) {
          final map = e as Map<String, dynamic>;
          return DeliveryIncentivesDonutSlice(
            category: map['category'] ?? 'others',
            value: (map['value'] as num?)?.toDouble() ?? 0.0,
          );
        }).toList();

    final milestones =
        (raw['milestones'] as List? ?? []).map((e) {
          final map = e as Map<String, dynamic>;
          return DeliveryIncentivesMilestone(
            target: (map['target'] as num?)?.toInt() ?? 0,
            completed: (map['completed'] as num?)?.toInt() ?? 0,
            status: _milestoneStatusFromString(map['status'] ?? 'locked'),
          );
        }).toList();

    final rewards =
        (raw['rewards'] as List? ?? []).map((e) {
          final map = e as Map<String, dynamic>;
          return DeliveryIncentivesRewardRecord(
            id: map['id'] ?? '',
            title: map['title'] ?? '',
            date: DateTime.tryParse(map['date'] ?? '') ?? DateTime.now(),
            amount: (map['amount'] as num?)?.toDouble() ?? 0.0,
            type: _rewardTypeFromString(map['type'] ?? 'others'),
            status: map['status'] ?? 'completed',
            referenceId: map['referenceId'] ?? '',
          );
        }).toList();

    return DeliveryIncentivesDashboardLoadedState(
      walletBalance: (raw['walletBalance'] as num?)?.toDouble() ?? 2450.00,
      todayBonus: (raw['todayBonus'] as num?)?.toDouble() ?? 350.00,
      todayBonusGrowth:
          (raw['todayBonusGrowth'] as num?)?.toDouble() ?? 12.5,
      weeklyBonus: (raw['weeklyBonus'] as num?)?.toDouble() ?? 1250.00,
      weeklyBonusGrowth:
          (raw['weeklyBonusGrowth'] as num?)?.toDouble() ?? 18.6,
      monthlyBonus: (raw['monthlyBonus'] as num?)?.toDouble() ?? 4750.00,
      monthlyBonusGrowth:
          (raw['monthlyBonusGrowth'] as num?)?.toDouble() ?? 24.3,
      targetProgress: (raw['targetProgress'] as num?)?.toDouble() ?? 76.0,
      targetEarned: (raw['targetEarned'] as num?)?.toDouble() ?? 7650.00,
      targetGoal: (raw['targetGoal'] as num?)?.toDouble() ?? 10000.00,
      targetDeadline:
          DateTime.tryParse(raw['targetDeadline'] ?? '') ?? DateTime.now(),
      rangePoints: rangeMap,
      achievements: achievements,
      donutSlices: donutSlices,
      milestones: milestones,
      rewardHistory: rewards,
    );
  }

  IncentivesDateRange _rangeFromString(String value) {
    return switch (value) {
      'today' => IncentivesDateRange.today,
      'last7Days' => IncentivesDateRange.last7Days,
      'thisWeek' => IncentivesDateRange.thisWeek,
      _ => IncentivesDateRange.thisMonth,
    };
  }

  RewardFilterType _rewardTypeFromString(String value) {
    return switch (value) {
      'performance' => RewardFilterType.performance,
      'peakHour' => RewardFilterType.peakHour,
      'incentive' => RewardFilterType.incentive,
      _ => RewardFilterType.others,
    };
  }

  DeliveryIncentivesMilestoneStatus _milestoneStatusFromString(String value) {
    return switch (value) {
      'completed' => DeliveryIncentivesMilestoneStatus.completed,
      'inProgress' => DeliveryIncentivesMilestoneStatus.inProgress,
      _ => DeliveryIncentivesMilestoneStatus.locked,
    };
  }
}
