import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Earnings%20Dashboard_page/Delivery_Earnings%20Dashboard_page_bloc.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Earnings%20Dashboard_page/Delivery_Earnings%20Dashboard_page_event.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Earnings%20Dashboard_page/Delivery_Earnings%20Dashboard_page_state.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Earnings%20Dashboard_page/Delivery_Earnings%20Dashboard_page_ui.dart';

class MockDeliveryEarningsDashboardPageBloc
    extends
        MockBloc<
          DeliveryEarningsDashboardPageEvent,
          DeliveryEarningsDashboardState
        >
    implements DeliveryEarningsDashboardPageBloc {}

DeliveryEarningsDashboardState buildLoadedState({
  EarningsTab selectedTab = EarningsTab.overview,
}) {
  final now = DateTime(2026, 7, 31);
  return DeliveryEarningsDashboardState(
    status: DeliveryEarningsStatus.loaded,
    totalEarnings: 12850.00,
    todayEarnings: 2450.00,
    weeklyEarnings: 12850.00,
    monthlyEarnings: 48900.00,
    earningsGrowth: 18.5,
    walletBalance: 12850.00,
    pendingWithdrawal: 1200.00,
    totalWithdrawn: 48250.00,
    selectedTab: selectedTab,
    rangeEarnings: {
      EarningsDateRange.today: [
        DeliveryEarningsPoint(label: '6AM', value: 180.0, date: now),
        DeliveryEarningsPoint(label: '12PM', value: 320.0, date: now),
      ],
    },
    transactions: [
      DeliveryEarningsTransaction(
        id: 'tx_1',
        title: 'Delivery Earnings',
        date: now,
        amount: 240.00,
        type: EarningsTransactionType.credit,
        status: 'completed',
      ),
    ],
    withdrawalHistory: [
      DeliveryWithdrawalRecord(
        id: 'wd_1',
        amount: 2000.00,
        method: 'Bank Transfer',
        date: now,
        status: 'completed',
      ),
    ],
  );
}

void main() {
  late MockDeliveryEarningsDashboardPageBloc mockBloc;

  setUpAll(() {
    registerFallbackValue(
      const DeliveryEarningsRangeChangedEvent(EarningsDateRange.today),
    );
    registerFallbackValue(
      const DeliveryEarningsTabChangedEvent(EarningsTab.overview),
    );
    registerFallbackValue(const DeliveryEarningsWithdrawEvent(0));
    registerFallbackValue(const DeliveryEarningsMediaUploadStartedEvent());
  });

  setUp(() {
    mockBloc = MockDeliveryEarningsDashboardPageBloc();
    when(() => mockBloc.state).thenReturn(buildLoadedState());
  });

  void setDesktopSize(WidgetTester tester) {
    tester.view.physicalSize = const Size(1280, 1000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
  }

  Widget buildPage() {
    return MaterialApp(
      home: Scaffold(body: DeliveryEarningsDashboardPage(bloc: mockBloc)),
    );
  }

  group('DeliveryEarningsDashboardPage Widget Tests', () {
    testWidgets('renders overview header, metrics, chart and wallet card', (
      tester,
    ) async {
      setDesktopSize(tester);
      await tester.pumpWidget(buildPage());
      await tester.pump();

      expect(find.text('Earnings Overview'), findsOneWidget);
      expect(
        find.byKey(const Key('dp_earnings_summary_total')),
        findsOneWidget,
      );
      expect(find.text('₹12850.00'), findsWidgets);
      expect(find.byKey(const Key('dp_earnings_chart_card')), findsOneWidget);
      expect(find.byKey(const Key('dp_earnings_wallet_card')), findsOneWidget);
      expect(
        find.byKey(const Key('dp_earnings_withdraw_button')),
        findsOneWidget,
      );
      expect(find.text('Withdraw'), findsOneWidget);
      expect(find.text('Upload Delivery Proof'), findsOneWidget);
    });

    testWidgets('renders transactions tab content when transactions selected', (
      tester,
    ) async {
      setDesktopSize(tester);
      when(
        () => mockBloc.state,
      ).thenReturn(buildLoadedState(selectedTab: EarningsTab.transactions));
      await tester.pumpWidget(buildPage());
      await tester.pump();

      expect(
        find.byKey(const Key('dp_earnings_transactions_list')),
        findsOneWidget,
      );
      expect(find.text('Recent Transactions'), findsOneWidget);
      expect(find.text('Delivery Earnings'), findsOneWidget);
    });

    testWidgets('renders withdrawals tab content when withdrawals selected', (
      tester,
    ) async {
      setDesktopSize(tester);
      when(
        () => mockBloc.state,
      ).thenReturn(buildLoadedState(selectedTab: EarningsTab.withdrawals));
      await tester.pumpWidget(buildPage());
      await tester.pump();

      expect(
        find.byKey(const Key('dp_earnings_withdrawals_list')),
        findsOneWidget,
      );
      expect(find.text('Withdrawal History'), findsOneWidget);
      expect(find.text('Bank Transfer'), findsWidgets);
    });

    testWidgets('tapping a range chip dispatches range changed event', (
      tester,
    ) async {
      setDesktopSize(tester);
      await tester.pumpWidget(buildPage());
      await tester.pump();

      await tester.tap(find.byKey(const Key('dp_earnings_range_thisWeek')));
      await tester.pump();

      verify(
        () => mockBloc.add(
          const DeliveryEarningsRangeChangedEvent(EarningsDateRange.thisWeek),
        ),
      ).called(1);
    });

    testWidgets('tapping a tab chip dispatches tab changed event', (
      tester,
    ) async {
      setDesktopSize(tester);
      await tester.pumpWidget(buildPage());
      await tester.pump();

      await tester.tap(find.byKey(const Key('dp_earnings_tab_transactions')));
      await tester.pump();

      verify(
        () => mockBloc.add(
          const DeliveryEarningsTabChangedEvent(EarningsTab.transactions),
        ),
      ).called(1);
    });

    testWidgets('withdraw dialog confirms and dispatches withdraw event', (
      tester,
    ) async {
      setDesktopSize(tester);
      await tester.pumpWidget(buildPage());
      await tester.pump();

      await tester.tap(find.byKey(const Key('dp_earnings_withdraw_button')));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('Withdraw Funds'), findsOneWidget);

      await tester.enterText(
        find.byKey(const Key('dp_earnings_withdraw_amount')),
        '500',
      );
      await tester.tap(find.byKey(const Key('dp_earnings_withdraw_confirm')));
      await tester.pump();

      verify(
        () => mockBloc.add(const DeliveryEarningsWithdrawEvent(500.0)),
      ).called(1);
    });

    testWidgets('tapping upload media dispatches upload started event', (
      tester,
    ) async {
      setDesktopSize(tester);
      await tester.pumpWidget(buildPage());
      await tester.pump();

      await tester.tap(
        find.byKey(const Key('dp_earnings_media_upload_button')),
      );
      await tester.pump();

      verify(
        () => mockBloc.add(const DeliveryEarningsMediaUploadStartedEvent()),
      ).called(1);
    });

    testWidgets('shows skeleton while loading', (tester) async {
      setDesktopSize(tester);
      when(() => mockBloc.state).thenReturn(
        const DeliveryEarningsDashboardState(
          status: DeliveryEarningsStatus.loading,
        ),
      );
      await tester.pumpWidget(buildPage());
      await tester.pump();

      expect(find.byKey(const Key('dp_earnings_skeleton')), findsOneWidget);
    });

    testWidgets('shows error shell with retry when state is error', (
      tester,
    ) async {
      setDesktopSize(tester);
      when(() => mockBloc.state).thenReturn(
        const DeliveryEarningsDashboardState(
          status: DeliveryEarningsStatus.error,
          errorMessage: 'Server unreachable',
        ),
      );
      await tester.pumpWidget(buildPage());
      await tester.pump();

      expect(find.byKey(const Key('dp_earnings_error')), findsOneWidget);
      expect(find.textContaining('Server unreachable'), findsWidgets);
      expect(find.byKey(const Key('dp_earnings_retry')), findsOneWidget);

      await tester.tap(find.byKey(const Key('dp_earnings_retry')));
      await tester.pump();

      verify(() => mockBloc.add(const DeliveryEarningsInitEvent())).called(1);
    });
  });
}
