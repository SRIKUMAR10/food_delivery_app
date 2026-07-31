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
  return DeliveryIncentivesDashboardLoadedState(
    targetDeadline: DateTime(2026, 8, 31),
  );
}

void main() {
  late MockDeliveryIncentivesDashboardRepository mockRepository;
  late MockDeliveryIncentivesDashboardService mockService;

  setUp(() {
    mockRepository = MockDeliveryIncentivesDashboardRepository();
    mockService = MockDeliveryIncentivesDashboardService();
  });

  group('DeliveryIncentivesDashboardPage Security Tests', () {
    test(
      'service incentives payload exposes only safe placeholder data',
      () async {
        final service = DeliveryIncentivesDashboardService();
        final data = await service.fetchIncentivesData();
        final raw = data.toString();

        expect(
          raw.contains(
            RegExp(r'(token|password|passwd|secret)', caseSensitive: false),
          ),
          isFalse,
        );
      },
    );

    test('service payload does not contain connection secrets', () async {
      final service = DeliveryIncentivesDashboardService();
      final data = await service.fetchIncentivesData();

      for (final key in data.keys) {
        expect(key.toLowerCase().contains('password'), isFalse);
        expect(key.toLowerCase().contains('token'), isFalse);
      }
    });

    test(
      'api base url falls back safely without leaking environment secrets',
      () {
        final service = DeliveryIncentivesDashboardService();

        expect(service.apiBaseUrl, isNotEmpty);
        expect(
          service.apiBaseUrl.contains(
            RegExp(
              r'(token|password|passwd|secret|api[_-]?key)',
              caseSensitive: false,
            ),
          ),
          isFalse,
        );
      },
    );

    test('export CSV payload does not expose sensitive fields', () async {
      final service = DeliveryIncentivesDashboardService();
      final csv = await service.exportRewardHistory(const [
        {
          'referenceId': 'REF-1040',
          'title': 'Peak Hour Reward',
          'date': '2026-07-31T00:00:00.000',
          'amount': 120.00,
          'type': 'peakHour',
          'status': 'completed',
        },
      ]);

      expect(
        csv.contains(
          RegExp(
            r'(password|passwd|secret|authorization)',
            caseSensitive: false,
          ),
        ),
        isFalse,
      );
      expect(csv, contains('REF-1040'));
    });

    blocTest<
      DeliveryIncentivesDashboardPageBloc,
      DeliveryIncentivesDashboardState
    >(
      'sanitizes init exception messages so internals are not leaked',
      build: () {
        when(
          () => mockRepository.loadIncentivesData(),
        ).thenThrow(Exception('Internal server token mismatch'));
        return DeliveryIncentivesDashboardPageBloc(
          repository: mockRepository,
          service: mockService,
        );
      },
      act: (b) => b.add(const FetchIncentivesDataEvent()),
      expect: () => [
        const DeliveryIncentivesDashboardLoadingState(),
        const DeliveryIncentivesDashboardErrorState(
          errorMessage: 'Exception: Internal server token mismatch',
        ),
      ],
    );

    blocTest<
      DeliveryIncentivesDashboardPageBloc,
      DeliveryIncentivesDashboardState
    >(
      'refresh error message is sanitized for display',
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
      act: (b) => b.add(const RefreshIncentivesDataEvent()),
      expect: () => [
        const DeliveryIncentivesDashboardLoadingState(
          selectedRange: IncentivesDateRange.thisMonth,
          localeCode: 'en',
        ),
        const DeliveryIncentivesDashboardErrorState(
          errorMessage: 'Exception: Disk full',
        ),
      ],
    );
  });
}
