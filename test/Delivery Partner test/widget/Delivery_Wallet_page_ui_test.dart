import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Wallet_page/Delivery_Wallet_page_bloc.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Wallet_page/Delivery_Wallet_page_event.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Wallet_page/Delivery_Wallet_page_state.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Wallet_page/Delivery_Wallet_page_ui.dart';

class MockDeliveryWalletPageBloc
    extends MockBloc<DeliveryWalletPageEvent, DeliveryWalletPageState>
    implements DeliveryWalletPageBloc {}

DeliveryWalletPageState loadedState({
  DeliveryWalletTransactionFilter filter = DeliveryWalletTransactionFilter.all,
  String localeCode = 'en',
}) {
  return DeliveryWalletPageState(
    status: DeliveryWalletStatus.loaded,
    activeFilter: filter,
    localeCode: localeCode,
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
        DeliveryWalletEarningsPoint(
          label: 'W2',
          value: 26400,
          date: DateTime(2026, 7, 8),
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
  late MockDeliveryWalletPageBloc bloc;

  setUpAll(() {
    registerFallbackValue(const DeliveryWalletInitEvent());
    registerFallbackValue(
      const DeliveryWalletFilterTransactionsEvent(
        DeliveryWalletTransactionFilter.all,
      ),
    );
    registerFallbackValue(
      const DeliveryWalletFilterPeriodChangedEvent(
        DeliveryWalletPeriod.thisMonth,
      ),
    );
    registerFallbackValue(const DeliveryWalletWithdrawRequestedEvent(0));
    registerFallbackValue(
      const DeliveryWalletAddPaymentMethodEvent(
        DeliveryPaymentMethod(
          id: 'fallback',
          type: 'UPI',
          label: 'Fallback',
          maskedIdentifier: 'fallback@upi',
        ),
      ),
    );
  });

  setUp(() {
    bloc = MockDeliveryWalletPageBloc();
    when(() => bloc.state).thenReturn(loadedState());
  });

  void setSize(WidgetTester tester, Size size) {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
  }

  Widget buildPage() {
    return MaterialApp(
      theme: ThemeData.dark(),
      home: Scaffold(body: DeliveryWalletPage(bloc: bloc)),
    );
  }

  group('DeliveryWalletPage Widget Tests', () {
    testWidgets('renders desktop dashboard sections and profile', (
      tester,
    ) async {
      setSize(tester, const Size(1280, 1000));
      await tester.pumpWidget(buildPage());
      await tester.pump();

      expect(find.text('My Wallet'), findsOneWidget);
      expect(find.text('Ravi Kumar'), findsWidgets);
      expect(find.byKey(const Key('dp_wallet_sidebar')), findsOneWidget);
      expect(
        find.byKey(const Key('dp_wallet_summary_balance')),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('dp_wallet_summary_earnings')),
        findsOneWidget,
      );
      expect(find.byKey(const Key('dp_wallet_chart_card')), findsOneWidget);
      expect(find.byKey(const Key('dp_wallet_breakdown_card')), findsOneWidget);
      expect(find.byKey(const Key('dp_wallet_payment_card')), findsOneWidget);
      expect(find.byKey(const Key('dp_wallet_bank_card')), findsOneWidget);
    });

    testWidgets('renders a compact layout on mobile', (tester) async {
      setSize(tester, const Size(390, 844));
      await tester.pumpWidget(buildPage());
      await tester.pump();

      expect(find.byKey(const Key('dp_wallet_page')), findsOneWidget);
      expect(find.byKey(const Key('dp_wallet_sidebar')), findsNothing);
      expect(
        find.byKey(const Key('dp_wallet_transactions_panel')),
        findsOneWidget,
      );
      expect(tester.takeException(), isNull);
    });

    testWidgets('opens withdraw dialog and dispatches amount', (tester) async {
      setSize(tester, const Size(1280, 1000));
      await tester.pumpWidget(buildPage());
      await tester.pump();

      await tester.tap(find.byKey(const Key('dp_wallet_withdraw_button')));
      await tester.pump();
      expect(find.text('Withdraw Funds'), findsWidgets);

      await tester.enterText(
        find.byKey(const Key('dp_wallet_withdraw_amount')),
        '500',
      );
      await tester.tap(find.byKey(const Key('dp_wallet_withdraw_confirm')));
      await tester.pump();

      verify(
        () => bloc.add(const DeliveryWalletWithdrawRequestedEvent(500)),
      ).called(1);
    });

    testWidgets('transaction filter dispatches the selected filter', (
      tester,
    ) async {
      setSize(tester, const Size(1280, 1000));
      await tester.pumpWidget(buildPage());
      await tester.pump();

      await tester.tap(
        find.byKey(const Key('dp_wallet_transaction_filter_bonuses')),
      );
      await tester.pump();

      verify(
        () => bloc.add(
          const DeliveryWalletFilterTransactionsEvent(
            DeliveryWalletTransactionFilter.bonuses,
          ),
        ),
      ).called(1);
    });

    testWidgets('period chip dispatches selected period', (tester) async {
      setSize(tester, const Size(1280, 1000));
      await tester.pumpWidget(buildPage());
      await tester.pump();

      await tester.tap(find.byKey(const Key('dp_wallet_period_lastMonth')));
      await tester.pump();

      verify(
        () => bloc.add(
          const DeliveryWalletFilterPeriodChangedEvent(
            DeliveryWalletPeriod.lastMonth,
          ),
        ),
      ).called(1);
    });

    testWidgets('add payment method dispatches an event', (tester) async {
      setSize(tester, const Size(1280, 1000));
      await tester.pumpWidget(buildPage());
      await tester.pump();

      await tester.tap(find.byKey(const Key('dp_wallet_add_payment_button')));
      await tester.pump();

      verify(
        () => bloc.add(any(that: isA<DeliveryWalletAddPaymentMethodEvent>())),
      ).called(1);
    });

    testWidgets('shows loading skeleton and error retry states', (
      tester,
    ) async {
      setSize(tester, const Size(800, 900));
      when(() => bloc.state).thenReturn(
        const DeliveryWalletPageState(status: DeliveryWalletStatus.loading),
      );
      await tester.pumpWidget(buildPage());
      await tester.pump();
      expect(find.byKey(const Key('dp_wallet_skeleton')), findsOneWidget);

      final errorBloc = MockDeliveryWalletPageBloc();
      when(() => errorBloc.state).thenReturn(
        const DeliveryWalletPageState(
          status: DeliveryWalletStatus.error,
          errorMessage: 'Offline',
        ),
      );
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.dark(),
          home: Scaffold(body: DeliveryWalletPage(bloc: errorBloc)),
        ),
      );
      await tester.pump();
      expect(find.byKey(const Key('dp_wallet_error')), findsOneWidget);
      await tester.tap(find.byKey(const Key('dp_wallet_retry')));
      verify(() => errorBloc.add(const DeliveryWalletInitEvent())).called(1);
    });
  });
}
