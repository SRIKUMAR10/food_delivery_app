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
    when(() => mockService.streamLiveLocation(highAccuracy: any(named: 'highAccuracy')))
        .thenAnswer((_) => const Stream.empty());
    when(() => mockService.streamLiveLocation()).thenAnswer((_) => const Stream.empty());
    when(() => mockService.simulateLiveLocation()).thenAnswer((_) => const Stream.empty());
    when(() => mockRepository.fetchActiveOrderData()).thenAnswer((_) async => null);
    when(() => mockRepository.fetchPartnerProfile()).thenAnswer((_) async => null);
    when(() => mockRepository.watchActiveOrder()).thenAnswer((_) => const Stream.empty());
    when(() => mockRepository.watchPartnerProfile()).thenAnswer((_) => const Stream.empty());
    when(() => mockRepository.fetchNearbySellers()).thenAnswer((_) async => const []);
    when(() => mockRepository.watchNearbySellers()).thenAnswer((_) => const Stream.empty());
    when(() => mockService.getCurrentLocation(highAccuracy: any(named: 'highAccuracy'))).thenAnswer((_) async => null);
    when(() => mockService.fetchDemandZones()).thenAnswer((_) async => const []);
  });

  DeliveryNavigationBloc buildBloc() {
    return DeliveryNavigationBloc(
      repository: mockRepository,
      service: mockService,
    );
  }

  void stubLoadedState() {
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

  group('DeliveryNavigationScreenPage State Restoration Tests', () {
    blocTest<DeliveryNavigationBloc, DeliveryNavigationState>(
      'restores previously saved audio guidance preference on init',
      build: () {
        stubLoadedState();
        when(
          () => mockRepository.getAudioEnabled(),
        ).thenAnswer((_) async => true);
        return buildBloc();
      },
      act: (b) => b.add(const DeliveryNavigationInitEvent()),
      expect: () => const [
        DeliveryNavigationState(status: DeliveryNavigationStatus.loading),
        DeliveryNavigationState(
          status: DeliveryNavigationStatus.loaded,
          hasLocationPermission: true,
          isGpsServiceEnabled: true,
          audioEnabled: true,
          gpsStatus: DeliveryGpsStatus.active,
          order: DeliveryNavigationRepository.defaultOrder,
          pickup: DeliveryNavigationRepository.defaultPickup,
          drop: DeliveryNavigationRepository.defaultDrop,
        ),
      ],
    );

    blocTest<DeliveryNavigationBloc, DeliveryNavigationState>(
      'restores persisted emergency mode and locale on init',
      build: () {
        stubLoadedState();
        when(
          () => mockRepository.getEmergencyMode(),
        ).thenAnswer((_) async => true);
        when(
          () => mockRepository.getLocaleCode(),
        ).thenAnswer((_) async => 'ta');
        return buildBloc();
      },
      act: (b) => b.add(const DeliveryNavigationInitEvent()),
      expect: () => const [
        DeliveryNavigationState(status: DeliveryNavigationStatus.loading),
        DeliveryNavigationState(
          status: DeliveryNavigationStatus.loaded,
          hasLocationPermission: true,
          isGpsServiceEnabled: true,
          emergencyMode: true,
          localeCode: 'ta',
          gpsStatus: DeliveryGpsStatus.active,
          order: DeliveryNavigationRepository.defaultOrder,
          pickup: DeliveryNavigationRepository.defaultPickup,
          drop: DeliveryNavigationRepository.defaultDrop,
        ),
      ],
    );

    blocTest<DeliveryNavigationBloc, DeliveryNavigationState>(
      'keeps navigation guidance stable across refresh cycles',
      build: () {
        stubLoadedState();
        return buildBloc();
      },
      seed: () => const DeliveryNavigationState(
        status: DeliveryNavigationStatus.navigating,
        hasLocationPermission: true,
        audioEnabled: true,
        turnDistanceMeters: 120.0,
        order: DeliveryNavigationRepository.defaultOrder,
        pickup: DeliveryNavigationRepository.defaultPickup,
        drop: DeliveryNavigationRepository.defaultDrop,
      ),
      act: (b) => b.add(const DeliveryNavigationRefreshEvent()),
      expect: () => const [
        DeliveryNavigationState(
          status: DeliveryNavigationStatus.loaded,
          hasLocationPermission: true,
          isGpsServiceEnabled: true,
          turnDistanceMeters: 120.0,
          gpsStatus: DeliveryGpsStatus.active,
          order: DeliveryNavigationRepository.defaultOrder,
          pickup: DeliveryNavigationRepository.defaultPickup,
          drop: DeliveryNavigationRepository.defaultDrop,
        ),
      ],
    );
  });
}
