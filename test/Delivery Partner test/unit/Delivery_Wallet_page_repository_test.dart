import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Wallet_page/Delivery_Wallet_page_repository.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Wallet_page/Delivery_Wallet_page_service.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Wallet_page/Delivery_Wallet_page_state.dart';

class MockDeliveryWalletPageService extends Mock
    implements DeliveryWalletPageServiceBase {}

Map<String, dynamic> rawData() => {
      'walletBalance': 24580.50,
      'totalEarnings': 128450.00,
      'totalWithdrawn': 89450.00,
      'bonusEarnings': 12500.00,
      'transactions': [
        {
          'id': 'tx_1',
          'title': 'Delivery Earnings',
          'date': '2026-07-31T10:00:00.000',
          'amount': 640.00,
          'type': 'income',
          'status': 'completed',
        },
        {
          'id': 'tx_2',
          'title': 'Wallet Withdrawal',
          'date': '2026-07-30T10:00:00.000',
          'amount': 5000.00,
          'type': 'withdrawal',
          'status': 'processing',
        },
      ],
      'paymentMethods': [
        {
          'id': 'pm_1',
          'type': 'UPI',
          'label': 'Google Pay',
          'maskedIdentifier': 'partner@okhdfcbank',
          'isDefault': true,
        },
      ],
      'bankAccount': {
        'bankName': 'HDFC Bank',
        'accountHolder': 'Kavitha',
        'maskedAccountNumber': 'xxxx4821',
        'ifscCode': 'HDFC0001234',
        'isVerified': true,
      },
      'settlementSchedule': [
        {
          'period': 'This Week',
          'amount': 1890.00,
          'status': 'scheduled',
          'date': '2026-07-31T00:00:00.000',
        },
      ],
      'periodEarnings': {
        'thisMonth': [
          {'label': 'W1', 'value': 22850.0, 'date': '2026-07-01T00:00:00.000'},
        ],
      },
      'earningsBreakdown': [
        {'label': 'Delivery Income', 'value': 96850.0, 'colorHex': '#00E676'},
      ],
    };

void main() {
  late DeliveryWalletPageRepository repository;
  late MockDeliveryWalletPageService mockService;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    mockService = MockDeliveryWalletPageService();
    registerFallbackValue(DeliveryWalletTransactionFilter.all);
    repository = DeliveryWalletPageRepository(
      service: mockService,
      prefs: prefs,
    );
  });

  group('DeliveryWalletPage Repository Tests', () {
    test('loadWalletData maps raw service data into the state', () async {
      when(
        () => mockService.fetchWalletData(),
      ).thenAnswer((_) async => rawData());

      final state = await repository.loadWalletData();

      expect(state.status, DeliveryWalletStatus.loaded);
      expect(state.isFromCache, isFalse);
      expect(state.walletBalance, 24580.50);
      expect(state.totalEarnings, 128450.00);
      expect(state.totalWithdrawn, 89450.00);
      expect(state.bonusEarnings, 12500.00);
      expect(state.transactions, hasLength(2));
      expect(state.paymentMethods, hasLength(1));
      expect(state.bankAccount, isNotNull);
      expect(state.bankAccount!.bankName, 'HDFC Bank');
      expect(state.settlementSchedule, hasLength(1));
      expect(state.earningsBreakdown, hasLength(1));
      expect(state.currentPeriodPoints, hasLength(1));
    });

    test('loadWalletData maps an empty payload to zeroed metrics', () async {
      when(
        () => mockService.fetchWalletData(),
      ).thenAnswer((_) async => <String, dynamic>{});

      final state = await repository.loadWalletData();

      expect(state.walletBalance, 0.0);
      expect(state.totalEarnings, 0.0);
      expect(state.transactions, isEmpty);
      expect(state.paymentMethods, isEmpty);
      expect(state.bankAccount, isNull);
    });

    test('loadWalletData persists a local cache for offline fallback', () async {
      when(
        () => mockService.fetchWalletData(),
      ).thenAnswer((_) async => rawData());
      await repository.loadWalletData();

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('dp_wallet_cache_v1'), isNotNull);
    });

    test('loadCachedWallet restores cached snapshot when available', () async {
      when(
        () => mockService.fetchWalletData(),
      ).thenAnswer((_) async => rawData());
      await repository.loadWalletData();
      final cached = await repository.loadCachedWallet();

      expect(cached, isNotNull);
      expect(cached!.status, DeliveryWalletStatus.loaded);
      expect(cached.isFromCache, isTrue);
      expect(cached.walletBalance, 24580.50);
      expect(cached.transactions, hasLength(2));
    });

    test('loadCachedWallet returns null when no cache exists', () async {
      final cached = await repository.loadCachedWallet();
      expect(cached, isNull);
    });

    test('withdraw reduces balance and prepends withdrawal transaction', () async {
      when(
        () => mockService.fetchWalletData(),
      ).thenAnswer((_) async => rawData());
      when(
        () => mockService.withdraw(500.00),
      ).thenAnswer((_) async => {
        'success': true,
        'walletBalance': 24080.50,
        'transaction': {
          'id': 'tx_new',
          'title': 'Withdrawal',
          'date': '2026-08-01T10:00:00.000',
          'amount': -500.00,
          'type': 'withdrawal',
          'status': 'processing',
        },
      });

      final initial = await repository.loadWalletData();
      expect(initial.walletBalance, 24580.50);

      final updated = await repository.withdraw(500.00);

      expect(updated.walletBalance, 24080.50);
      expect(updated.transactions, hasLength(3));
      expect(updated.transactions.first.type, 'withdrawal');
      expect(updated.transactions.first.amount, -500.00);
    });

    test('withdrawal state persists to cache and is restored', () async {
      when(
        () => mockService.fetchWalletData(),
      ).thenAnswer((_) async => rawData());
      when(
        () => mockService.withdraw(500.00),
      ).thenAnswer((_) async => {
        'success': true,
        'walletBalance': 24080.50,
        'transaction': {
          'id': 'tx_new',
          'title': 'Withdrawal',
          'date': '2026-08-01T10:00:00.000',
          'amount': -500.00,
          'type': 'withdrawal',
          'status': 'processing',
        },
      });
      await repository.loadWalletData();
      await repository.withdraw(500.00);

      final fresh = DeliveryWalletPageRepository(
        service: mockService,
        prefs: await SharedPreferences.getInstance(),
      );
      final cached = await fresh.loadCachedWallet();

      expect(cached, isNotNull);
      expect(cached!.walletBalance, 24080.50);
      expect(cached.transactions.first.amount, -500.00);
    });

    test('filterTransactions maps service transaction records', () async {
      when(
        () => mockService.fetchTransactions(any()),
      ).thenAnswer((_) async => (rawData()['transactions'] as List)
          .cast<Map<String, dynamic>>());

      final income = await repository.filterTransactions(
        DeliveryWalletTransactionFilter.income,
      );
      expect(income, hasLength(2));
      expect(income.first.type, 'income');
    });

    test('addPaymentMethod appends a new payment method', () async {
      when(
        () => mockService.fetchWalletData(),
      ).thenAnswer((_) async => rawData());
      when(
        () => mockService.addPaymentMethod(any()),
      ).thenAnswer((_) async => {
        'success': true,
        'id': 'pm_new',
        'type': 'UPI',
        'label': 'PhonePe',
        'maskedIdentifier': 'partner@okicici',
        'isDefault': false,
      });

      await repository.loadWalletData();
      final updated = await repository.addPaymentMethod(
        const DeliveryPaymentMethod(
          id: 'pm_new',
          type: 'UPI',
          label: 'PhonePe',
          maskedIdentifier: 'partner@okicici',
          isDefault: false,
        ),
      );

      expect(updated.paymentMethods, hasLength(2));
      expect(updated.paymentMethods.last.label, 'PhonePe');
    });

    test('clearCache removes the persisted snapshot', () async {
      when(
        () => mockService.fetchWalletData(),
      ).thenAnswer((_) async => rawData());
      await repository.loadWalletData();
      await repository.clearCache();

      final cached = await repository.loadCachedWallet();
      expect(cached, isNull);
    });
  });
}
