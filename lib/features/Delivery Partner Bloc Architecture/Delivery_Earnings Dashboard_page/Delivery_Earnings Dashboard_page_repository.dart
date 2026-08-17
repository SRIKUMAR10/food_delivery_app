// Real-Time Firestore Stream Provider Standardized
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'Delivery_Earnings Dashboard_page_service.dart';
import 'Delivery_Earnings Dashboard_page_state.dart';

abstract class DeliveryEarningsDashboardRepositoryBase {
  Future<DeliveryEarningsDashboardState> loadEarningsData();
  Stream<DeliveryEarningsDashboardState> watchEarningsData();
  Future<DeliveryEarningsDashboardState?> loadCachedEarnings();
  Future<DeliveryEarningsDashboardState> withdraw(double amount);
  Future<DeliveryEarningsDashboardState> submitCash({
    required double amount,
    required String method,
  });
  Future<void> clearCache();
  Stream<double> mediaUploadStream();
}

class DeliveryEarningsDashboardRepository
    implements DeliveryEarningsDashboardRepositoryBase {
  static const String _cacheKey = 'dp_earnings_cache_v1';

  final DeliveryEarningsDashboardServiceBase _service;
  final SharedPreferences? _prefs;
  Map<String, dynamic>? _lastRaw;

  DeliveryEarningsDashboardRepository({
    DeliveryEarningsDashboardServiceBase? service,
    SharedPreferences? prefs,
  })  : _service = service ?? DeliveryEarningsDashboardService(
            firestore: FirebaseFirestore.instance,
            auth: FirebaseAuth.instance,
        ),
        _prefs = prefs;

  Future<SharedPreferences> _getPrefs() async =>
      _prefs ?? await SharedPreferences.getInstance();

  @override
  Future<DeliveryEarningsDashboardState> loadEarningsData() async {
    try {
      final raw = await _service.fetchEarningsData();
      _lastRaw = raw;
      await _saveCache(raw);
      return _buildState(raw);
    } catch (_) {
      final cached = await loadCachedEarnings();
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
  Future<DeliveryEarningsDashboardState?> loadCachedEarnings() async {
    try {
      final prefs = await _getPrefs();
      final cached = prefs.getString(_cacheKey);
      if (cached == null) return null;
      final raw = jsonDecode(cached) as Map<String, dynamic>;
      _lastRaw = raw;
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
  Stream<DeliveryEarningsDashboardState> watchEarningsData() {
    return _service.watchEarningsData().map((raw) {
      _lastRaw = raw;
      return _buildState(raw);
    });
  }

  @override
  Stream<double> mediaUploadStream() => _service.simulateMediaUpload();

  @override
  Future<DeliveryEarningsDashboardState> withdraw(double amount) async {
    final result = await _service.withdraw(amount);

    final raw = Map<String, dynamic>.from(_lastRaw ?? const {});
    raw['walletBalance'] = result['walletBalance'];

    final transactions =
        List<Map<String, dynamic>>.from(
          (raw['transactions'] as List? ?? [])
              .map((e) => Map<String, dynamic>.from(e as Map)),
        );
    transactions.insert(
      0,
      Map<String, dynamic>.from(result['transaction'] as Map),
    );
    raw['transactions'] = transactions;

    final withdrawals =
        List<Map<String, dynamic>>.from(
          (raw['withdrawals'] as List? ?? [])
              .map((e) => Map<String, dynamic>.from(e as Map)),
        );
    withdrawals.insert(
      0,
      Map<String, dynamic>.from(result['withdrawal'] as Map),
    );
    raw['withdrawals'] = withdrawals;

    _lastRaw = raw;
    await _saveCache(raw);
    return _buildState(raw);
  }

  @override
  Future<DeliveryEarningsDashboardState> submitCash({
    required double amount,
    required String method,
  }) async {
    final result = await _service.submitCash(amount: amount, method: method);
    if (result['success'] != true) {
      throw Exception(result['message'] ?? 'Cash submission failed');
    }

    final raw = Map<String, dynamic>.from(_lastRaw ?? const {});
    if (result['cashInHand'] != null) raw['cashInHand'] = result['cashInHand'];
    if (result['cashSubmitted'] != null) {
      raw['cashSubmitted'] = result['cashSubmitted'];
    }
    if (result['reconciliationStatus'] != null) {
      raw['reconciliationStatus'] = result['reconciliationStatus'];
    }

    _lastRaw = raw;
    await _saveCache(raw);
    return _buildState(raw);
  }

  DeliveryEarningsDashboardState _buildState(Map<String, dynamic> raw) {
    final rangeMap = <EarningsDateRange, List<DeliveryEarningsPoint>>{};
    final ranges = raw['rangeEarnings'] as Map<String, dynamic>? ?? {};
    ranges.forEach((key, value) {
      final points = (value as List? ?? []).map((e) {
        final map = e as Map<String, dynamic>;
        return DeliveryEarningsPoint(
          label: map['label'] ?? '',
          value: (map['value'] as num?)?.toDouble() ?? 0.0,
          date: DateTime.tryParse(map['date'] ?? '') ?? DateTime.now(),
        );
      }).toList();
      rangeMap[_rangeFromString(key)] = points;
    });

    final transactions =
        (raw['transactions'] as List? ?? []).map((e) {
      final map = e as Map<String, dynamic>;
      return DeliveryEarningsTransaction(
        id: map['id'] ?? '',
        title: map['title'] ?? '',
        date: DateTime.tryParse(map['date'] ?? '') ?? DateTime.now(),
        amount: (map['amount'] as num?)?.toDouble() ?? 0.0,
        type: _transactionTypeFromString(map['type'] ?? 'credit'),
        status: map['status'] ?? 'completed',
      );
    }).toList();

    final withdrawals =
        (raw['withdrawals'] as List? ?? []).map((e) {
      final map = e as Map<String, dynamic>;
      return DeliveryWithdrawalRecord(
        id: map['id'] ?? '',
        amount: (map['amount'] as num?)?.toDouble() ?? 0.0,
        method: map['method'] ?? 'Bank Transfer',
        date: DateTime.tryParse(map['date'] ?? '') ?? DateTime.now(),
        status: map['status'] ?? 'completed',
      );
    }).toList();

    final detailedEarnings =
        (raw['detailedEarnings'] as List? ?? []).map((e) {
      final map = e as Map<String, dynamic>;
      return DeliveryDetailedEarningItem(
        orderId: map['orderId'] ?? '',
        customerName: map['customerName'] ?? '',
        timestamp: DateTime.tryParse(map['timestamp'] ?? '') ?? DateTime.now(),
        paymentMethod: map['paymentMethod'] ?? '',
        isCOD: map['isCOD'] == true,
        baseFare: (map['baseFare'] as num?)?.toDouble() ?? 0.0,
        distanceFare: (map['distanceFare'] as num?)?.toDouble() ?? 0.0,
        surgeFare: (map['surgeFare'] as num?)?.toDouble() ?? 0.0,
        incentive: (map['incentive'] as num?)?.toDouble() ?? 0.0,
        bonus: (map['bonus'] as num?)?.toDouble() ?? 0.0,
        tips: (map['tips'] as num?)?.toDouble() ?? 0.0,
        cancellationCompensation:
            (map['cancellationCompensation'] as num?)?.toDouble() ?? 0.0,
        totalEarnings: (map['totalEarnings'] as num?)?.toDouble() ?? 0.0,
      );
    }).toList();

    return DeliveryEarningsDashboardState(
      status: DeliveryEarningsStatus.loaded,
      totalEarnings: (raw['totalEarnings'] as num?)?.toDouble() ?? 0.0,
      todayEarnings: (raw['todayEarnings'] as num?)?.toDouble() ?? 0.0,
      weeklyEarnings: (raw['weeklyEarnings'] as num?)?.toDouble() ?? 0.0,
      monthlyEarnings: (raw['monthlyEarnings'] as num?)?.toDouble() ?? 0.0,
      earningsGrowth: (raw['earningsGrowth'] as num?)?.toDouble() ?? 0.0,
      walletBalance: (raw['walletBalance'] as num?)?.toDouble() ?? 0.0,
      pendingWithdrawal:
          (raw['pendingWithdrawal'] as num?)?.toDouble() ?? 0.0,
      totalWithdrawn: (raw['totalWithdrawn'] as num?)?.toDouble() ?? 0.0,
      todayDeliveries: (raw['todayDeliveries'] as num?)?.toInt() ?? 0,
      weeklyDeliveries: (raw['weeklyDeliveries'] as num?)?.toInt() ?? 0,
      monthlyDeliveries: (raw['monthlyDeliveries'] as num?)?.toInt() ?? 0,
      totalDeliveries: (raw['totalDeliveries'] as num?)?.toInt() ?? 0,
      pendingEarnings: (raw['pendingEarnings'] as num?)?.toDouble() ?? 0.0,
      cashInHand: (raw['cashInHand'] as num?)?.toDouble() ?? 0.0,
      cashCollected: (raw['cashCollected'] as num?)?.toDouble() ?? 0.0,
      cashSubmitted: (raw['cashSubmitted'] as num?)?.toDouble() ?? 0.0,
      reconciliationStatus: raw['reconciliationStatus'] ?? 'balanced',
      detailedEarnings: detailedEarnings,
      rangeEarnings: rangeMap,
      transactions: transactions,
      withdrawalHistory: withdrawals,
    );
  }

  EarningsDateRange _rangeFromString(String value) {
    return switch (value) {
      'today' => EarningsDateRange.today,
      'last7Days' => EarningsDateRange.last7Days,
      'thisWeek' => EarningsDateRange.thisWeek,
      _ => EarningsDateRange.thisMonth,
    };
  }

  EarningsTransactionType _transactionTypeFromString(String value) {
    return switch (value) {
      'debit' => EarningsTransactionType.debit,
      'withdrawal' => EarningsTransactionType.withdrawal,
      _ => EarningsTransactionType.credit,
    };
  }
}
