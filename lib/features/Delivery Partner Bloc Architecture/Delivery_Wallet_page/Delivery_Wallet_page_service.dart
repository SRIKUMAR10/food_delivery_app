import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'Delivery_Wallet_page_state.dart';

abstract class DeliveryWalletPageServiceBase {
  Future<Map<String, dynamic>> fetchWalletData();
  Future<Map<String, dynamic>> withdraw(double amount);
  Future<Map<String, dynamic>> addPaymentMethod(Map<String, dynamic> method);
  Future<List<Map<String, dynamic>>> fetchTransactions(
    DeliveryWalletTransactionFilter filter,
  );
}

class DeliveryWalletPageService implements DeliveryWalletPageServiceBase {
  static const String _apiUrlKey = 'WALLET_API_BASE_URL';
  static const Duration _cacheLifetime = Duration(minutes: 5);

  Map<String, dynamic>? _cache;
  DateTime? _cacheTimestamp;

  String get apiBaseUrl =>
      _safeEnv(_apiUrlKey, fallback: 'https://api.foodgo.example/v1');

  String _safeEnv(String key, {required String fallback}) {
    try {
      return dotenv.maybeGet(key) ?? fallback;
    } catch (_) {
      return fallback;
    }
  }

  Map<String, dynamic> _tx(
    String id,
    String title,
    int dayOffset,
    double amount,
    String type,
    String status,
  ) {
    return {
      'id': id,
      'title': title,
      'date': DateTime.now()
          .subtract(Duration(days: dayOffset))
          .toIso8601String(),
      'amount': amount,
      'type': type,
      'status': status,
    };
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

  Map<String, dynamic> _buildMockPayload() {
    return {
      'walletBalance': 24580.50,
      'totalEarnings': 128450.00,
      'totalWithdrawn': 89450.00,
      'bonusEarnings': 12500.00,
      'transactions': [
        _tx('tx_1', 'Delivery Earnings', 0, 640.00, 'income', 'completed'),
        _tx('tx_2', 'Peak Hour Bonus', 0, 350.00, 'bonus', 'completed'),
        _tx(
          'tx_3',
          'Wallet Withdrawal',
          1,
          5000.00,
          'withdrawal',
          'processing',
        ),
        _tx('tx_4', 'Weekend Incentive', 2, 500.00, 'bonus', 'completed'),
        _tx('tx_5', 'Delivery Earnings', 2, 480.00, 'income', 'completed'),
        _tx('tx_6', 'Wallet Withdrawal', 3, 3000.00, 'withdrawal', 'completed'),
        _tx('tx_7', 'Delivery Earnings', 4, 520.00, 'income', 'completed'),
        _tx('tx_8', 'Referral Bonus', 5, 200.00, 'bonus', 'pending'),
        _tx('tx_9', 'Delivery Earnings', 6, 610.00, 'income', 'completed'),
        _tx(
          'tx_10',
          'Wallet Withdrawal',
          7,
          4000.00,
          'withdrawal',
          'completed',
        ),
        _tx('tx_11', 'Rainy Day Bonus', 8, 300.00, 'bonus', 'completed'),
        _tx('tx_12', 'Delivery Earnings', 9, 455.00, 'income', 'completed'),
      ],
      'paymentMethods': [
        {
          'id': 'pm_1',
          'type': 'UPI',
          'label': 'Google Pay',
          'maskedIdentifier': 'ravi@okhdfcbank',
          'isDefault': true,
        },
        {
          'id': 'pm_2',
          'type': 'Bank',
          'label': 'HDFC Bank',
          'maskedIdentifier': 'xxxx4821',
          'isDefault': false,
        },
        {
          'id': 'pm_3',
          'type': 'Card',
          'label': 'Visa Debit Card',
          'maskedIdentifier': 'xxxx 4421',
          'isDefault': false,
        },
      ],
      'bankAccount': {
        'bankName': 'HDFC Bank',
        'accountHolder': 'Ravi Kumar',
        'maskedAccountNumber': 'xxxx4821',
        'ifscCode': 'HDFC0001234',
        'isVerified': true,
      },
      'settlementSchedule': [
        {
          'period': 'This Week',
          'amount': 1890.00,
          'status': 'scheduled',
          'date': DateTime.now()
              .subtract(const Duration(days: 1))
              .toIso8601String(),
        },
        {
          'period': 'Last Week',
          'amount': 12450.00,
          'status': 'settled',
          'date': DateTime.now()
              .subtract(const Duration(days: 8))
              .toIso8601String(),
        },
        {
          'period': 'Two Weeks Ago',
          'amount': 11720.00,
          'status': 'settled',
          'date': DateTime.now()
              .subtract(const Duration(days: 15))
              .toIso8601String(),
        },
      ],
      'periodEarnings': {
        'thisWeek': [
          _point('Mon', 2100.0, 6),
          _point('Tue', 2450.0, 5),
          _point('Wed', 1980.0, 4),
          _point('Thu', 2720.0, 3),
          _point('Fri', 3150.0, 2),
          _point('Sat', 3380.0, 1),
          _point('Sun', 2890.0, 0),
        ],
        'thisMonth': [
          _point('W1', 22850.0, 28),
          _point('W2', 26400.0, 21),
          _point('W3', 24100.0, 14),
          _point('W4', 28900.0, 7),
          _point('W5', 24580.0, 0),
        ],
        'lastMonth': [
          _point('W1', 20100.0, 35),
          _point('W2', 23400.0, 28),
          _point('W3', 22150.0, 21),
          _point('W4', 25800.0, 14),
        ],
        'last3Months': [
          _point('Jun', 88250.0, 90),
          _point('Jul', 91500.0, 60),
          _point('Aug', 94100.0, 30),
        ],
      },
      'earningsBreakdown': [
        {'label': 'Delivery Income', 'value': 96850.0, 'colorHex': '#00E676'},
        {'label': 'Tips', 'value': 7200.0, 'colorHex': '#29B6F6'},
        {'label': 'Incentives', 'value': 11900.0, 'colorHex': '#7C4DFF'},
        {'label': 'Bonuses', 'value': 12500.0, 'colorHex': '#FFB74D'},
      ],
    };
  }

  @override
  Future<Map<String, dynamic>> fetchWalletData() async {
    final now = DateTime.now();
    if (_cache != null &&
        _cacheTimestamp != null &&
        now.difference(_cacheTimestamp!) < _cacheLifetime) {
      return _cache!;
    }

    await Future.delayed(const Duration(milliseconds: 300));

    final data = _buildMockPayload();
    _cache = data;
    _cacheTimestamp = now;
    return data;
  }

  @override
  Future<Map<String, dynamic>> withdraw(double amount) async {
    await Future.delayed(const Duration(milliseconds: 250));
    final currentBalance = ((_cache?['walletBalance'] as num?) ?? 24580.50)
        .toDouble();
    final newBalance = currentBalance - amount;

    if (_cache != null) {
      _cache!['walletBalance'] = newBalance;
    }

    final now = DateTime.now();
    final transaction = _tx(
      'tx_${now.millisecondsSinceEpoch}',
      'Withdrawal to Bank',
      0,
      amount,
      'withdrawal',
      'processing',
    );
    if (_cache != null) {
      final transactions = List<Map<String, dynamic>>.from(
        (_cache!['transactions'] as List? ?? const []).map(
          (item) => Map<String, dynamic>.from(item as Map),
        ),
      );
      transactions.insert(0, transaction);
      _cache!['transactions'] = transactions;
    }
    return {
      'success': true,
      'walletBalance': newBalance,
      'transaction': transaction,
    };
  }

  @override
  Future<Map<String, dynamic>> addPaymentMethod(
    Map<String, dynamic> method,
  ) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final methods = List<Map<String, dynamic>>.from(
      (_cache?['paymentMethods'] as List? ?? const []).map(
        (e) => Map<String, dynamic>.from(e as Map),
      ),
    );
    methods.add(Map<String, dynamic>.from(method));
    _cache?['paymentMethods'] = methods;
    return method;
  }

  @override
  Future<List<Map<String, dynamic>>> fetchTransactions(
    DeliveryWalletTransactionFilter filter,
  ) async {
    await Future.delayed(const Duration(milliseconds: 100));
    final all = List<Map<String, dynamic>>.from(
      (_cache?['transactions'] as List? ?? const []).map(
        (e) => Map<String, dynamic>.from(e as Map),
      ),
    );
    return switch (filter) {
      DeliveryWalletTransactionFilter.all => all,
      DeliveryWalletTransactionFilter.income =>
        all.where((t) => t['type'] == 'income').toList(),
      DeliveryWalletTransactionFilter.withdrawals =>
        all.where((t) => t['type'] == 'withdrawal').toList(),
      DeliveryWalletTransactionFilter.bonuses =>
        all.where((t) => t['type'] == 'bonus').toList(),
    };
  }
}
