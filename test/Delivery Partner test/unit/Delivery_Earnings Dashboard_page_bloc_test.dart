import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Earnings%20Dashboard_page/Delivery_Earnings%20Dashboard_page_bloc.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Earnings%20Dashboard_page/Delivery_Earnings%20Dashboard_page_event.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Earnings%20Dashboard_page/Delivery_Earnings%20Dashboard_page_state.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Earnings%20Dashboard_page/Delivery_Earnings%20Dashboard_page_repository.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Earnings%20Dashboard_page/Delivery_Earnings%20Dashboard_page_service.dart';

class MockDeliveryEarningsDashboardRepository extends Mock
    implements DeliveryEarningsDashboardRepositoryBase {}

class MockDeliveryEarningsDashboardService extends Mock
    implements DeliveryEarningsDashboardServiceBase {}

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
    selectedRange: EarningsDateRange.today,
    selectedTab: EarningsTab.overview,
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
  late MockDeliveryEarningsDashboardRepository mockRepository;
  late MockDeliveryEarningsDashboardService mockService;

  setUp(() {
    mockRepository = MockDeliveryEarningsDashboardRepository();
    mockService = MockDeliveryEarningsDashboardService();
  });

  group('DeliveryEarningsDashboardPageBloc Unit Tests', () {
    test('initial state starts at default state with initial status', () {
      final bloc = DeliveryEarningsDashboardPageBloc(
        repository: mockRepository,
        service: mockService,
      );

      expect(bloc.state.status, DeliveryEarningsStatus.initial);
      expect(bloc.state.totalEarnings, 12850.00);
      expect(bloc.state.walletBalance, 12850.00);
      expect(bloc.state.todayEarnings, 2450.00);
      expect(bloc.state.weeklyEarnings, 12850.00);
      expect(bloc.state.monthlyEarnings, 48900.00);
      expect(bloc.state.earningsGrowth, 18.5);
      expect(bloc.state.selectedRange, EarningsDateRange.today);
      expect(bloc.state.selectedTab, EarningsTab.overview);
      expect(bloc.state.rangeEarnings, isEmpty);
      expect(bloc.state.transactions, isEmpty);
      expect(bloc.state.withdrawalHistory, isEmpty);
      expect(bloc.state.isMediaUploading, isFalse);
      expect(bloc.state.isWithdrawing, isFalse);
      bloc.close();
    });

    blocTest<DeliveryEarningsDashboardPageBloc, DeliveryEarningsDashboardState>(
      'emits [loading, loaded] on init success',
      build: () {
        when(
          () => mockRepository.loadEarningsData(),
        ).thenAnswer((_) async => buildLoadedState());
        return DeliveryEarningsDashboardPageBloc(
          repository: mockRepository,
          service: mockService,
        );
      },
      act: (bloc) => bloc.add(const DeliveryEarningsInitEvent()),
      expect: () => [
        const DeliveryEarningsDashboardState(
          status: DeliveryEarningsStatus.loading,
        ),
        buildLoadedState(),
      ],
      verify: (_) {
        verify(() => mockRepository.loadEarningsData()).called(1);
      },
    );

    blocTest<DeliveryEarningsDashboardPageBloc, DeliveryEarningsDashboardState>(
      'emits [loading, error] on init failure',
      build: () {
        when(
          () => mockRepository.loadEarningsData(),
        ).thenThrow(Exception('Server unreachable'));
        return DeliveryEarningsDashboardPageBloc(
          repository: mockRepository,
          service: mockService,
        );
      },
      act: (bloc) => bloc.add(const DeliveryEarningsInitEvent()),
      expect: () => [
        const DeliveryEarningsDashboardState(
          status: DeliveryEarningsStatus.loading,
        ),
        const DeliveryEarningsDashboardState(
          status: DeliveryEarningsStatus.error,
          errorMessage: 'Exception: Server unreachable',
        ),
      ],
    );

    blocTest<DeliveryEarningsDashboardPageBloc, DeliveryEarningsDashboardState>(
      'emits [refreshing, loaded] on refresh success',
      build: () {
        when(
          () => mockRepository.loadEarningsData(),
        ).thenAnswer((_) async => buildLoadedState());
        return DeliveryEarningsDashboardPageBloc(
          repository: mockRepository,
          service: mockService,
        );
      },
      seed: () => buildLoadedState(),
      act: (bloc) => bloc.add(const DeliveryEarningsRefreshEvent()),
      expect: () => [
        buildLoadedState().copyWith(status: DeliveryEarningsStatus.refreshing),
        buildLoadedState(),
      ],
    );

    blocTest<DeliveryEarningsDashboardPageBloc, DeliveryEarningsDashboardState>(
      'emits updated range when range changed event is added',
      build: () => DeliveryEarningsDashboardPageBloc(
        repository: mockRepository,
        service: mockService,
      ),
      seed: () => buildLoadedState(),
      act: (bloc) => bloc.add(
        const DeliveryEarningsRangeChangedEvent(EarningsDateRange.thisWeek),
      ),
      expect: () => [
        buildLoadedState().copyWith(selectedRange: EarningsDateRange.thisWeek),
      ],
    );

    blocTest<DeliveryEarningsDashboardPageBloc, DeliveryEarningsDashboardState>(
      'emits updated tab when tab changed event is added',
      build: () => DeliveryEarningsDashboardPageBloc(
        repository: mockRepository,
        service: mockService,
      ),
      seed: () => buildLoadedState(),
      act: (bloc) => bloc.add(
        const DeliveryEarningsTabChangedEvent(EarningsTab.transactions),
      ),
      expect: () => [
        buildLoadedState().copyWith(selectedTab: EarningsTab.transactions),
      ],
    );

    blocTest<DeliveryEarningsDashboardPageBloc, DeliveryEarningsDashboardState>(
      'withdraw emits withdrawing and updated wallet balance on success',
      build: () {
        when(() => mockRepository.withdraw(500.0)).thenAnswer(
          (_) async => buildLoadedState().copyWith(walletBalance: 12350.00),
        );
        return DeliveryEarningsDashboardPageBloc(
          repository: mockRepository,
          service: mockService,
        );
      },
      seed: () => buildLoadedState(),
      act: (bloc) => bloc.add(const DeliveryEarningsWithdrawEvent(500.0)),
      expect: () => [
        buildLoadedState().copyWith(isWithdrawing: true),
        buildLoadedState().copyWith(walletBalance: 12350.00),
      ],
      verify: (_) {
        verify(() => mockRepository.withdraw(500.0)).called(1);
      },
    );

    blocTest<DeliveryEarningsDashboardPageBloc, DeliveryEarningsDashboardState>(
      'withdraw rejects non-positive amounts without calling repository',
      build: () => DeliveryEarningsDashboardPageBloc(
        repository: mockRepository,
        service: mockService,
      ),
      seed: () => buildLoadedState(),
      act: (bloc) => bloc.add(const DeliveryEarningsWithdrawEvent(0.0)),
      expect: () => [
        buildLoadedState().copyWith(
          errorMessage: 'Please enter a valid withdrawal amount.',
        ),
      ],
      verify: (_) {
        verifyNever(() => mockRepository.withdraw(any()));
      },
    );

    blocTest<DeliveryEarningsDashboardPageBloc, DeliveryEarningsDashboardState>(
      'withdraw rejects amounts exceeding wallet balance',
      build: () => DeliveryEarningsDashboardPageBloc(
        repository: mockRepository,
        service: mockService,
      ),
      seed: () => buildLoadedState(),
      act: (bloc) => bloc.add(const DeliveryEarningsWithdrawEvent(20000.0)),
      expect: () => [
        buildLoadedState().copyWith(
          errorMessage:
              'Withdrawal amount exceeds your available wallet balance.',
        ),
      ],
      verify: (_) {
        verifyNever(() => mockRepository.withdraw(any()));
      },
    );

    blocTest<DeliveryEarningsDashboardPageBloc, DeliveryEarningsDashboardState>(
      'withdraw failure emits friendly error and resets withdrawing',
      build: () {
        when(
          () => mockRepository.withdraw(500.0),
        ).thenThrow(Exception('Gateway timeout'));
        return DeliveryEarningsDashboardPageBloc(
          repository: mockRepository,
          service: mockService,
        );
      },
      seed: () => buildLoadedState(),
      act: (bloc) => bloc.add(const DeliveryEarningsWithdrawEvent(500.0)),
      expect: () => [
        buildLoadedState().copyWith(isWithdrawing: true),
        buildLoadedState().copyWith(
          isWithdrawing: false,
          errorMessage: 'Withdrawal failed. Please try again.',
        ),
      ],
    );

    blocTest<DeliveryEarningsDashboardPageBloc, DeliveryEarningsDashboardState>(
      'media upload started streams progress and completes',
      build: () {
        when(
          () => mockRepository.mediaUploadStream(),
        ).thenAnswer((_) => Stream<double>.fromIterable([0.2, 0.5, 1.0]));
        return DeliveryEarningsDashboardPageBloc(
          repository: mockRepository,
          service: mockService,
        );
      },
      seed: () => buildLoadedState(),
      act: (bloc) => bloc.add(const DeliveryEarningsMediaUploadStartedEvent()),
      expect: () => [
        buildLoadedState().copyWith(
          isMediaUploading: true,
          mediaUploadProgress: 0.0,
        ),
        buildLoadedState().copyWith(
          isMediaUploading: true,
          mediaUploadProgress: 0.2,
        ),
        buildLoadedState().copyWith(
          isMediaUploading: true,
          mediaUploadProgress: 0.5,
        ),
        buildLoadedState().copyWith(
          isMediaUploading: false,
          mediaUploadProgress: 1.0,
        ),
      ],
    );

    blocTest<DeliveryEarningsDashboardPageBloc, DeliveryEarningsDashboardState>(
      'media upload progress event updates progress state',
      build: () => DeliveryEarningsDashboardPageBloc(
        repository: mockRepository,
        service: mockService,
      ),
      seed: () => buildLoadedState(),
      act: (bloc) =>
          bloc.add(const DeliveryEarningsMediaUploadProgressEvent(0.6)),
      expect: () => [
        buildLoadedState().copyWith(
          isMediaUploading: true,
          mediaUploadProgress: 0.6,
        ),
      ],
    );

    blocTest<DeliveryEarningsDashboardPageBloc, DeliveryEarningsDashboardState>(
      'media upload completed event finalizes upload state',
      build: () => DeliveryEarningsDashboardPageBloc(
        repository: mockRepository,
        service: mockService,
      ),
      seed: () => buildLoadedState(),
      act: (bloc) =>
          bloc.add(const DeliveryEarningsMediaUploadCompletedEvent()),
      expect: () => [
        buildLoadedState().copyWith(
          isMediaUploading: false,
          mediaUploadProgress: 1.0,
        ),
      ],
    );
  });
}
