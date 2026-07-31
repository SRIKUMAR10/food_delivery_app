import 'package:flutter_dotenv/flutter_dotenv.dart';

abstract class DeliveryIncentivesDashboardServiceBase {
  Future<Map<String, dynamic>> fetchIncentivesData();
  Future<String> exportRewardHistory(List<Map<String, dynamic>> records);
}

class DeliveryIncentivesDashboardService
    implements DeliveryIncentivesDashboardServiceBase {
  static const String _apiUrlKey = 'INCENTIVES_API_BASE_URL';
  static const Duration _cacheLifetime = Duration(minutes: 5);

  Map<String, dynamic>? _cache;
  DateTime? _cacheTimestamp;

  String get apiBaseUrl => _safeEnv(
        _apiUrlKey,
        fallback: 'https://api.foodgo.example/v1/incentives',
      );

  String _safeEnv(String key, {required String fallback}) {
    try {
      return dotenv.maybeGet(key) ?? fallback;
    } catch (_) {
      return fallback;
    }
  }

  @override
  Future<Map<String, dynamic>> fetchIncentivesData() async {
    final now = DateTime.now();
    if (_cache != null &&
        _cacheTimestamp != null &&
        now.difference(_cacheTimestamp!) < _cacheLifetime) {
      return _cache!;
    }

    await Future.delayed(const Duration(milliseconds: 300));

    final data = <String, dynamic>{
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
      'rangePoints': {
        'today': [
          _point('6AM', 40.0, 0),
          _point('9AM', 55.0, 1),
          _point('12PM', 35.0, 2),
          _point('3PM', 70.0, 3),
          _point('6PM', 90.0, 4),
          _point('9PM', 60.0, 5),
        ],
        'last7Days': [
          _point('Mon', 210.0, 0),
          _point('Tue', 240.0, 1),
          _point('Wed', 190.0, 2),
          _point('Thu', 300.0, 3),
          _point('Fri', 280.0, 4),
          _point('Sat', 350.0, 5),
          _point('Sun', 320.0, 6),
        ],
        'thisWeek': [
          _point('Mon', 210.0, 0),
          _point('Tue', 240.0, 1),
          _point('Wed', 190.0, 2),
          _point('Thu', 300.0, 3),
          _point('Fri', 280.0, 4),
          _point('Sat', 350.0, 5),
          _point('Sun', 320.0, 6),
        ],
        'thisMonth': [
          _point('W1', 950.0, 0),
          _point('W2', 1100.0, 1),
          _point('W3', 1250.0, 2),
          _point('W4', 1450.0, 3),
        ],
      },
      'achievements': [
        _achievement('early_bird', 'Early Bird', 1.0, 1.0, true),
        _achievement('consistent_star', 'Consistent Star', 15.0, 20.0, false),
        _achievement('weekend_warrior', 'Weekend Warrior', 10.0, 25.0, false),
        _achievement('delivery_master', 'Delivery Master', 62.0, 100.0, false),
      ],
      'donutSlices': [
        {'category': 'performance', 'value': 2100.00},
        {'category': 'peakHour', 'value': 1350.00},
        {'category': 'incentive', 'value': 900.00},
        {'category': 'others', 'value': 400.00},
      ],
      'milestones': [
        {'target': 10, 'completed': 10, 'status': 'completed'},
        {'target': 25, 'completed': 25, 'status': 'completed'},
        {'target': 50, 'completed': 50, 'status': 'completed'},
        {'target': 100, 'completed': 62, 'status': 'inProgress'},
        {'target': 200, 'completed': 0, 'status': 'locked'},
      ],
      'rewards': _buildRewards(now),
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

  Map<String, dynamic> _achievement(
    String id,
    String title,
    double progress,
    double target,
    bool completed,
  ) {
    return {
      'id': id,
      'title': title,
      'progress': progress,
      'target': target,
      'completed': completed,
    };
  }

  List<Map<String, dynamic>> _buildRewards(DateTime now) {
    final entries = <(String, String, String, double)>[
      ('Peak Hour Bonus', 'peakHour', 'completed', 120.00),
      ('On-Time Delivery Incentive', 'incentive', 'completed', 85.00),
      ('Performance Bonus', 'performance', 'completed', 200.00),
      ('Long Distance Bonus', 'incentive', 'pending', 150.00),
      ('Rainy Weather Bonus', 'others', 'completed', 60.00),
      ('Night Shift Bonus', 'others', 'completed', 110.00),
      ('High Order Volume Bonus', 'performance', 'processing', 90.00),
      ('Weekend Surge Bonus', 'peakHour', 'completed', 175.00),
      ('Referral Reward', 'others', 'completed', 50.00),
      ('Customer Rating Bonus', 'performance', 'completed', 140.00),
      ('Festival Surge Bonus', 'peakHour', 'pending', 230.00),
      ('Early Shift Bonus', 'others', 'completed', 75.00),
    ];

    final rewards = <Map<String, dynamic>>[];
    for (var i = 0; i < 32; i++) {
      final entry = entries[i % entries.length];
      final title = i >= 12
          ? '${entry.$2 == 'peakHour' ? 'Peak' : entry.$2} Reward #${i + 1}'
          : entry.$1;
      rewards.add({
        'id': 'inc_rw_${i + 1}',
        'title': title,
        'date': now
            .subtract(Duration(days: i))
            .subtract(Duration(hours: i * 3 % 12))
            .toIso8601String(),
        'amount': entry.$4 + (i % 3) * 5.0,
        'type': entry.$2,
        'status': entry.$3,
        'referenceId': 'REF-${1040 + i}',
      });
    }
    return rewards;
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
