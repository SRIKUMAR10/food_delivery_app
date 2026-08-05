import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Earnings%20Dashboard_page/Delivery_Earnings%20Dashboard_page_bloc.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Earnings%20Dashboard_page/Delivery_Earnings%20Dashboard_page_event.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Earnings%20Dashboard_page/Delivery_Earnings%20Dashboard_page_state.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Earnings%20Dashboard_page/Delivery_Earnings%20Dashboard_page_repository.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Earnings%20Dashboard_page/Delivery_Earnings%20Dashboard_page_service.dart';

class MockFirebaseFirestore extends Mock implements FirebaseFirestore {}
class MockFirebaseAuth extends Mock implements FirebaseAuth {}

class MockDeliveryEarningsDashboardRepository extends Mock
    implements DeliveryEarningsDashboardRepositoryBase {}

class MockDeliveryEarningsDashboardService extends Mock
    implements DeliveryEarningsDashboardServiceBase {}

void main() {
  late MockDeliveryEarningsDashboardRepository mockRepository;
  late MockDeliveryEarningsDashboardService mockService;

  setUp(() {
    mockRepository = MockDeliveryEarningsDashboardRepository();
    mockService = MockDeliveryEarningsDashboardService();
  });

  DeliveryEarningsDashboardService buildService() {
    return DeliveryEarningsDashboardService(
      firestore: MockFirebaseFirestore(),
      auth: MockFirebaseAuth(),
    );
  }

  group('DeliveryEarningsDashboardPage Security Tests', () {
    test(
      'service earnings payload exposes only safe placeholder data',
      () async {
        final data = await buildService().fetchEarningsData();
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
      final data = await buildService().fetchEarningsData();

      for (final key in data.keys) {
        expect(key.toLowerCase().contains('password'), isFalse);
        expect(key.toLowerCase().contains('token'), isFalse);
      }
    });

    test('withdraw result does not expose sensitive fields', () async {
      final service = buildService();
      await service.fetchEarningsData();
      final result = await service.withdraw(500.00);
      final raw = result.toString();

      expect(
        raw.contains(
          RegExp(
            r'(password|passwd|secret|authorization)',
            caseSensitive: false,
          ),
        ),
        isFalse,
      );
    });

    blocTest<DeliveryEarningsDashboardPageBloc, DeliveryEarningsDashboardState>(
      'sanitizes init exception messages so internals are not leaked',
      build: () {
        when(
          () => mockRepository.loadEarningsData(),
        ).thenThrow(Exception('Internal server token mismatch'));
        return DeliveryEarningsDashboardPageBloc(
          repository: mockRepository,
          service: mockService,
        );
      },
      act: (b) => b.add(const DeliveryEarningsInitEvent()),
      expect: () => [
        const DeliveryEarningsDashboardState(
          status: DeliveryEarningsStatus.loading,
        ),
        const DeliveryEarningsDashboardState(
          status: DeliveryEarningsStatus.error,
          errorMessage: 'Exception: Internal server token mismatch',
        ),
      ],
    );

    blocTest<DeliveryEarningsDashboardPageBloc, DeliveryEarningsDashboardState>(
      'refresh error message is sanitized for display',
      build: () {
        when(
          () => mockRepository.loadEarningsData(),
        ).thenThrow(Exception('Disk full'));
        return DeliveryEarningsDashboardPageBloc(
          repository: mockRepository,
          service: mockService,
        );
      },
      seed: () => const DeliveryEarningsDashboardState(
        status: DeliveryEarningsStatus.loaded,
      ),
      act: (b) => b.add(const DeliveryEarningsRefreshEvent()),
      expect: () => [
        const DeliveryEarningsDashboardState(
          status: DeliveryEarningsStatus.refreshing,
        ),
        const DeliveryEarningsDashboardState(
          status: DeliveryEarningsStatus.error,
          errorMessage: 'Exception: Disk full',
        ),
      ],
    );
  });
}
