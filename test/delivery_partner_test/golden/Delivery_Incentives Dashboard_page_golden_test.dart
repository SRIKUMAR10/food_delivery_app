import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/services.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Incentives%20Dashboard_page/Delivery_Incentives%20Dashboard_page_bloc.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Incentives%20Dashboard_page/Delivery_Incentives%20Dashboard_page_event.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Incentives%20Dashboard_page/Delivery_Incentives%20Dashboard_page_state.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Incentives%20Dashboard_page/Delivery_Incentives%20Dashboard_page_ui.dart';

import '../../font_loader_helper.dart';

class MockDeliveryIncentivesDashboardPageBloc
    extends
        MockBloc<
          DeliveryIncentivesDashboardPageEvent,
          DeliveryIncentivesDashboardState
        >
    implements DeliveryIncentivesDashboardPageBloc {}

DeliveryIncentivesDashboardLoadedState buildLoadedState() {
  final now = DateTime(2026, 7, 31);
  return DeliveryIncentivesDashboardLoadedState(
    targetDeadline: DateTime(2026, 8, 31),
    walletBalance: 2450.00,
    todayBonus: 350.00,
    todayBonusGrowth: 12.5,
    weeklyBonus: 1250.00,
    weeklyBonusGrowth: 18.6,
    monthlyBonus: 4750.00,
    monthlyBonusGrowth: 24.3,
    targetProgress: 76.0,
    targetEarned: 7650.00,
    targetGoal: 10000.00,
    rangePoints: {
      IncentivesDateRange.thisMonth: [
        DeliveryIncentivesBonusPoint(label: '6AM', value: 40.0, date: now),
        DeliveryIncentivesBonusPoint(label: '9AM', value: 55.0, date: now),
      ],
    },
    achievements: [
      DeliveryIncentivesAchievement(
        id: 'early_bird',
        title: 'Early Bird',
        progress: 1,
        target: 1,
        completed: true,
      ),
    ],
    donutSlices: const [
      DeliveryIncentivesDonutSlice(category: 'performance', value: 1850.00),
      DeliveryIncentivesDonutSlice(category: 'peakHour', value: 1450.00),
    ],
    milestones: const [
      DeliveryIncentivesMilestone(
        target: 10,
        completed: 10,
        status: DeliveryIncentivesMilestoneStatus.completed,
      ),
      DeliveryIncentivesMilestone(
        target: 25,
        completed: 15,
        status: DeliveryIncentivesMilestoneStatus.inProgress,
      ),
    ],
    rewardHistory: [
      DeliveryIncentivesRewardRecord(
        id: 'r_1',
        title: 'Peak Hour Reward',
        date: now,
        amount: 120.00,
        type: RewardFilterType.peakHour,
        status: 'completed',
        referenceId: 'REF-1040',
      ),
    ],
  );
}

void main() {
  late MockDeliveryIncentivesDashboardPageBloc mockBloc;

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
    mockBloc = MockDeliveryIncentivesDashboardPageBloc();
    when(() => mockBloc.state).thenReturn(buildLoadedState());
  });

  Widget buildPage() {
    return MaterialApp(
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0D1117),
      ),
      home: Scaffold(body: DeliveryIncentivesDashboardPage(bloc: mockBloc)),
    );
  }

  group('DeliveryIncentivesDashboardPage Golden Tests', () {
    testWidgets('renders dark obsidian dashboard layout on desktop', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(1440, 1024);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(buildPage());
      await tester.pump();

      expect(find.byType(DeliveryIncentivesDashboardPage), findsOneWidget);
      expect(find.text('Incentives Dashboard'), findsOneWidget);
      expect(find.byKey(const Key('dp_incentives_header')), findsOneWidget);
      expect(
        find.byKey(const Key('dp_incentives_summary_today')),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('dp_incentives_summary_target')),
        findsOneWidget,
      );
    });

    testWidgets('renders dark theme dashboard layout on tablet viewport', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(800, 1024);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(buildPage());
      await tester.pump();

      expect(find.byKey(const Key('dp_incentives_page')), findsOneWidget);
      expect(
        find.byKey(const Key('dp_incentives_overview_card')),
        findsOneWidget,
      );
      expect(find.byKey(const Key('dp_incentives_donut_card')), findsOneWidget);
    });

    testWidgets('renders dark theme dashboard layout on mobile viewport', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(buildPage());
      await tester.pump();

      expect(find.byKey(const Key('dp_incentives_page')), findsOneWidget);
      expect(
        find.byKey(const Key('dp_incentives_summary_today')),
        findsOneWidget,
      );
      expect(find.byKey(const Key('dp_incentives_donut_card')), findsOneWidget);
    });

    testWidgets('matches dark obsidian color palette', (tester) async {
      tester.view.physicalSize = const Size(1280, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(buildPage());
      await tester.pump();

      final metric = tester.widget<Container>(
        find
            .descendant(
              of: find.byKey(const Key('dp_incentives_summary_today')),
              matching: find.byType(Container),
            )
            .first,
      );
      final metricDecoration = metric.decoration as BoxDecoration;
      expect(metricDecoration.color, const Color(0xFF161B22));

      final donutCard = tester.widget<Container>(
        find.byKey(const Key('dp_incentives_donut_card')),
      );
      final donutDecoration = donutCard.decoration as BoxDecoration;
      expect(donutDecoration.color, const Color(0xFF161B22));
    });

    testWidgets('renders skeleton while loading for golden stability', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(1280, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      when(
        () => mockBloc.state,
      ).thenReturn(const DeliveryIncentivesDashboardLoadingState());

      await tester.pumpWidget(buildPage());
      await tester.pump();

      expect(find.byKey(const Key('dp_incentives_skeleton')), findsOneWidget);
    });
  });
}
