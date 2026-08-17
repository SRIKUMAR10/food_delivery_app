// Real-Time Firestore Stream Provider Standardized
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'Delivery_Wallet_page_service.dart';
import 'Delivery_Wallet_page_state.dart';

abstract class DeliveryWalletPageRepositoryBase {
  Future<DeliveryWalletPageState> loadWalletData();
  Stream<DeliveryWalletPageState> watchWalletData();
  Future<DeliveryWalletPageState?> loadCachedWallet();
  Future<DeliveryWalletPageState> withdraw(double amount);
  Future<List<DeliveryWalletTransaction>> filterTransactions(
    DeliveryWalletTransactionFilter filter,
  );
  Stream<List<DeliveryWalletTransaction>> watchTransactions(
    DeliveryWalletTransactionFilter filter,
  );
  Future<DeliveryWalletPageState> addPaymentMethod(
    DeliveryPaymentMethod method,
  );
  Future<void> clearCache();
}

class DeliveryWalletPageRepository implements DeliveryWalletPageRepositoryBase {
  static const String _cacheKey = 'dp_wallet_cache_v1';

  final DeliveryWalletPageServiceBase _service;
  final SharedPreferences? _prefs;
  Map<String, dynamic>? _lastRaw;

  DeliveryWalletPageRepository({
    DeliveryWalletPageServiceBase? service,
    SharedPreferences? prefs,
  }) : _service = service ?? DeliveryWalletPageService(
            firestore: FirebaseFirestore.instance,
            auth: FirebaseAuth.instance,
        ),
       _prefs = prefs;

  Future<SharedPreferences> _getPrefs() async =>
      _prefs ?? await SharedPreferences.getInstance();

  @override
  Future<DeliveryWalletPageState> loadWalletData() async {
    try {
      final raw = await _service.fetchWalletData();
      _lastRaw = raw;
      await _saveCache(raw);
      return _buildState(raw);
    } catch (_) {
      final cached = await loadCachedWallet();
      if (cached != null) return cached;
      rethrow;
    }
  }

  @override
  Stream<DeliveryWalletPageState> watchWalletData() {
    return _service.watchWalletData().map((raw) {
      if (raw.isNotEmpty) {
        _lastRaw = raw;
        _saveCache(raw);
      }
      return _buildState(raw);
    });
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
  Future<DeliveryWalletPageState?> loadCachedWallet() async {
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
  Future<List<DeliveryWalletTransaction>> filterTransactions(
    DeliveryWalletTransactionFilter filter,
  ) async {
    final rawList = await _service.fetchTransactions(filter);
    return rawList
        .map(
          (e) => DeliveryWalletTransaction(
            id: e['id'] ?? '',
            title: e['title'] ?? '',
            date: DateTime.tryParse(e['date'] ?? '') ?? DateTime.now(),
            amount: (e['amount'] as num?)?.toDouble() ?? 0.0,
            type: e['type'] ?? 'income',
            status: e['status'] ?? 'completed',
          ),
        )
        .toList();
  }

  @override
  Stream<List<DeliveryWalletTransaction>> watchTransactions(
    DeliveryWalletTransactionFilter filter,
  ) {
    return _service.watchTransactions(filter).map(
          (rawList) => rawList
              .map(
                (e) => DeliveryWalletTransaction(
                  id: e['id'] ?? '',
                  title: e['title'] ?? '',
                  date: DateTime.tryParse(e['date'] ?? '') ?? DateTime.now(),
                  amount: (e['amount'] as num?)?.toDouble() ?? 0.0,
                  type: e['type'] ?? 'income',
                  status: e['status'] ?? 'completed',
                ),
              )
              .toList(),
        );
  }

  @override
  Future<DeliveryWalletPageState> withdraw(double amount) async {
    final result = await _service.withdraw(amount);

    final raw = Map<String, dynamic>.from(_lastRaw ?? const {});
    raw['walletBalance'] = result['walletBalance'];

    final transactions = List<Map<String, dynamic>>.from(
      (raw['transactions'] as List? ?? []).map(
        (e) => Map<String, dynamic>.from(e as Map),
      ),
    );
    final transaction = Map<String, dynamic>.from(result['transaction'] as Map);
    if (!transactions.any((item) => item['id'] == transaction['id'])) {
      transactions.insert(0, transaction);
    }
    raw['transactions'] = transactions;

    _lastRaw = raw;
    await _saveCache(raw);
    return _buildState(raw);
  }

  @override
  Future<DeliveryWalletPageState> addPaymentMethod(
    DeliveryPaymentMethod method,
  ) async {
    final rawMethod = await _service.addPaymentMethod({
      'id': method.id,
      'type': method.type,
      'label': method.label,
      'maskedIdentifier': method.maskedIdentifier,
      'isDefault': method.isDefault,
    });

    final raw = Map<String, dynamic>.from(_lastRaw ?? const {});
    final methods = List<Map<String, dynamic>>.from(
      (raw['paymentMethods'] as List? ?? []).map(
        (e) => Map<String, dynamic>.from(e as Map),
      ),
    );
    final methodId = rawMethod['id'];
    if (!methods.any((item) => item['id'] == methodId)) {
      methods.add(Map<String, dynamic>.from(rawMethod));
    }
    raw['paymentMethods'] = methods;

    _lastRaw = raw;
    await _saveCache(raw);
    return _buildState(raw);
  }

  DeliveryWalletPageState _buildState(Map<String, dynamic> raw) {
    final periodMap =
        <DeliveryWalletPeriod, List<DeliveryWalletEarningsPoint>>{};
    final periods = raw['periodEarnings'] as Map<String, dynamic>? ?? {};
    periods.forEach((key, value) {
      final points = (value as List? ?? []).map((e) {
        final map = e as Map<String, dynamic>;
        return DeliveryWalletEarningsPoint(
          label: map['label'] ?? '',
          value: (map['value'] as num?)?.toDouble() ?? 0.0,
          date: DateTime.tryParse(map['date'] ?? '') ?? DateTime.now(),
        );
      }).toList();
      periodMap[_periodFromString(key)] = points;
    });

    final transactions = (raw['transactions'] as List? ?? []).map((e) {
      final map = e as Map<String, dynamic>;
      return DeliveryWalletTransaction(
        id: map['id'] ?? '',
        title: map['title'] ?? '',
        date: DateTime.tryParse(map['date'] ?? '') ?? DateTime.now(),
        amount: (map['amount'] as num?)?.toDouble() ?? 0.0,
        type: map['type'] ?? 'income',
        status: map['status'] ?? 'completed',
      );
    }).toList();

    final paymentMethods = (raw['paymentMethods'] as List? ?? []).map((e) {
      final map = e as Map<String, dynamic>;
      return DeliveryPaymentMethod(
        id: map['id'] ?? '',
        type: map['type'] ?? 'Bank',
        label: map['label'] ?? 'Bank Transfer',
        maskedIdentifier: map['maskedIdentifier'] ?? '',
        isDefault: map['isDefault'] ?? false,
      );
    }).toList();

    final bankRaw = raw['bankAccount'] as Map<String, dynamic>?;
    final bankAccount = bankRaw == null
        ? null
        : DeliveryBankAccount(
            bankName: bankRaw['bankName'] ?? '',
            accountHolder: bankRaw['accountHolder'] ?? '',
            maskedAccountNumber: bankRaw['maskedAccountNumber'] ?? '',
            ifscCode: bankRaw['ifscCode'] ?? '',
            isVerified: bankRaw['isVerified'] ?? false,
          );

    final settlements = (raw['settlementSchedule'] as List? ?? []).map((e) {
      final map = e as Map<String, dynamic>;
      return DeliverySettlementItem(
        period: map['period'] ?? '',
        amount: (map['amount'] as num?)?.toDouble() ?? 0.0,
        status: map['status'] ?? 'scheduled',
        date: DateTime.tryParse(map['date'] ?? '') ?? DateTime.now(),
      );
    }).toList();

    final breakdown = (raw['earningsBreakdown'] as List? ?? []).map((e) {
      final map = e as Map<String, dynamic>;
      return DeliveryWalletBreakdownSlice(
        label: map['label'] ?? '',
        value: (map['value'] as num?)?.toDouble() ?? 0.0,
        colorHex: map['colorHex'] ?? '#00E676',
      );
    }).toList();

    return DeliveryWalletPageState(
      status: DeliveryWalletStatus.loaded,
      walletBalance: (raw['walletBalance'] as num?)?.toDouble() ?? 0.0,
      availableBalance: (raw['availableBalance'] as num?)?.toDouble() ?? 0.0,
      pendingBalance: (raw['pendingBalance'] as num?)?.toDouble() ??
          (raw['pendingWithdrawal'] as num?)?.toDouble() ??
          0.0,
      withdrawableAmount:
          (raw['withdrawableAmount'] as num?)?.toDouble() ?? 0.0,
      codAdjustment: (raw['codAdjustment'] as num?)?.toDouble() ?? 0.0,
      totalEarnings: (raw['totalEarnings'] as num?)?.toDouble() ?? 0.0,
      totalWithdrawn: (raw['totalWithdrawn'] as num?)?.toDouble() ?? 0.0,
      bonusEarnings: (raw['bonusEarnings'] as num?)?.toDouble() ?? 0.0,
      incentiveEarnings: (raw['incentiveEarnings'] as num?)?.toDouble() ?? 0.0,
      transactions: transactions,
      paymentMethods: paymentMethods,
      bankAccount: bankAccount,
      settlementSchedule: settlements,
      periodEarnings: periodMap,
      earningsBreakdown: breakdown,
    );
  }

  DeliveryWalletPeriod _periodFromString(String value) {
    return switch (value) {
      'thisWeek' => DeliveryWalletPeriod.thisWeek,
      'lastMonth' => DeliveryWalletPeriod.lastMonth,
      'last3Months' => DeliveryWalletPeriod.last3Months,
      _ => DeliveryWalletPeriod.thisMonth,
    };
  }
}
