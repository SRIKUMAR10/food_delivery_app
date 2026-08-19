import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Dashboard_page/Delivery_Dashboard_page_bloc.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Dashboard_page/Delivery_Dashboard_page_event.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Dashboard_page/Delivery_Dashboard_page_state.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Dashboard_page/Delivery_Dashboard_page_repository.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Dashboard_page/Delivery_Dashboard_page_service.dart';

class MockDeliveryDashboardRepository extends Mock
    implements DeliveryDashboardRepositoryBase {}

class MockDeliveryDashboardService extends Mock
    implements DeliveryDashboardServiceBase {}

void main() {
  late MockDeliveryDashboardRepository mockRepository;
  late MockDeliveryDashboardService mockService;

  setUp(() {
    mockRepository = MockDeliveryDashboardRepository();
    mockService = MockDeliveryDashboardService();
    registerFallbackValue(const DeliveryDashboardState());
  });

  group('DeliveryDashboardPage Security Tests', () {
    test('service metric payload exposes only safe data without credentials', () async {
      final service = DeliveryDashboardService();
      final metrics = await service.fetchDashboardMetrics();
      final raw = metrics.toString();

      expect(
        raw.contains(
          RegExp(r'(password|passwd|secret_key|private_key)', caseSensitive: false),
        ),
        isFalse,
      );
    });

    test('service payload does not contain connection secrets', () async {
      final service = DeliveryDashboardService();
      final metrics = await service.fetchDashboardMetrics();

      for (final key in metrics.keys) {
        expect(key.toLowerCase().contains('password'), isFalse);
        expect(key.toLowerCase().contains('secret_key'), isFalse);
      }
    });

    blocTest<DeliveryDashboardPageBloc, DeliveryDashboardState>(
      'sanitizes refresh exception messages safely',
      build: () {
        when(
          () => mockRepository.loadDashboardData(),
        ).thenThrow(Exception('Disk full'));
        return DeliveryDashboardPageBloc(
          repository: mockRepository,
          service: mockService,
        );
      },
      seed: () =>
          const DeliveryDashboardState(status: DeliveryDashboardStatus.loaded),
      act: (b) => b.add(const DeliveryDashboardRefreshEvent()),
      expect: () => [
        const DeliveryDashboardState(status: DeliveryDashboardStatus.loading),
        const DeliveryDashboardState(
          status: DeliveryDashboardStatus.error,
          errorMessage: 'Exception: Disk full',
        ),
      ],
    );
  });
}
