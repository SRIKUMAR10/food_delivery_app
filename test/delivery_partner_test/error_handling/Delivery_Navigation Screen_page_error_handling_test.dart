import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Navigation%20Screen_page/Delivery_Navigation%20Screen_page_bloc.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Navigation%20Screen_page/Delivery_Navigation%20Screen_page_event.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Navigation%20Screen_page/Delivery_Navigation%20Screen_page_state.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Navigation%20Screen_page/Delivery_Navigation%20Screen_page_repository.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Navigation%20Screen_page/Delivery_Navigation%20Screen_page_service.dart';

class MockDeliveryNavigationRepository extends Mock
    implements DeliveryNavigationRepositoryBase {}

class MockDeliveryNavigationService extends Mock
    implements DeliveryNavigationServiceBase {}

void main() {
  late MockDeliveryNavigationRepository mockRepository;
  late MockDeliveryNavigationService mockService;

  setUp(() {
    mockRepository = MockDeliveryNavigationRepository();
    mockService = MockDeliveryNavigationService();
    when(() => mockService.checkGpsStatus()).thenAnswer((_) async => true);
    when(() => mockService.streamLiveLocation(highAccuracy: any(named: 'highAccuracy'))).thenAnswer((_) => const Stream.empty());
    when(() => mockService.streamLiveLocation()).thenAnswer((_) => const Stream.empty());
    when(() => mockService.simulateLiveLocation()).thenAnswer((_) => const Stream.empty());
    when(() => mockRepository.fetchActiveOrderData()).thenAnswer((_) async => null);
    when(() => mockRepository.fetchPartnerProfile()).thenAnswer((_) async => null);
    when(() => mockRepository.watchActiveOrder()).thenAnswer((_) => const Stream.empty());
    when(() => mockRepository.watchPartnerProfile()).thenAnswer((_) => const Stream.empty());
  });

  void stubHappyPath() {
    when(() => mockService.checkConnectivity()).thenAnswer((_) async => true);
    when(
      () => mockService.checkLocationPermission(),
    ).thenAnswer((_) async => true);
    when(
      () => mockRepository.fetchOrderSummary(),
    ).thenAnswer((_) async => DeliveryNavigationRepository.defaultOrder);
    when(
      () => mockRepository.fetchPickup(),
    ).thenAnswer((_) async => DeliveryNavigationRepository.defaultPickup);
    when(
      () => mockRepository.fetchDrop(),
    ).thenAnswer((_) async => DeliveryNavigationRepository.defaultDrop);
    when(() => mockRepository.getAudioEnabled()).thenAnswer((_) async => false);
    when(
      () => mockRepository.getEmergencyMode(),
    ).thenAnswer((_) async => false);
    when(() => mockRepository.getLocaleCode()).thenAnswer((_) async => 'en');
  }

  group('DeliveryNavigationScreenPage Error Handling Tests', () {
    blocTest<DeliveryNavigationBloc, DeliveryNavigationState>(
      'transitions to error state when route data fetch fails on init',
      build: () {
        when(
          () => mockService.checkConnectivity(),
        ).thenAnswer((_) async => true);
        when(
          () => mockService.checkLocationPermission(),
        ).thenAnswer((_) async => true);
        when(
          () => mockRepository.fetchOrderSummary(),
        ).thenThrow(Exception('Route service unavailable'));
        return DeliveryNavigationBloc(
          repository: mockRepository,
          service: mockService,
        );
      },
      act: (b) => b.add(const DeliveryNavigationInitEvent()),
      expect: () => const [
        DeliveryNavigationState(status: DeliveryNavigationStatus.loading),
        DeliveryNavigationState(
          status: DeliveryNavigationStatus.error,
          errorMessage: 'Route service unavailable',
        ),
      ],
    );

    blocTest<DeliveryNavigationBloc, DeliveryNavigationState>(
      'retries a failed load and recovers on RefreshEvent',
      build: () {
        var fetchCalls = 0;
        when(
          () => mockService.checkConnectivity(),
        ).thenAnswer((_) async => true);
        when(
          () => mockService.checkLocationPermission(),
        ).thenAnswer((_) async => true);
        when(() => mockRepository.fetchOrderSummary()).thenAnswer((_) async {
          fetchCalls += 1;
          if (fetchCalls == 1) {
            throw Exception('Timeout');
          }
          return DeliveryNavigationRepository.defaultOrder;
        });
        when(
          () => mockRepository.fetchPickup(),
        ).thenAnswer((_) async => DeliveryNavigationRepository.defaultPickup);
        when(
          () => mockRepository.fetchDrop(),
        ).thenAnswer((_) async => DeliveryNavigationRepository.defaultDrop);
        when(
          () => mockRepository.getAudioEnabled(),
        ).thenAnswer((_) async => false);
        when(
          () => mockRepository.getEmergencyMode(),
        ).thenAnswer((_) async => false);
        return DeliveryNavigationBloc(
          repository: mockRepository,
          service: mockService,
        );
      },
      seed: () => const DeliveryNavigationState(
        status: DeliveryNavigationStatus.error,
        errorMessage: 'Timeout',
      ),
      act: (b) {
        b.add(const DeliveryNavigationRefreshEvent());
        b.add(const DeliveryNavigationRefreshEvent());
      },
      expect: () => const [
        DeliveryNavigationState(
          status: DeliveryNavigationStatus.loaded,
          hasLocationPermission: true,
          isGpsServiceEnabled: true,
          gpsStatus: DeliveryGpsStatus.active,
          order: DeliveryNavigationRepository.defaultOrder,
          pickup: DeliveryNavigationRepository.defaultPickup,
          drop: DeliveryNavigationRepository.defaultDrop,
        ),
      ],
    );

    blocTest<DeliveryNavigationBloc, DeliveryNavigationState>(
      'stops at empty state when no active delivery exists',
      build: () {
        when(
          () => mockService.checkConnectivity(),
        ).thenAnswer((_) async => true);
        when(
          () => mockService.checkLocationPermission(),
        ).thenAnswer((_) async => true);
        when(() => mockRepository.fetchOrderSummary()).thenAnswer(
          (_) async => const DeliveryNavigationOrderSummary(
            orderId: '',
            pickupLabel: '',
            pickupAddress: '',
            dropLabel: '',
            dropAddress: '',
            customerName: '',
            customerPhone: '',
            status: '',
          ),
        );
        when(
          () => mockRepository.fetchPickup(),
        ).thenAnswer((_) async => DeliveryNavigationRepository.defaultPickup);
        when(
          () => mockRepository.fetchDrop(),
        ).thenAnswer((_) async => DeliveryNavigationRepository.defaultDrop);
        when(
          () => mockRepository.getAudioEnabled(),
        ).thenAnswer((_) async => false);
        when(
          () => mockRepository.getEmergencyMode(),
        ).thenAnswer((_) async => false);
        when(
          () => mockRepository.getLocaleCode(),
        ).thenAnswer((_) async => 'en');
        return DeliveryNavigationBloc(
          repository: mockRepository,
          service: mockService,
        );
      },
      act: (b) => b.add(const DeliveryNavigationInitEvent()),
      expect: () => const [
        DeliveryNavigationState(status: DeliveryNavigationStatus.loading),
        DeliveryNavigationState(
          status: DeliveryNavigationStatus.loaded,
          hasLocationPermission: true,
          isGpsServiceEnabled: true,
          gpsStatus: DeliveryGpsStatus.active,
          order: DeliveryNavigationOrderSummary(
            orderId: '',
            pickupLabel: '',
            pickupAddress: '',
            dropLabel: '',
            dropAddress: '',
            customerName: '',
            customerPhone: '',
            status: '',
          ),
          pickup: DeliveryNavigationRepository.defaultPickup,
          drop: DeliveryNavigationRepository.defaultDrop,
        ),
      ],
    );

    blocTest<DeliveryNavigationBloc, DeliveryNavigationState>(
      'surfaces error when live location stream fails and keeps guidance',
      build: () {
        stubHappyPath();
        when(
          () => mockRepository.saveAudioEnabled(true),
        ).thenAnswer((_) async {});
        when(
          () => mockService.streamLiveLocation(highAccuracy: any(named: 'highAccuracy')),
        ).thenAnswer((_) => Stream<Map<String, dynamic>>.error(Exception('GPS lost')));
        return DeliveryNavigationBloc(
          repository: mockRepository,
          service: mockService,
        );
      },
      seed: () => const DeliveryNavigationState(
        status: DeliveryNavigationStatus.loaded,
        hasLocationPermission: true,
        order: DeliveryNavigationRepository.defaultOrder,
        pickup: DeliveryNavigationRepository.defaultPickup,
        drop: DeliveryNavigationRepository.defaultDrop,
        turnDistanceMeters: 250.0,
      ),
      act: (b) {
        b.add(const DeliveryNavigationStartNavigationEvent());
      },
      expect: () => const [
        DeliveryNavigationState(
          status: DeliveryNavigationStatus.navigating,
          hasLocationPermission: true,
          order: DeliveryNavigationRepository.defaultOrder,
          pickup: DeliveryNavigationRepository.defaultPickup,
          drop: DeliveryNavigationRepository.defaultDrop,
          turnDistanceMeters: 250.0,
          audioEnabled: true,
          gpsStatus: DeliveryGpsStatus.searching,
        ),
        DeliveryNavigationState(
          status: DeliveryNavigationStatus.navigating,
          hasLocationPermission: true,
          order: DeliveryNavigationRepository.defaultOrder,
          pickup: DeliveryNavigationRepository.defaultPickup,
          drop: DeliveryNavigationRepository.defaultDrop,
          turnDistanceMeters: 250.0,
          audioEnabled: true,
          gpsStatus: DeliveryGpsStatus.disabled,
        ),
      ],
    );
  });
}
