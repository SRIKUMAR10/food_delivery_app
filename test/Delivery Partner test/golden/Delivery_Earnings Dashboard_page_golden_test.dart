import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/services.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Earnings%20Dashboard_page/Delivery_Earnings%20Dashboard_page_bloc.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Earnings%20Dashboard_page/Delivery_Earnings%20Dashboard_page_event.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Earnings%20Dashboard_page/Delivery_Earnings%20Dashboard_page_state.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Earnings%20Dashboard_page/Delivery_Earnings%20Dashboard_page_ui.dart';

import '../../font_loader_helper.dart';

class MockDeliveryEarningsDashboardPageBloc
    extends
        MockBloc<
          DeliveryEarningsDashboardPageEvent,
          DeliveryEarningsDashboardState
        >
    implements DeliveryEarningsDashboardPageBloc {}

DeliveryEarningsDashboardState buildLoadedState() {
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
    rangeEarnings: {
      EarningsDateRange.today: [
        DeliveryEarningsPoint(label: '6AM', value: 180.0, date: now),
        DeliveryEarningsPoint(label: '9AM', value: 220.0, date: now),
        DeliveryEarningsPoint(label: '12PM', value: 320.0, date: now),
        DeliveryEarningsPoint(label: '3PM', value: 410.0, date: now),
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
    overrideFontAssetLoading();

    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          const MethodChannel('plugins.flutter.io/path_provider'),
          (MethodCall methodCall) async {
            return '.';
          },
        );
  });

  setUp(() {
    mockBloc = MockDeliveryEarningsDashboardPageBloc();
    when(() => mockBloc.state).thenReturn(buildLoadedState());
  });

  Widget buildPage() {
    return MaterialApp(
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0D131E),
      ),
      home: Scaffold(body: DeliveryEarningsDashboardPage(bloc: mockBloc)),
    );
  }

  group('DeliveryEarningsDashboardPage Golden Tests', () {
    testWidgets('renders dark glassmorphic dashboard layout on desktop', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(1440, 1024);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(buildPage());
      await tester.pump();

      expect(find.byType(DeliveryEarningsDashboardPage), findsOneWidget);
      expect(find.byKey(const Key('dp_earnings_greeting')), findsOneWidget);
      expect(
        find.byKey(const Key('dp_earnings_summary_total')),
        findsOneWidget,
      );
      expect(find.byKey(const Key('dp_earnings_wallet_card')), findsOneWidget);
      expect(find.text('Earnings Overview'), findsOneWidget);
    });

    testWidgets('renders dark theme dashboard layout on tablet viewport', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(800, 1024);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(buildPage());
      await tester.pump();

      expect(find.byKey(const Key('dp_earnings_page')), findsOneWidget);
      expect(find.byKey(const Key('dp_earnings_chart_card')), findsOneWidget);
      expect(find.byKey(const Key('dp_earnings_wallet_card')), findsOneWidget);
    });

    testWidgets('renders dark theme dashboard layout on mobile viewport', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(buildPage());
      await tester.pump();

      expect(find.byKey(const Key('dp_earnings_page')), findsOneWidget);
      expect(
        find.byKey(const Key('dp_earnings_summary_total')),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('dp_earnings_media_upload_card')),
        findsOneWidget,
      );
    });

    testWidgets('matches dark glassmorphic color palette', (tester) async {
      tester.view.physicalSize = const Size(1280, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(buildPage());
      await tester.pump();

      final metric = tester.widget<Container>(
        find
            .descendant(
              of: find.byKey(const Key('dp_earnings_summary_total')),
              matching: find.byType(Container),
            )
            .first,
      );
      final metricDecoration = metric.decoration as BoxDecoration;
      expect(metricDecoration.color, const Color(0xFF0F1E26));

      final walletCard = tester.widget<Container>(
        find.byKey(const Key('dp_earnings_wallet_card')),
      );
      final walletDecoration = walletCard.decoration as BoxDecoration;
      final gradient = walletDecoration.gradient as LinearGradient;
      expect(gradient.colors.first, const Color(0xFF0D1B22));
    });

    testWidgets('renders skeleton while loading for golden stability', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(1280, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      when(() => mockBloc.state).thenReturn(
        const DeliveryEarningsDashboardState(
          status: DeliveryEarningsStatus.loading,
        ),
      );

      await tester.pumpWidget(buildPage());
      await tester.pump();

      expect(find.byKey(const Key('dp_earnings_skeleton')), findsOneWidget);
    });
  });
}
