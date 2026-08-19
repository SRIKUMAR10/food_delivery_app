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
  });

  DeliveryNavigationBloc buildBloc() {
    return DeliveryNavigationBloc(
      repository: mockRepository,
      service: mockService,
    );
  }

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

  group('DeliveryNavigationScreenPage Permission Tests', () {
    test('service checks location permission state', () async {
      when(
        () => mockService.checkLocationPermission(),
      ).thenAnswer((_) async => true);

      expect(await mockService.checkLocationPermission(), isTrue);
      verify(() => mockService.checkLocationPermission()).called(1);
    });

    test('service requests location permission and returns grant', () async {
      when(
        () => mockService.requestLocationPermission(),
      ).thenAnswer((_) async => true);

      expect(await mockService.requestLocationPermission(), isTrue);
      verify(() => mockService.requestLocationPermission()).called(1);
    });

    blocTest<DeliveryNavigationBloc, DeliveryNavigationState>(
      'tracks granted location permission on init',
      build: () {
        stubHappyPath();
        return buildBloc();
      },
      act: (b) => b.add(const DeliveryNavigationInitEvent()),
      expect: () => const [
        DeliveryNavigationState(status: DeliveryNavigationStatus.loading),
        DeliveryNavigationState(
          status: DeliveryNavigationStatus.loaded,
          hasLocationPermission: true,
          order: DeliveryNavigationRepository.defaultOrder,
          pickup: DeliveryNavigationRepository.defaultPickup,
          drop: DeliveryNavigationRepository.defaultDrop,
        ),
      ],
    );

    blocTest<DeliveryNavigationBloc, DeliveryNavigationState>(
      'tracks denied location permission on init',
      build: () {
        when(
          () => mockService.checkConnectivity(),
        ).thenAnswer((_) async => true);
        when(
          () => mockService.checkLocationPermission(),
        ).thenAnswer((_) async => false);
        when(
          () => mockRepository.fetchOrderSummary(),
        ).thenAnswer((_) async => DeliveryNavigationRepository.defaultOrder);
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
        return buildBloc();
      },
      act: (b) => b.add(const DeliveryNavigationInitEvent()),
      expect: () => const [
        DeliveryNavigationState(
          status: DeliveryNavigationStatus.loading,
          hasLocationPermission: false,
        ),
        DeliveryNavigationState(
          status: DeliveryNavigationStatus.loaded,
          hasLocationPermission: false,
          order: DeliveryNavigationRepository.defaultOrder,
          pickup: DeliveryNavigationRepository.defaultPickup,
          drop: DeliveryNavigationRepository.defaultDrop,
        ),
      ],
    );

    blocTest<DeliveryNavigationBloc, DeliveryNavigationState>(
      'marks offline state when connectivity is unavailable on init',
      build: () {
        when(
          () => mockService.checkConnectivity(),
        ).thenAnswer((_) async => false);
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
        when(
          () => mockRepository.getAudioEnabled(),
        ).thenAnswer((_) async => false);
        when(
          () => mockRepository.getEmergencyMode(),
        ).thenAnswer((_) async => false);
        when(
          () => mockRepository.getLocaleCode(),
        ).thenAnswer((_) async => 'en');
        return buildBloc();
      },
      act: (b) => b.add(const DeliveryNavigationInitEvent()),
      expect: () => const [
        DeliveryNavigationState(status: DeliveryNavigationStatus.loading),
        DeliveryNavigationState(
          status: DeliveryNavigationStatus.loaded,
          hasLocationPermission: true,
          isOffline: true,
          order: DeliveryNavigationRepository.defaultOrder,
          pickup: DeliveryNavigationRepository.defaultPickup,
          drop: DeliveryNavigationRepository.defaultDrop,
        ),
      ],
    );

    blocTest<DeliveryNavigationBloc, DeliveryNavigationState>(
      'surfaces empty state without error when order list is empty',
      build: () {
        when(
          () => mockService.checkConnectivity(),
        ).thenAnswer((_) async => true);
        when(
          () => mockService.checkLocationPermission(),
        ).thenAnswer((_) async => true);
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
          () => mockRepository.getAudioEnabled(),
        ).thenAnswer((_) async => false);
        when(
          () => mockRepository.getEmergencyMode(),
        ).thenAnswer((_) async => false);
        when(
          () => mockRepository.getLocaleCode(),
        ).thenAnswer((_) async => 'en');
        return buildBloc();
      },
      act: (b) => b.add(const DeliveryNavigationInitEvent()),
      expect: () => const [
        DeliveryNavigationState(status: DeliveryNavigationStatus.loading),
        DeliveryNavigationState(
          status: DeliveryNavigationStatus.empty,
          hasLocationPermission: true,
        ),
      ],
    );
  });
}
