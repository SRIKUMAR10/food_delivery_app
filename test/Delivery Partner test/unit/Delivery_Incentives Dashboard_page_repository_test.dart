import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Incentives%20Dashboard_page/Delivery_Incentives%20Dashboard_page_repository.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Incentives%20Dashboard_page/Delivery_Incentives%20Dashboard_page_service.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Incentives%20Dashboard_page/Delivery_Incentives%20Dashboard_page_state.dart';

class MockDeliveryIncentivesDashboardService extends Mock
    implements DeliveryIncentivesDashboardServiceBase {}

void main() {
  late DeliveryIncentivesDashboardRepository repository;
  late MockDeliveryIncentivesDashboardService mockService;
  final realService = DeliveryIncentivesDashboardService();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    mockService = MockDeliveryIncentivesDashboardService();
    
    when(() => mockService.fetchIncentivesData()).thenAnswer(
      (_) async => _getMockDataset(),
    );
    when(() => mockService.watchIncentivesData()).thenAnswer(
      (_) => Stream.value(_getMockDataset()),
    );
    when(() => mockService.exportRewardHistory(any())).thenAnswer(
      (invocation) async => realService.exportRewardHistory(
        invocation.positionalArguments[0] as List<Map<String, dynamic>>,
      ),
    );

    repository = DeliveryIncentivesDashboardRepository(
      service: mockService,
      prefs: prefs,
    );
  });

  group('DeliveryIncentivesDashboardPage Repository Tests', () {
    test(
      'watchIncentivesData returns stream of loaded states',
      () async {
        final stream = repository.watchIncentivesData();
        final state = await stream.first;
        expect(state.walletBalance, 2450.00);
        expect(state.todayBonus, 350.00);
      },
    );

    test(
      'loadIncentivesData returns loaded state with correct metrics',
      () async {
        final state = await repository.loadIncentivesData();

        expect(state.walletBalance, 2450.00);
        expect(state.todayBonus, 350.00);
        expect(state.todayBonusGrowth, 12.5);
        expect(state.weeklyBonus, 1250.00);
        expect(state.weeklyBonusGrowth, 18.6);
        expect(state.monthlyBonus, 4750.00);
        expect(state.monthlyBonusGrowth, 24.3);
        expect(state.targetProgress, 76.0);
        expect(state.targetEarned, 7650.00);
        expect(state.targetGoal, 10000.00);
        expect(state.isFromCache, isFalse);
      },
    );

    test(
      'loadIncentivesData parses chart, achievements and milestones',
      () async {
        final state = await repository.loadIncentivesData();

        expect(state.achievements, hasLength(4));
        expect(state.achievements.first.title, 'Early Bird');
        expect(state.donutSlices, hasLength(4));
        expect(state.milestones, hasLength(5));
        expect(
          state.milestones.first.status,
          DeliveryIncentivesMilestoneStatus.completed,
        );
        expect(state.currentRangePoints, isNotEmpty);
      },
    );

    test('loadIncentivesData parses the full reward history', () async {
      final state = await repository.loadIncentivesData();

      expect(state.rewardHistory, hasLength(32));
      expect(state.rewardHistory.first.referenceId, 'REF-1040');
      expect(state.filteredTotal, 32);
    });

    test(
      'loadIncentivesData persists a local cache for offline fallback',
      () async {
        await repository.loadIncentivesData();

        final prefs = await SharedPreferences.getInstance();
        expect(prefs.getString('dp_incentives_cache_v1'), isNotNull);
      },
    );

    test(
      'loadCachedIncentives restores cached snapshot when available',
      () async {
        await repository.loadIncentivesData();
        final cached = await repository.loadCachedIncentives();

        expect(cached, isNotNull);
        expect(cached!.isFromCache, isTrue);
        expect(cached.walletBalance, 2450.00);
        expect(cached.rewardHistory, hasLength(32));
      },
    );

    test('loadCachedIncentives returns null when no cache exists', () async {
      final cached = await repository.loadCachedIncentives();
      expect(cached, isNull);
    });

    test('clearCache removes the persisted snapshot', () async {
      await repository.loadIncentivesData();
      await repository.clearCache();

      final cached = await repository.loadCachedIncentives();
      expect(cached, isNull);
    });

    test('falls back to cached data when the remote service fails', () async {
      await repository.loadIncentivesData();

      final failingService = MockDeliveryIncentivesDashboardService();
      when(
        () => failingService.fetchIncentivesData(),
      ).thenThrow(Exception('offline'));

      final offlineRepository = DeliveryIncentivesDashboardRepository(
        service: failingService,
        prefs: await SharedPreferences.getInstance(),
      );

      final state = await offlineRepository.loadIncentivesData();
      expect(state.isFromCache, isTrue);
      expect(state.walletBalance, 2450.00);
    });

    test('rethrows when service fails and no cache is available', () async {
      final failingService = MockDeliveryIncentivesDashboardService();
      when(
        () => failingService.fetchIncentivesData(),
      ).thenThrow(Exception('offline'));

      final offlineRepository = DeliveryIncentivesDashboardRepository(
        service: failingService,
        prefs: await SharedPreferences.getInstance(),
      );

      expect(
        () => offlineRepository.loadIncentivesData(),
        throwsA(isA<Exception>()),
      );
    });

    test('exportRewardHistory produces a CSV payload', () async {
      final state = await repository.loadIncentivesData();
      final csv = await repository.exportRewardHistory(state.rewardHistory);

      expect(csv, startsWith('Reference,Title,Date,Amount,Type,Status'));
      expect(csv.trim().split('\n'), hasLength(33));
      expect(csv, contains('REF-1040'));
    });
  });
}

Map<String, dynamic> _getMockDataset() {
  final List<Map<String, dynamic>> rewards = List.generate(32, (index) {
    final ref = 'REF-${1040 - index}';
    return {
      'id': 'inc_rw_${index + 1}',
      'referenceId': ref,
      'title': index % 2 == 0 ? 'Peak Hour Bonus' : 'On-Time Delivery Incentive',
      'date': DateTime.now().toIso8601String(),
      'amount': 100.0 + index,
      'type': 'peakHour',
      'status': 'completed',
    };
  });

  return {
    'walletBalance': 2450.00,
    'todayBonus': 350.00,
    'todayBonusGrowth': 12.5,
    'weeklyBonus': 1250.00,
    'weeklyBonusGrowth': 18.6,
    'monthlyBonus': 4750.00,
    'monthlyBonusGrowth': 24.3,
    'targetProgress': 76.0,
    'targetEarned': 7650.00,
    'targetGoal': 10000.00,
    'targetDeadline': DateTime(2026, 8, 31).toIso8601String(),
    'achievements': [
      {'id': 'a1', 'title': 'Early Bird', 'subtitle': 'Deliver before 8 AM', 'progress': 1.0, 'rewardAmount': 50.0, 'isClaimed': true},
      {'id': 'a2', 'title': 'Speed Racer', 'subtitle': 'Fast delivery', 'progress': 0.8, 'rewardAmount': 100.0, 'isClaimed': false},
      {'id': 'a3', 'title': 'Night Owl', 'subtitle': 'Late night delivery', 'progress': 0.5, 'rewardAmount': 75.0, 'isClaimed': false},
      {'id': 'a4', 'title': 'Weekend Warrior', 'subtitle': 'Weekend shifts', 'progress': 0.9, 'rewardAmount': 150.0, 'isClaimed': false},
    ],
    'donutSlices': [
      {'label': 'Peak Hour', 'amount': 1200.0, 'percentage': 40.0, 'hexColor': '#FF0000'},
      {'label': 'Surge', 'amount': 900.0, 'percentage': 30.0, 'hexColor': '#00FF00'},
      {'label': 'Bonus', 'amount': 600.0, 'percentage': 20.0, 'hexColor': '#0000FF'},
      {'label': 'Tips', 'amount': 300.0, 'percentage': 10.0, 'hexColor': '#FFFF00'},
    ],
    'milestones': [
      {'title': '5 Deliveries', 'targetDeliveries': 5, 'completedDeliveries': 5, 'rewardAmount': 50.0, 'status': 'completed'},
      {'title': '10 Deliveries', 'targetDeliveries': 10, 'completedDeliveries': 10, 'rewardAmount': 100.0, 'status': 'completed'},
      {'title': '15 Deliveries', 'targetDeliveries': 15, 'completedDeliveries': 12, 'rewardAmount': 150.0, 'status': 'inProgress'},
      {'title': '20 Deliveries', 'targetDeliveries': 20, 'completedDeliveries': 12, 'rewardAmount': 200.0, 'status': 'locked'},
      {'title': '25 Deliveries', 'targetDeliveries': 25, 'completedDeliveries': 12, 'rewardAmount': 250.0, 'status': 'locked'},
    ],
    'rangePoints': {
      'today': [{'label': 'Mon', 'value': 10.0, 'date': DateTime.now().toIso8601String()}],
      'thisWeek': [{'label': 'Mon', 'value': 10.0, 'date': DateTime.now().toIso8601String()}],
      'thisMonth': [{'label': 'Mon', 'value': 10.0, 'date': DateTime.now().toIso8601String()}],
    },
    'rewards': rewards,
  };
}
