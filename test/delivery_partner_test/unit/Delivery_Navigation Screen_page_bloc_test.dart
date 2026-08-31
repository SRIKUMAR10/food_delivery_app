import 'dart:async';

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

const DeliveryNavigationOrderSummary emptyOrder =
    DeliveryNavigationOrderSummary(
      orderId: '',
      pickupLabel: '',
      pickupAddress: '',
      dropLabel: '',
      dropAddress: '',
      customerName: '',
      customerPhone: '',
      status: '',
    );

void main() {
  late MockDeliveryNavigationRepository mockRepository;
  late MockDeliveryNavigationService mockService;
  late DeliveryNavigationBloc bloc;

  void stubSuccessfulInit() {
    when(() => mockService.checkConnectivity()).thenAnswer((_) async => true);
    when(
      () => mockService.checkLocationPermission(),
    ).thenAnswer((_) async => true);
    when(() => mockService.checkGpsStatus()).thenAnswer((_) async => true);
    when(
      () => mockRepository.fetchOrderSummary(),
    ).thenAnswer((_) async => DeliveryNavigationRepository.defaultOrder);
    when(() => mockRepository.fetchActiveOrderData()).thenAnswer((_) async => null);
    when(
      () => mockRepository.fetchPickup(),
    ).thenAnswer((_) async => DeliveryNavigationRepository.defaultPickup);
    when(
      () => mockRepository.fetchDrop(),
    ).thenAnswer((_) async => DeliveryNavigationRepository.defaultDrop);
    when(() => mockRepository.fetchPartnerProfile()).thenAnswer((_) async => null);
    when(() => mockRepository.watchActiveOrder()).thenAnswer((_) => const Stream.empty());
    when(() => mockRepository.watchPartnerProfile()).thenAnswer((_) => const Stream.empty());
    when(() => mockRepository.fetchNearbySellers()).thenAnswer((_) async => const []);
    when(() => mockRepository.watchNearbySellers()).thenAnswer((_) => const Stream.empty());
    when(() => mockRepository.getAudioEnabled()).thenAnswer((_) async => false);
    when(() => mockRepository.saveAudioEnabled(any())).thenAnswer((_) async {});
    when(() => mockRepository.getEmergencyMode()).thenAnswer((_) async => false);
    when(() => mockRepository.saveEmergencyMode(any())).thenAnswer((_) async {});
    when(() => mockRepository.getLocaleCode()).thenAnswer((_) async => 'en');
    when(() => mockRepository.saveLocaleCode(any())).thenAnswer((_) async {});
    when(() => mockRepository.getHasLocationPermission()).thenAnswer((_) async => true);
    when(() => mockRepository.saveHasLocationPermission(any())).thenAnswer((_) async {});
    when(() => mockService.getCurrentLocation(highAccuracy: any(named: 'highAccuracy'))).thenAnswer((_) async => null);
    when(() => mockService.streamLiveLocation(highAccuracy: any(named: 'highAccuracy'))).thenAnswer((_) => const Stream.empty());
    when(() => mockService.watchActiveOrder(any())).thenAnswer((_) => const Stream.empty());
    when(() => mockService.updateDriverLocation(
      latitude: any(named: 'latitude'),
      longitude: any(named: 'longitude'),
    )).thenAnswer((_) async {});
  }

  setUp(() {
    mockRepository = MockDeliveryNavigationRepository();
    mockService = MockDeliveryNavigationService();
    stubSuccessfulInit();
    bloc = DeliveryNavigationBloc(
      repository: mockRepository,
      service: mockService,
    );
  });

  tearDown(() {
    bloc.close();
  });

  group('DeliveryNavigationBloc Unit Tests', () {
    test('initial state defaults to idle navigation dashboard', () {
      expect(bloc.state.status, DeliveryNavigationStatus.initial);
      expect(bloc.state.isNavigating, isFalse);
      expect(bloc.state.order.orderId, '#ORD-789456');
      expect(bloc.state.etaMinutes, 6);
      expect(bloc.state.distanceKm, 2.1);
      expect(bloc.state.nextTurnInstruction, 'Turn Left onto Bhavani Main Road');
      expect(bloc.state.turnDistanceMeters, 250.0);
      expect(bloc.state.trafficLevel, DeliveryNavigationTrafficLevel.moderate);
      expect(bloc.state.mapZoomLevel, 15.0);
      expect(bloc.state.audioEnabled, isFalse);
      expect(bloc.state.emergencyMode, isFalse);
      expect(bloc.state.localeCode, 'en');
    });

    blocTest<DeliveryNavigationBloc, DeliveryNavigationState>(
      'emits loading then loaded state on InitEvent success',
      build: () {
        stubSuccessfulInit();
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
          isOffline: false,
          audioEnabled: false,
          emergencyMode: false,
          localeCode: 'en',
        ),
      ],
    );

    blocTest<DeliveryNavigationBloc, DeliveryNavigationState>(
      'enters navigating state and enables audio on StartNavigationEvent',
      build: () {
        when(
          () => mockRepository.saveAudioEnabled(true),
        ).thenAnswer((_) async {});
        when(
          () => mockService.simulateLiveLocation(),
        ).thenAnswer((_) => const Stream<double>.empty());
        return DeliveryNavigationBloc(
          repository: mockRepository,
          service: mockService,
        );
      },
      seed: () => const DeliveryNavigationState(
        status: DeliveryNavigationStatus.loaded,
        hasLocationPermission: true,
      ),
      act: (b) => b.add(const DeliveryNavigationStartNavigationEvent()),
      expect: () => const [
        DeliveryNavigationState(
          status: DeliveryNavigationStatus.navigating,
          hasLocationPermission: true,
          audioEnabled: true,
          emergencyMode: false,
        ),
      ],
      verify: (_) {
        verify(() => mockRepository.saveAudioEnabled(true)).called(1);
      },
    );

    blocTest<DeliveryNavigationBloc, DeliveryNavigationState>(
      'ignores repeated StartNavigationEvent while already navigating',
      build: () {
        return DeliveryNavigationBloc(
          repository: mockRepository,
          service: mockService,
        );
      },
      seed: () => const DeliveryNavigationState(
        status: DeliveryNavigationStatus.navigating,
        audioEnabled: true,
      ),
      act: (b) => b.add(const DeliveryNavigationStartNavigationEvent()),
      expect: () => const <DeliveryNavigationState>[],
      verify: (_) {
        verifyNever(() => mockRepository.saveAudioEnabled(any()));
        verifyNever(() => mockService.simulateLiveLocation());
      },
    );

    blocTest<DeliveryNavigationBloc, DeliveryNavigationState>(
      'returns to loaded state and clears emergency on ExitNavigationEvent',
      build: () {
        return DeliveryNavigationBloc(
          repository: mockRepository,
          service: mockService,
        );
      },
      seed: () => const DeliveryNavigationState(
        status: DeliveryNavigationStatus.navigating,
        audioEnabled: true,
        emergencyMode: true,
      ),
      act: (b) => b.add(const DeliveryNavigationExitNavigationEvent()),
      expect: () => const [
        DeliveryNavigationState(
          status: DeliveryNavigationStatus.loaded,
          audioEnabled: true,
          emergencyMode: false,
        ),
      ],
    );

    blocTest<DeliveryNavigationBloc, DeliveryNavigationState>(
      'resets map zoom to default on RecenterMapEvent',
      build: () {
        return DeliveryNavigationBloc(
          repository: mockRepository,
          service: mockService,
        );
      },
      seed: () => const DeliveryNavigationState(
        status: DeliveryNavigationStatus.loaded,
        mapZoomLevel: 12.0,
      ),
      act: (b) => b.add(const DeliveryNavigationRecenterMapEvent()),
      expect: () => const [
        DeliveryNavigationState(
          status: DeliveryNavigationStatus.loaded,
          mapZoomLevel: 15.0,
        ),
      ],
    );

    blocTest<DeliveryNavigationBloc, DeliveryNavigationState>(
      'toggles audio guidance and persists the new preference',
      build: () {
        when(
          () => mockRepository.saveAudioEnabled(true),
        ).thenAnswer((_) async {});
        return DeliveryNavigationBloc(
          repository: mockRepository,
          service: mockService,
        );
      },
      seed: () => const DeliveryNavigationState(
        status: DeliveryNavigationStatus.loaded,
        audioEnabled: false,
      ),
      act: (b) => b.add(const DeliveryNavigationToggleAudioEvent()),
      expect: () => const [
        DeliveryNavigationState(
          status: DeliveryNavigationStatus.loaded,
          audioEnabled: true,
        ),
      ],
      verify: (_) {
        verify(() => mockRepository.saveAudioEnabled(true)).called(1);
      },
    );

    blocTest<DeliveryNavigationBloc, DeliveryNavigationState>(
      'sets emergency mode on SOSClickedEvent and persists it',
      build: () {
        when(
          () => mockRepository.saveEmergencyMode(true),
        ).thenAnswer((_) async {});
        return DeliveryNavigationBloc(
          repository: mockRepository,
          service: mockService,
        );
      },
      seed: () => const DeliveryNavigationState(
        status: DeliveryNavigationStatus.loaded,
        emergencyMode: false,
      ),
      act: (b) => b.add(const DeliveryNavigationSOSClickedEvent()),
      expect: () => const [
        DeliveryNavigationState(
          status: DeliveryNavigationStatus.loaded,
          emergencyMode: true,
        ),
      ],
      verify: (_) {
        verify(() => mockRepository.saveEmergencyMode(true)).called(1);
      },
    );

    blocTest<DeliveryNavigationBloc, DeliveryNavigationState>(
      'reloads route and order details on RefreshEvent',
      build: () {
        stubSuccessfulInit();
        return DeliveryNavigationBloc(
          repository: mockRepository,
          service: mockService,
        );
      },
      seed: () => const DeliveryNavigationState(
        status: DeliveryNavigationStatus.navigating,
        hasLocationPermission: true,
        audioEnabled: true,
        turnDistanceMeters: 120.0,
      ),
      act: (b) => b.add(const DeliveryNavigationRefreshEvent()),
      expect: () => const [
        DeliveryNavigationState(
          status: DeliveryNavigationStatus.loaded,
          hasLocationPermission: true,
          isGpsServiceEnabled: true,
          gpsStatus: DeliveryGpsStatus.active,
          turnDistanceMeters: 120.0,
          order: DeliveryNavigationRepository.defaultOrder,
          pickup: DeliveryNavigationRepository.defaultPickup,
          drop: DeliveryNavigationRepository.defaultDrop,
        ),
      ],
    );

    blocTest<DeliveryNavigationBloc, DeliveryNavigationState>(
      'switches locale and persists it on LocaleChangedEvent',
      build: () {
        when(
          () => mockRepository.saveLocaleCode('ta'),
        ).thenAnswer((_) async {});
        return DeliveryNavigationBloc(
          repository: mockRepository,
          service: mockService,
        );
      },
      seed: () => const DeliveryNavigationState(
        status: DeliveryNavigationStatus.loaded,
        localeCode: 'en',
      ),
      act: (b) => b.add(const DeliveryNavigationLocaleChangedEvent('ta')),
      expect: () => const [
        DeliveryNavigationState(
          status: DeliveryNavigationStatus.loaded,
          localeCode: 'ta',
        ),
      ],
      verify: (_) {
        verify(() => mockRepository.saveLocaleCode('ta')).called(1);
      },
    );

    blocTest<DeliveryNavigationBloc, DeliveryNavigationState>(
      'reduces turn distance from live location stream during navigation',
      build: () {
        when(
          () => mockRepository.saveAudioEnabled(true),
        ).thenAnswer((_) async {});
        when(() => mockService.updateDriverLocation(
          latitude: any(named: 'latitude'),
          longitude: any(named: 'longitude'),
        )).thenAnswer((_) async {});
        return DeliveryNavigationBloc(
          repository: mockRepository,
          service: mockService,
        );
      },
      seed: () => const DeliveryNavigationState(
        status: DeliveryNavigationStatus.loaded,
        hasLocationPermission: true,
        isGpsServiceEnabled: true,
        gpsStatus: DeliveryGpsStatus.searching,
        turnDistanceMeters: 250.0,
      ),
      act: (b) async {
        b.add(const DeliveryNavigationStartNavigationEvent());
        await Future<void>.delayed(Duration.zero);
        b.add(const DeliveryNavigationLocationTickEvent(40.0));
        await Future<void>.delayed(Duration.zero);
        b.add(const DeliveryNavigationLocationTickEvent(35.0));
        await Future<void>.delayed(Duration.zero);
        b.add(const DeliveryNavigationExitNavigationEvent());
        await Future<void>.delayed(Duration.zero);
      },
      expect: () => const [
        DeliveryNavigationState(
          status: DeliveryNavigationStatus.navigating,
          hasLocationPermission: true,
          isGpsServiceEnabled: true,
          gpsStatus: DeliveryGpsStatus.searching,
          audioEnabled: true,
          turnDistanceMeters: 250.0,
        ),
        DeliveryNavigationState(
          status: DeliveryNavigationStatus.navigating,
          hasLocationPermission: true,
          isGpsServiceEnabled: true,
          gpsStatus: DeliveryGpsStatus.searching,
          audioEnabled: true,
          turnDistanceMeters: 210.0,
        ),
        DeliveryNavigationState(
          status: DeliveryNavigationStatus.navigating,
          hasLocationPermission: true,
          isGpsServiceEnabled: true,
          gpsStatus: DeliveryGpsStatus.searching,
          audioEnabled: true,
          turnDistanceMeters: 175.0,
        ),
        DeliveryNavigationState(
          status: DeliveryNavigationStatus.loaded,
          hasLocationPermission: true,
          isGpsServiceEnabled: true,
          gpsStatus: DeliveryGpsStatus.searching,
          audioEnabled: true,
          turnDistanceMeters: 175.0,
        ),
      ],
    );

    blocTest<DeliveryNavigationBloc, DeliveryNavigationState>(
      'toggles showMap on ToggleMapEvent',
      build: () {
        return DeliveryNavigationBloc(
          repository: mockRepository,
          service: mockService,
        );
      },
      seed: () => const DeliveryNavigationState(
        status: DeliveryNavigationStatus.loaded,
        showMap: true,
      ),
      act: (b) => b.add(const DeliveryNavigationToggleMapEvent()),
      expect: () => const [
        DeliveryNavigationState(
          status: DeliveryNavigationStatus.loaded,
          showMap: false,
        ),
      ],
    );

    blocTest<DeliveryNavigationBloc, DeliveryNavigationState>(
      'collect COD cash marks order collected and stores change',
      build: () {
        when(
          () => mockRepository.collectCodCash(
            orderId: 'ORD-1234',
            amountReceived: 1000.0,
          ),
        ).thenAnswer(
          (_) async => {
            'success': true,
            'changeAmount': 500.0,
            'collectedAmount': 500.0,
            'message': 'COD collected',
          },
        );
        return DeliveryNavigationBloc(
          repository: mockRepository,
          service: mockService,
        );
      },
      seed: () => const DeliveryNavigationState(
        status: DeliveryNavigationStatus.loaded,
        paymentMethod: 'COD',
        codAmount: 500.0,
        isCodCollected: false,
        activeOrderId: 'ORD-1234',
      ),
      act: (b) => b.add(
        const DeliveryNavigationCollectCodCashEvent(
          orderId: 'ORD-1234',
          amountReceived: 1000.0,
        ),
      ),
      expect: () => [
        isA<DeliveryNavigationState>()
            .having((s) => s.codCollectStatus, 'collecting',
                CodCollectStatus.collecting),
        isA<DeliveryNavigationState>()
            .having((s) => s.codCollectStatus, 'success',
                CodCollectStatus.success)
            .having((s) => s.isCodCollected, 'collected', true)
            .having((s) => s.collectedAmount, 'collectedAmount', 500.0)
            .having((s) => s.codChangeAmount, 'change', 500.0),
      ],
      verify: (_) {
        verify(
          () => mockRepository.collectCodCash(
            orderId: 'ORD-1234',
            amountReceived: 1000.0,
          ),
        ).called(1);
      },
    );

    blocTest<DeliveryNavigationBloc, DeliveryNavigationState>(
      'collect COD cash reports failure when insufficient amount received',
      build: () {
        when(
          () => mockRepository.collectCodCash(
            orderId: 'ORD-1234',
            amountReceived: 100.0,
          ),
        ).thenAnswer(
          (_) async => {
            'success': false,
            'changeAmount': 0.0,
            'message': 'Received amount is less than the COD amount to collect.',
          },
        );
        return DeliveryNavigationBloc(
          repository: mockRepository,
          service: mockService,
        );
      },
      seed: () => const DeliveryNavigationState(
        status: DeliveryNavigationStatus.loaded,
        paymentMethod: 'COD',
        codAmount: 500.0,
        isCodCollected: false,
        activeOrderId: 'ORD-1234',
      ),
      act: (b) => b.add(
        const DeliveryNavigationCollectCodCashEvent(
          orderId: 'ORD-1234',
          amountReceived: 100.0,
        ),
      ),
      expect: () => [
        isA<DeliveryNavigationState>()
            .having((s) => s.codCollectStatus, 'collecting',
                CodCollectStatus.collecting),
        isA<DeliveryNavigationState>()
            .having((s) => s.codCollectStatus, 'failed',
                CodCollectStatus.failed)
            .having((s) => s.isCodCollected, 'collected', false),
      ],
    );

    test('hasActiveOrder reflects a bound active order', () {
      const idleState = DeliveryNavigationState(
        status: DeliveryNavigationStatus.loaded,
        order: emptyOrder,
      );
      expect(idleState.hasActiveOrder, isFalse);
      expect(idleState.isIdle, isTrue);

      const activeState = DeliveryNavigationState(
        status: DeliveryNavigationStatus.loaded,
        activeOrderId: 'ORD-784512',
      );
      expect(activeState.hasActiveOrder, isTrue);
      expect(activeState.isIdle, isFalse);
    });

    blocTest<DeliveryNavigationBloc, DeliveryNavigationState>(
      'loads demand zones and enters idle map for empty active order',
      build: () {
        when(() => mockService.checkConnectivity()).thenAnswer((_) async => true);
        when(
          () => mockService.checkLocationPermission(),
        ).thenAnswer((_) async => true);
        when(() => mockService.checkGpsStatus()).thenAnswer((_) async => true);
        when(
          () => mockService.streamLiveLocation(),
        ).thenAnswer((_) => const Stream.empty());
        when(
          () => mockService.fetchDemandZones(),
        ).thenAnswer(
          (_) async => const [
            {'name': 'Anna Salai', 'latitude': 13.0475, 'longitude': 80.2573, 'estimatedDemand': 12},
          ],
        );
        when(
          () => mockRepository.fetchOrderSummary(),
        ).thenAnswer((_) async => emptyOrder);
        when(
          () => mockRepository.fetchPickup(),
        ).thenAnswer((_) async => DeliveryNavigationRepository.defaultPickup);
        when(
          () => mockRepository.fetchDrop(),
        ).thenAnswer((_) async => DeliveryNavigationRepository.defaultDrop);
        when(
          () => mockRepository.fetchPartnerProfile(),
        ).thenAnswer((_) async => null);
        when(
          () => mockRepository.watchActiveOrder(),
        ).thenAnswer((_) => const Stream.empty());
        when(
          () => mockRepository.watchPartnerProfile(),
        ).thenAnswer((_) => const Stream.empty());
        when(() => mockRepository.getAudioEnabled()).thenAnswer((_) async => false);
        when(
          () => mockRepository.getEmergencyMode(),
        ).thenAnswer((_) async => false);
        when(() => mockRepository.getLocaleCode()).thenAnswer((_) async => 'en');
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
          order: emptyOrder,
          pickup: DeliveryNavigationRepository.defaultPickup,
          drop: DeliveryNavigationRepository.defaultDrop,
          demandZones: [
            DeliveryDemandZone(
              name: 'Anna Salai',
              latitude: 13.0475,
              longitude: 80.2573,
              estimatedDemand: 12,
            ),
          ],
        ),
      ],
      verify: (bloc) {
        expect(bloc.state.hasActiveOrder, isFalse);
        expect(bloc.state.isIdle, isTrue);
      },
    );

    blocTest<DeliveryNavigationBloc, DeliveryNavigationState>(
      'toggles online status from the navigation console',
      build: () {
        return DeliveryNavigationBloc(
          repository: mockRepository,
          service: mockService,
        );
      },
      seed: () => const DeliveryNavigationState(
        status: DeliveryNavigationStatus.loaded,
        isOnline: true,
      ),
      act: (b) => b.add(const DeliveryNavigationToggleOnlineStatusEvent()),
      expect: () => const [
        DeliveryNavigationState(
          status: DeliveryNavigationStatus.loaded,
          isOnline: false,
        ),
      ],
    );

    blocTest<DeliveryNavigationBloc, DeliveryNavigationState>(
      'selects a demand zone and recenters the map',
      build: () {
        return DeliveryNavigationBloc(
          repository: mockRepository,
          service: mockService,
        );
      },
      seed: () => const DeliveryNavigationState(
        status: DeliveryNavigationStatus.loaded,
        mapZoomLevel: 15.0,
      ),
      act: (b) => b.add(
        const DeliveryNavigationSelectDemandZoneEvent(
          DeliveryDemandZone(
            name: 'T. Nagar',
            latitude: 13.0418,
            longitude: 80.2341,
            estimatedDemand: 9,
          ),
        ),
      ),
      expect: () => const [
        DeliveryNavigationState(
          status: DeliveryNavigationStatus.loaded,
          mapZoomLevel: 16.0,
          selectedDemandZone: DeliveryDemandZone(
            name: 'T. Nagar',
            latitude: 13.0418,
            longitude: 80.2341,
            estimatedDemand: 9,
          ),
        ),
      ],
    );

    blocTest<DeliveryNavigationBloc, DeliveryNavigationState>(
      'updates nearbySellers when DeliveryNavigationSellersUpdatedEvent is added',
      build: () {
        return DeliveryNavigationBloc(
          repository: mockRepository,
          service: mockService,
        );
      },
      seed: () => const DeliveryNavigationState(
        status: DeliveryNavigationStatus.loaded,
        nearbySellers: [],
      ),
      act: (b) => b.add(
        const DeliveryNavigationSellersUpdatedEvent([
          {
            'id': 'seller_1',
            'name': 'Test Pizza Store',
            'latitude': 13.0418,
            'longitude': 80.2341,
            'phone': '9876543210',
          },
        ]),
      ),
      expect: () => const [
        DeliveryNavigationState(
          status: DeliveryNavigationStatus.loaded,
          nearbySellers: [
            {
              'id': 'seller_1',
              'name': 'Test Pizza Store',
              'latitude': 13.0418,
              'longitude': 80.2341,
              'phone': '9876543210',
            },
          ],
        ),
      ],
    );
  });
}

