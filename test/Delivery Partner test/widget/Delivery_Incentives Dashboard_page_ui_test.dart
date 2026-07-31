import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Incentives%20Dashboard_page/Delivery_Incentives%20Dashboard_page_bloc.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Incentives%20Dashboard_page/Delivery_Incentives%20Dashboard_page_event.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Incentives%20Dashboard_page/Delivery_Incentives%20Dashboard_page_state.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Incentives%20Dashboard_page/Delivery_Incentives%20Dashboard_page_ui.dart';

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
    targetDeadline: DateTime(2026, 8, 31),
    rangePoints: {
      IncentivesDateRange.today: [
        DeliveryIncentivesBonusPoint(label: '6AM', value: 40.0, date: now),
        DeliveryIncentivesBonusPoint(label: '9AM', value: 55.0, date: now),
        DeliveryIncentivesBonusPoint(label: '12PM', value: 70.0, date: now),
      ],
      IncentivesDateRange.thisWeek: [
        DeliveryIncentivesBonusPoint(label: 'Mon', value: 210.0, date: now),
        DeliveryIncentivesBonusPoint(label: 'Tue', value: 240.0, date: now),
      ],
      IncentivesDateRange.thisMonth: [
        DeliveryIncentivesBonusPoint(label: 'W1', value: 950.0, date: now),
        DeliveryIncentivesBonusPoint(label: 'W2', value: 1100.0, date: now),
      ],
    },
    achievements: [
      DeliveryIncentivesAchievement(
        id: 'early_bird',
        title: 'Early Bird',
        progress: 1.0,
        target: 1.0,
        completed: true,
      ),
      DeliveryIncentivesAchievement(
        id: 'consistent_star',
        title: 'Consistent Star',
        progress: 15.0,
        target: 20.0,
        completed: false,
      ),
    ],
    donutSlices: [
      const DeliveryIncentivesDonutSlice(
        category: 'performance',
        value: 2100.00,
      ),
      const DeliveryIncentivesDonutSlice(category: 'peakHour', value: 1350.00),
      const DeliveryIncentivesDonutSlice(category: 'incentive', value: 900.00),
      const DeliveryIncentivesDonutSlice(category: 'others', value: 400.00),
    ],
    milestones: [
      const DeliveryIncentivesMilestone(
        target: 10,
        completed: 10,
        status: DeliveryIncentivesMilestoneStatus.completed,
      ),
      const DeliveryIncentivesMilestone(
        target: 25,
        completed: 25,
        status: DeliveryIncentivesMilestoneStatus.completed,
      ),
      const DeliveryIncentivesMilestone(
        target: 50,
        completed: 50,
        status: DeliveryIncentivesMilestoneStatus.completed,
      ),
      const DeliveryIncentivesMilestone(
        target: 100,
        completed: 62,
        status: DeliveryIncentivesMilestoneStatus.inProgress,
      ),
      const DeliveryIncentivesMilestone(
        target: 200,
        completed: 0,
        status: DeliveryIncentivesMilestoneStatus.locked,
      ),
    ],
    rewardHistory: List.generate(
      32,
      (i) => DeliveryIncentivesRewardRecord(
        id: 'inc_rw_${i + 1}',
        title: 'Reward #${i + 1}',
        date: now.subtract(Duration(days: i)),
        amount: 120.0,
        type: RewardFilterType.peakHour,
        status: 'completed',
        referenceId: 'REF-${1040 + i}',
      ),
    ),
  );
}

void main() {
  late MockDeliveryIncentivesDashboardPageBloc mockBloc;

  setUpAll(() {
    registerFallbackValue(const FilterRewardHistoryEvent(RewardFilterType.all));
    registerFallbackValue(const ChangePageEvent(0));
    registerFallbackValue(const ExportRewardHistoryEvent());
    registerFallbackValue(
      const UpdateDateRangeEvent(IncentivesDateRange.today),
    );
    registerFallbackValue(const FetchIncentivesDataEvent());
    registerFallbackValue(const RefreshIncentivesDataEvent());
  });

  setUp(() {
    mockBloc = MockDeliveryIncentivesDashboardPageBloc();
    when(() => mockBloc.state).thenReturn(buildLoadedState());
  });

  void setDesktopSize(WidgetTester tester) {
    tester.view.physicalSize = const Size(1280, 1000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
  }

  Widget buildPage() {
    return MaterialApp(
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0D1117),
      ),
      home: Scaffold(body: DeliveryIncentivesDashboardPage(bloc: mockBloc)),
    );
  }

  group('DeliveryIncentivesDashboardPage Widget Tests', () {
    testWidgets('renders header, wallet balance and partner profile', (
      tester,
    ) async {
      setDesktopSize(tester);
      await tester.pumpWidget(buildPage());
      await tester.pump();

      expect(find.text('Incentives Dashboard'), findsOneWidget);
      expect(find.text('₹2450.00'), findsWidgets);
      expect(find.text('Ravi Kumar'), findsOneWidget);
      expect(find.text('TN 01 AB 1234'), findsOneWidget);
      expect(
        find.byKey(const Key('dp_incentives_notification')),
        findsOneWidget,
      );
    });

    testWidgets('renders all four summary metric cards', (tester) async {
      setDesktopSize(tester);
      await tester.pumpWidget(buildPage());
      await tester.pump();

      expect(
        find.byKey(const Key('dp_incentives_summary_today')),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('dp_incentives_summary_weekly')),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('dp_incentives_summary_monthly')),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('dp_incentives_summary_target')),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('dp_incentives_target_progress_bar')),
        findsOneWidget,
      );
      expect(find.text("Today's Bonus"), findsOneWidget);
      expect(find.text('₹350.00'), findsOneWidget);
      expect(find.text('₹1250.00'), findsOneWidget);
      expect(find.text('₹4750.00'), findsWidgets);
    });

    testWidgets('renders overview chart, donut and achievements sections', (
      tester,
    ) async {
      setDesktopSize(tester);
      await tester.pumpWidget(buildPage());
      await tester.pump();

      expect(
        find.byKey(const Key('dp_incentives_overview_card')),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('dp_incentives_overview_chart')),
        findsOneWidget,
      );
      expect(find.byKey(const Key('dp_incentives_donut_card')), findsOneWidget);
      expect(
        find.byKey(const Key('dp_incentives_donut_chart')),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('dp_incentives_achievements_carousel')),
        findsOneWidget,
      );
      expect(find.text('Early Bird'), findsOneWidget);
    });

    testWidgets('renders milestones stepper with all nodes', (tester) async {
      setDesktopSize(tester);
      await tester.pumpWidget(buildPage());
      await tester.pump();

      expect(
        find.byKey(const Key('dp_incentives_milestones_card')),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('dp_incentives_milestone_10')),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('dp_incentives_milestone_25')),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('dp_incentives_milestone_50')),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('dp_incentives_milestone_100')),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('dp_incentives_milestone_200')),
        findsOneWidget,
      );
    });

    testWidgets(
      'renders reward history table with filter, export and pagination',
      (tester) async {
        setDesktopSize(tester);
        await tester.pumpWidget(buildPage());
        await tester.pump();

        expect(
          find.byKey(const Key('dp_incentives_reward_history_card')),
          findsOneWidget,
        );
        expect(find.byKey(const Key('dp_incentives_export')), findsOneWidget);
        expect(
          find.byKey(const Key('dp_incentives_filter_all')),
          findsOneWidget,
        );
        expect(
          find.byKey(const Key('dp_incentives_filter_peakhour')),
          findsOneWidget,
        );
        expect(find.text('REF-1040'), findsOneWidget);
        expect(find.text('1 to 5 of 32 rewards'), findsOneWidget);
      },
    );

    testWidgets('tapping a filter chip dispatches filter event', (
      tester,
    ) async {
      setDesktopSize(tester);
      await tester.pumpWidget(buildPage());
      await tester.pump();

      final filterChip = find.byKey(const Key('dp_incentives_filter_peakhour'));
      await tester.ensureVisible(filterChip);
      await tester.tap(filterChip);
      await tester.pump();

      verify(
        () => mockBloc.add(
          const FilterRewardHistoryEvent(RewardFilterType.peakHour),
        ),
      ).called(1);
    });

    testWidgets('tapping export dispatches export event', (tester) async {
      setDesktopSize(tester);
      await tester.pumpWidget(buildPage());
      await tester.pump();

      final exportButton = find.byKey(const Key('dp_incentives_export'));
      await tester.ensureVisible(exportButton);
      await tester.tap(exportButton);
      await tester.pump();

      verify(() => mockBloc.add(const ExportRewardHistoryEvent())).called(1);
    });

    testWidgets('tapping a range chip dispatches update range event', (
      tester,
    ) async {
      setDesktopSize(tester);
      await tester.pumpWidget(buildPage());
      await tester.pump();

      final rangeChip = find.byKey(const Key('dp_incentives_range_thisWeek'));
      await tester.ensureVisible(rangeChip);
      await tester.tap(rangeChip);
      await tester.pump();

      verify(
        () => mockBloc.add(
          const UpdateDateRangeEvent(IncentivesDateRange.thisWeek),
        ),
      ).called(1);
    });

    testWidgets('tapping next page dispatches change page event', (
      tester,
    ) async {
      setDesktopSize(tester);
      await tester.pumpWidget(buildPage());
      await tester.pump();

      final nextButton = find.byKey(const Key('dp_incentives_page_next'));
      await tester.ensureVisible(nextButton);
      await tester.tap(nextButton);
      await tester.pump();

      verify(() => mockBloc.add(const ChangePageEvent(1))).called(1);
    });

    testWidgets('shows skeleton while loading', (tester) async {
      setDesktopSize(tester);
      when(
        () => mockBloc.state,
      ).thenReturn(const DeliveryIncentivesDashboardLoadingState());
      await tester.pumpWidget(buildPage());
      await tester.pump();

      expect(find.byKey(const Key('dp_incentives_skeleton')), findsOneWidget);
    });

    testWidgets('shows error shell with retry when state is error', (
      tester,
    ) async {
      setDesktopSize(tester);
      when(() => mockBloc.state).thenReturn(
        const DeliveryIncentivesDashboardErrorState(
          errorMessage: 'Server unreachable',
        ),
      );
      await tester.pumpWidget(buildPage());
      await tester.pump();

      expect(find.byKey(const Key('dp_incentives_error')), findsOneWidget);
      expect(find.textContaining('Server unreachable'), findsWidgets);
      expect(find.byKey(const Key('dp_incentives_retry')), findsOneWidget);

      await tester.tap(find.byKey(const Key('dp_incentives_retry')));
      await tester.pump();

      verify(() => mockBloc.add(const FetchIncentivesDataEvent())).called(1);
    });

    testWidgets('shows empty shell when state is empty', (tester) async {
      setDesktopSize(tester);
      when(
        () => mockBloc.state,
      ).thenReturn(const DeliveryIncentivesDashboardEmptyState());
      await tester.pumpWidget(buildPage());
      await tester.pump();

      expect(find.byKey(const Key('dp_incentives_empty')), findsOneWidget);
      expect(find.text('No incentives yet'), findsOneWidget);
    });
  });
}
