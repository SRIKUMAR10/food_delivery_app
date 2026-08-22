import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Wallet_page/Delivery_Wallet_page_repository.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Wallet_page/Delivery_Wallet_page_service.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Wallet_page/Delivery_Wallet_page_state.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Wallet_page/Delivery_Wallet_page_ui.dart';

class MockDeliveryWalletRepository extends Mock
    implements DeliveryWalletPageRepositoryBase {}

class MockDeliveryWalletService extends Mock
    implements DeliveryWalletPageServiceBase {}

DeliveryWalletPageState buildLoadedState({
  double walletBalance = 24580.50,
}) {
  return DeliveryWalletPageState(
    status: DeliveryWalletStatus.loaded,
    walletBalance: walletBalance,
    availableBalance: walletBalance,
    pendingBalance: 0,
    withdrawableAmount: walletBalance,
    totalEarnings: 48250,
    totalWithdrawn: 12000,
    transactions: [
      DeliveryWalletTransaction(
        id: 'tx_1',
        title: 'Delivery Earnings',
        date: DateTime(2026, 7, 31),
        amount: 640,
        type: 'income',
        status: 'completed',
      ),
      DeliveryWalletTransaction(
        id: 'tx_2',
        title: 'Peak Hour Bonus',
        date: DateTime(2026, 7, 30),
        amount: 350,
        type: 'bonus',
        status: 'completed',
      ),
    ],
    paymentMethods: const [
      DeliveryPaymentMethod(
        id: 'pm_1',
        type: 'UPI',
        label: 'Google Pay',
        maskedIdentifier: 'ravi@okhdfcbank',
        isDefault: true,
      ),
    ],
    bankAccount: const DeliveryBankAccount(
      bankName: 'HDFC Bank',
      accountHolder: 'Ravi Kumar',
      maskedAccountNumber: 'xxxx4821',
      ifscCode: 'HDFC0001234',
      isVerified: true,
    ),
    periodEarnings: {
      DeliveryWalletPeriod.thisMonth: [
        DeliveryWalletEarningsPoint(
          label: 'W1',
          value: 22850,
          date: DateTime(2026, 7, 1),
        ),
      ],
    },
    earningsBreakdown: const [
      DeliveryWalletBreakdownSlice(
        label: 'Delivery Income',
        value: 96850,
        colorHex: '#00E676',
      ),
    ],
  );
}

void main() {
  late MockDeliveryWalletRepository mockRepository;
  late MockDeliveryWalletService mockService;

  setUpAll(() {
    registerFallbackValue(DeliveryWalletTransactionFilter.all);
  });

  setUp(() {
    SharedPreferences.setMockInitialValues({});

    mockRepository = MockDeliveryWalletRepository();
    mockService = MockDeliveryWalletService();

    when(() => mockRepository.loadWalletData()).thenAnswer(
      (_) async => buildLoadedState(),
    );
    when(() => mockRepository.watchWalletData()).thenAnswer(
      (_) => Stream.value(buildLoadedState()),
    );
    when(() => mockRepository.withdraw(any())).thenAnswer(
      (_) async => buildLoadedState(walletBalance: 24080.50),
    );
    when(() => mockRepository.watchTransactions(any())).thenAnswer(
      (invocation) {
        final filter = invocation.positionalArguments.first
            as DeliveryWalletTransactionFilter;
        return Stream.value(
          filter == DeliveryWalletTransactionFilter.income
              ? [
                  DeliveryWalletTransaction(
                    id: 'tx_1',
                    title: 'Delivery Earnings',
                    date: DateTime(2026, 7, 31),
                    amount: 640,
                    type: 'income',
                    status: 'completed',
                  ),
                ]
              : [
                  DeliveryWalletTransaction(
                    id: 'tx_1',
                    title: 'Delivery Earnings',
                    date: DateTime(2026, 7, 31),
                    amount: 640,
                    type: 'income',
                    status: 'completed',
                  ),
                  DeliveryWalletTransaction(
                    id: 'tx_2',
                    title: 'Peak Hour Bonus',
                    date: DateTime(2026, 7, 30),
                    amount: 350,
                    type: 'bonus',
                    status: 'completed',
                  ),
                ],
        );
      },
    );
    when(() => mockRepository.filterTransactions(any())).thenAnswer(
      (_) async => const <DeliveryWalletTransaction>[],
    );
  });

  void setDesktopSize(WidgetTester tester) {
    tester.view.physicalSize = const Size(1280, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
  }

  Future<void> loadPage(WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData.dark(),
        home: Scaffold(
          body: DeliveryWalletPage(
            repository: mockRepository,
            service: mockService,
          ),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
  }

  group('DeliveryWalletPage Integration Flow Tests', () {
    testWidgets('loads the complete dashboard', (tester) async {
      setDesktopSize(tester);
      await loadPage(tester);

      expect(find.text('My Wallet'), findsWidgets);
      expect(find.text('₹24580.50'), findsWidgets);
      expect(find.byKey(const Key('dp_wallet_chart_card')), findsOneWidget);
      expect(
        find.byKey(const Key('dp_wallet_transactions_panel')),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('dp_wallet_settlement_card')),
        findsOneWidget,
      );
    });

    testWidgets('filters transactions through the rendered UI', (tester) async {
      setDesktopSize(tester);
      await loadPage(tester);

      await tester.ensureVisible(
        find.byKey(const Key('dp_wallet_transaction_filter_income')),
      );
      await tester.pump();
      await tester.tap(
        find.byKey(const Key('dp_wallet_transaction_filter_income')),
      );
      await tester.pump(const Duration(milliseconds: 150));

      expect(find.text('Delivery Earnings'), findsWidgets);
      expect(find.text('Peak Hour Bonus'), findsNothing);
      expect(tester.takeException(), isNull);
    });

    testWidgets('changes earnings period without exceptions', (tester) async {
      setDesktopSize(tester);
      await loadPage(tester);

      await tester.tap(find.byKey(const Key('dp_wallet_period_last3Months')));
      await tester.pump();
      expect(find.byKey(const Key('dp_wallet_chart')), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('withdraws funds and updates the balance', (tester) async {
      setDesktopSize(tester);
      await loadPage(tester);

      await tester.tap(find.byKey(const Key('dp_wallet_withdraw_button')));
      await tester.pump();
      await tester.enterText(
        find.byKey(const Key('dp_earnings_withdraw_amount')),
        '500',
      );
      await tester.tap(find.byKey(const Key('dp_earnings_withdraw_confirm')));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 350));

      expect(find.text('₹24080.50'), findsWidgets);
      expect(tester.takeException(), isNull);
    });
  });
}