import 'dart:async';
import 'package:flutter_dotenv/flutter_dotenv.dart';

abstract class DeliveryEarningsDashboardServiceBase {
  Future<Map<String, dynamic>> fetchEarningsData();
  Future<Map<String, dynamic>> withdraw(double amount);
  Stream<double> simulateMediaUpload();
}

class DeliveryEarningsDashboardService
    implements DeliveryEarningsDashboardServiceBase {
  static const String _apiUrlKey = 'EARNINGS_API_BASE_URL';
  static const Duration _cacheLifetime = Duration(minutes: 5);

  Map<String, dynamic>? _cache;
  DateTime? _cacheTimestamp;

  String get apiBaseUrl => _safeEnv(
        _apiUrlKey,
        fallback: 'https://api.foodgo.example/v1',
      );

  String _safeEnv(String key, {required String fallback}) {
    try {
      return dotenv.maybeGet(key) ?? fallback;
    } catch (_) {
      return fallback;
    }
  }

  @override
  Future<Map<String, dynamic>> fetchEarningsData() async {
    final now = DateTime.now();
    if (_cache != null &&
        _cacheTimestamp != null &&
        now.difference(_cacheTimestamp!) < _cacheLifetime) {
      return _cache!;
    }

    await Future.delayed(const Duration(milliseconds: 300));

    final data = <String, dynamic>{
      'totalEarnings': 12850.00,
      'todayEarnings': 2450.00,
      'weeklyEarnings': 12850.00,
      'monthlyEarnings': 48900.00,
      'earningsGrowth': 18.5,
      'walletBalance': 12850.00,
      'pendingWithdrawal': 1200.00,
      'totalWithdrawn': 48250.00,
      'rangeEarnings': {
        'today': [
          _point('6AM', 180.0, 0),
          _point('9AM', 220.0, 1),
          _point('12PM', 150.0, 2),
          _point('3PM', 320.0, 3),
          _point('6PM', 410.0, 4),
          _point('9PM', 380.0, 5),
          _point('10PM', 290.0, 6),
          _point('11PM', 500.0, 7),
        ],
        'last7Days': [
          _point('Mon', 1250.0, 0),
          _point('Tue', 1500.0, 1),
          _point('Wed', 1700.0, 2),
          _point('Thu', 1800.0, 3),
          _point('Fri', 2100.0, 4),
          _point('Sat', 2200.0, 5),
          _point('Sun', 2300.0, 6),
        ],
        'thisWeek': [
          _point('Mon', 1250.0, 0),
          _point('Tue', 1500.0, 1),
          _point('Wed', 1700.0, 2),
          _point('Thu', 1800.0, 3),
          _point('Fri', 2100.0, 4),
          _point('Sat', 2200.0, 5),
          _point('Sun', 2300.0, 6),
        ],
        'thisMonth': [
          _point('W1', 9800.0, 0),
          _point('W2', 12050.0, 1),
          _point('W3', 12850.0, 2),
          _point('W4', 14200.0, 3),
        ],
      },
      'transactions': [
        {
          'id': 'tx_1',
          'title': 'Delivery Earnings',
          'date': DateTime.now().toIso8601String(),
          'amount': 240.00,
          'type': 'credit',
          'status': 'completed',
        },
        {
          'id': 'tx_2',
          'title': 'Peak Hour Bonus',
          'date': DateTime.now()
              .subtract(const Duration(hours: 2))
              .toIso8601String(),
          'amount': 250.00,
          'type': 'credit',
          'status': 'completed',
        },
        {
          'id': 'tx_3',
          'title': 'Wallet Withdrawal',
          'date': DateTime.now()
              .subtract(const Duration(days: 1))
              .toIso8601String(),
          'amount': 500.00,
          'type': 'withdrawal',
          'status': 'completed',
        },
        {
          'id': 'tx_4',
          'title': 'Weekend Incentive',
          'date': DateTime.now()
              .subtract(const Duration(days: 2))
              .toIso8601String(),
          'amount': 500.00,
          'type': 'credit',
          'status': 'pending',
        },
        {
          'id': 'tx_5',
          'title': 'Order Cancellation Adjustment',
          'date': DateTime.now()
              .subtract(const Duration(days: 3))
              .toIso8601String(),
          'amount': 40.00,
          'type': 'debit',
          'status': 'completed',
        },
      ],
      'withdrawals': [
        {
          'id': 'wd_1',
          'amount': 2000.00,
          'method': 'Bank Transfer',
          'date': DateTime.now()
              .subtract(const Duration(days: 5))
              .toIso8601String(),
          'status': 'completed',
        },
        {
          'id': 'wd_2',
          'amount': 1500.00,
          'method': 'UPI',
          'date': DateTime.now()
              .subtract(const Duration(days: 12))
              .toIso8601String(),
          'status': 'completed',
        },
        {
          'id': 'wd_3',
          'amount': 1200.00,
          'method': 'Bank Transfer',
          'date': DateTime.now().toIso8601String(),
          'status': 'processing',
        },
      ],
    };

    _cache = data;
    _cacheTimestamp = now;
    return data;
  }

  Map<String, dynamic> _point(String label, double value, int dayOffset) {
    return {
      'label': label,
      'value': value,
      'date': DateTime.now()
          .subtract(Duration(days: dayOffset))
          .toIso8601String(),
    };
  }

  @override
  Future<Map<String, dynamic>> withdraw(double amount) async {
    await Future.delayed(const Duration(milliseconds: 250));
    final currentBalance =
        ((_cache?['walletBalance'] as num?) ?? 12850.00).toDouble();
    final newBalance = currentBalance - amount;

    if (_cache != null) {
      _cache!['walletBalance'] = newBalance;
    }

    final now = DateTime.now();
    return {
      'success': true,
      'walletBalance': newBalance,
      'withdrawal': {
        'id': 'wd_${now.millisecondsSinceEpoch}',
        'amount': amount,
        'method': 'Bank Transfer',
        'date': now.toIso8601String(),
        'status': 'processing',
      },
      'transaction': {
        'id': 'tx_${now.millisecondsSinceEpoch}',
        'title': 'Withdrawal to Bank',
        'date': now.toIso8601String(),
        'amount': amount,
        'type': 'withdrawal',
        'status': 'processing',
      },
    };
  }

  @override
  Stream<double> simulateMediaUpload() async* {
    const int chunks = 10;
    for (var i = 1; i <= chunks; i++) {
      await Future<void>.delayed(const Duration(milliseconds: 20));
      yield i / chunks;
    }
  }
}
