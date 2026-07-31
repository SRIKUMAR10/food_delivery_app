import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Incentives%20Dashboard_page/Delivery_Incentives%20Dashboard_page_bloc.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Incentives%20Dashboard_page/Delivery_Incentives%20Dashboard_page_event.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Incentives%20Dashboard_page/Delivery_Incentives%20Dashboard_page_state.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Incentives%20Dashboard_page/Delivery_Incentives%20Dashboard_page_repository.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Incentives%20Dashboard_page/Delivery_Incentives%20Dashboard_page_service.dart';

class MockDeliveryIncentivesDashboardRepository extends Mock
    implements DeliveryIncentivesDashboardRepositoryBase {}

class MockDeliveryIncentivesDashboardService extends Mock
    implements DeliveryIncentivesDashboardServiceBase {}

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
        DeliveryIncentivesBonusPoint(label: '12PM', value: 70.0, date: now),
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
    ],
    milestones: [
      const DeliveryIncentivesMilestone(
        target: 10,
        completed: 10,
        status: DeliveryIncentivesMilestoneStatus.completed,
      ),
      const DeliveryIncentivesMilestone(
        target: 100,
        completed: 62,
        status: DeliveryIncentivesMilestoneStatus.inProgress,
      ),
    ],
    rewardHistory: List.generate(
      12,
      (i) => DeliveryIncentivesRewardRecord(
        id: 'inc_rw_${i + 1}',
        title: 'Peak Hour Bonus',
        date: now.subtract(Duration(days: i)),
        amount: 120.0,
        type: i.isEven
            ? RewardFilterType.peakHour
            : RewardFilterType.performance,
        status: 'completed',
        referenceId: 'REF-${1040 + i}',
      ),
    ),
  );
}

DeliveryIncentivesDashboardLoadedState buildEmptyState() {
  return buildLoadedState().copyWith(
    rewardHistory: const [],
    donutSlices: const [],
  );
}

void main() {
  late MockDeliveryIncentivesDashboardRepository mockRepository;
  late MockDeliveryIncentivesDashboardService mockService;

  setUp(() {
    mockRepository = MockDeliveryIncentivesDashboardRepository();
    mockService = MockDeliveryIncentivesDashboardService();
  });

  group('DeliveryIncentivesDashboardPageBloc Unit Tests', () {
    test('initial state is DeliveryIncentivesDashboardInitialState', () {
      final bloc = DeliveryIncentivesDashboardPageBloc(
        repository: mockRepository,
        service: mockService,
      );

      expect(bloc.state, isA<DeliveryIncentivesDashboardInitialState>());
      expect(bloc.state.selectedRange, IncentivesDateRange.thisMonth);
      expect(bloc.state.localeCode, 'en');
      bloc.close();
    });

    blocTest<
      DeliveryIncentivesDashboardPageBloc,
      DeliveryIncentivesDashboardState
    >(
      'emits [loading, loaded] on fetch success',
      build: () {
        when(
          () => mockRepository.loadIncentivesData(),
        ).thenAnswer((_) async => buildLoadedState());
        return DeliveryIncentivesDashboardPageBloc(
          repository: mockRepository,
          service: mockService,
        );
      },
      act: (bloc) => bloc.add(const FetchIncentivesDataEvent()),
      expect: () => [
        const DeliveryIncentivesDashboardLoadingState(),
        buildLoadedState(),
      ],
      verify: (_) {
        verify(() => mockRepository.loadIncentivesData()).called(1);
      },
    );

    blocTest<
      DeliveryIncentivesDashboardPageBloc,
      DeliveryIncentivesDashboardState
    >(
      'emits [loading, error] on fetch failure',
      build: () {
        when(
          () => mockRepository.loadIncentivesData(),
        ).thenThrow(Exception('Server unreachable'));
        return DeliveryIncentivesDashboardPageBloc(
          repository: mockRepository,
          service: mockService,
        );
      },
      act: (bloc) => bloc.add(const FetchIncentivesDataEvent()),
      expect: () => [
        const DeliveryIncentivesDashboardLoadingState(),
        const DeliveryIncentivesDashboardErrorState(
          errorMessage: 'Exception: Server unreachable',
        ),
      ],
    );

    blocTest<
      DeliveryIncentivesDashboardPageBloc,
      DeliveryIncentivesDashboardState
    >(
      'emits [loading, empty] when dashboard data has no rewards',
      build: () {
        when(
          () => mockRepository.loadIncentivesData(),
        ).thenAnswer((_) async => buildEmptyState());
        return DeliveryIncentivesDashboardPageBloc(
          repository: mockRepository,
          service: mockService,
        );
      },
      act: (bloc) => bloc.add(const FetchIncentivesDataEvent()),
      expect: () => [
        const DeliveryIncentivesDashboardLoadingState(),
        const DeliveryIncentivesDashboardEmptyState(),
      ],
    );

    blocTest<
      DeliveryIncentivesDashboardPageBloc,
      DeliveryIncentivesDashboardState
    >(
      'emits [loading, loaded] on refresh success',
      build: () {
        when(
          () => mockRepository.loadIncentivesData(),
        ).thenAnswer((_) async => buildLoadedState());
        return DeliveryIncentivesDashboardPageBloc(
          repository: mockRepository,
          service: mockService,
        );
      },
      seed: () => buildLoadedState(),
      act: (bloc) => bloc.add(const RefreshIncentivesDataEvent()),
      expect: () => [
        const DeliveryIncentivesDashboardLoadingState(),
        buildLoadedState(),
      ],
    );

    blocTest<
      DeliveryIncentivesDashboardPageBloc,
      DeliveryIncentivesDashboardState
    >(
      'refresh failure emits error state',
      build: () {
        when(
          () => mockRepository.loadIncentivesData(),
        ).thenThrow(Exception('Disk full'));
        return DeliveryIncentivesDashboardPageBloc(
          repository: mockRepository,
          service: mockService,
        );
      },
      seed: () => buildLoadedState(),
      act: (bloc) => bloc.add(const RefreshIncentivesDataEvent()),
      expect: () => [
        const DeliveryIncentivesDashboardLoadingState(),
        const DeliveryIncentivesDashboardErrorState(
          errorMessage: 'Exception: Disk full',
        ),
      ],
    );

    blocTest<
      DeliveryIncentivesDashboardPageBloc,
      DeliveryIncentivesDashboardState
    >(
      'filter updates active filter and resets to first page',
      build: () => DeliveryIncentivesDashboardPageBloc(
        repository: mockRepository,
        service: mockService,
      ),
      seed: () => buildLoadedState().copyWith(currentPage: 1),
      act: (bloc) =>
          bloc.add(const FilterRewardHistoryEvent(RewardFilterType.peakHour)),
      expect: () => [
        buildLoadedState().copyWith(
          activeFilter: RewardFilterType.peakHour,
          currentPage: 0,
        ),
      ],
    );

    blocTest<
      DeliveryIncentivesDashboardPageBloc,
      DeliveryIncentivesDashboardState
    >(
      'filter is ignored when state is not loaded',
      build: () => DeliveryIncentivesDashboardPageBloc(
        repository: mockRepository,
        service: mockService,
      ),
      act: (bloc) => bloc.add(
        const FilterRewardHistoryEvent(RewardFilterType.performance),
      ),
      expect: () => [],
    );

    blocTest<
      DeliveryIncentivesDashboardPageBloc,
      DeliveryIncentivesDashboardState
    >(
      'change page advances the current page',
      build: () => DeliveryIncentivesDashboardPageBloc(
        repository: mockRepository,
        service: mockService,
      ),
      seed: () => buildLoadedState(),
      act: (bloc) => bloc.add(const ChangePageEvent(1)),
      expect: () => [buildLoadedState().copyWith(currentPage: 1)],
    );

    blocTest<
      DeliveryIncentivesDashboardPageBloc,
      DeliveryIncentivesDashboardState
    >(
      'change page clamps invalid page numbers',
      build: () => DeliveryIncentivesDashboardPageBloc(
        repository: mockRepository,
        service: mockService,
      ),
      seed: () => buildLoadedState(),
      act: (bloc) => bloc.add(const ChangePageEvent(99)),
      expect: () => [],
    );

    blocTest<
      DeliveryIncentivesDashboardPageBloc,
      DeliveryIncentivesDashboardState
    >(
      'export emits exporting progress and completes',
      build: () {
        when(
          () => mockRepository.exportRewardHistory(any()),
        ).thenAnswer((_) async => 'csv data');
        return DeliveryIncentivesDashboardPageBloc(
          repository: mockRepository,
          service: mockService,
        );
      },
      seed: () => buildLoadedState(),
      act: (bloc) => bloc.add(const ExportRewardHistoryEvent()),
      expect: () => [
        buildLoadedState().copyWith(isExporting: true),
        buildLoadedState().copyWith(isExporting: false),
      ],
      verify: (_) {
        verify(() => mockRepository.exportRewardHistory(any())).called(1);
      },
    );

    blocTest<
      DeliveryIncentivesDashboardPageBloc,
      DeliveryIncentivesDashboardState
    >(
      'export failure resets exporting without changing dashboard',
      build: () {
        when(
          () => mockRepository.exportRewardHistory(any()),
        ).thenThrow(Exception('Export gateway down'));
        return DeliveryIncentivesDashboardPageBloc(
          repository: mockRepository,
          service: mockService,
        );
      },
      seed: () => buildLoadedState(),
      act: (bloc) => bloc.add(const ExportRewardHistoryEvent()),
      expect: () => [
        buildLoadedState().copyWith(isExporting: true),
        buildLoadedState().copyWith(isExporting: false),
      ],
    );

    blocTest<
      DeliveryIncentivesDashboardPageBloc,
      DeliveryIncentivesDashboardState
    >(
      'update date range changes the selected range',
      build: () => DeliveryIncentivesDashboardPageBloc(
        repository: mockRepository,
        service: mockService,
      ),
      seed: () => buildLoadedState(),
      act: (bloc) =>
          bloc.add(const UpdateDateRangeEvent(IncentivesDateRange.thisWeek)),
      expect: () => [
        buildLoadedState().copyWith(
          selectedRange: IncentivesDateRange.thisWeek,
        ),
      ],
    );

    blocTest<
      DeliveryIncentivesDashboardPageBloc,
      DeliveryIncentivesDashboardState
    >(
      'update date range is ignored when state is not loaded',
      build: () => DeliveryIncentivesDashboardPageBloc(
        repository: mockRepository,
        service: mockService,
      ),
      act: (bloc) =>
          bloc.add(const UpdateDateRangeEvent(IncentivesDateRange.today)),
      expect: () => [],
    );
  });
}
