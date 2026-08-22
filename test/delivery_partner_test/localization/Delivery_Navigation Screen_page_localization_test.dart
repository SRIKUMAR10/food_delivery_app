import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Navigation%20Screen_page/Delivery_Navigation%20Screen_page_bloc.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Navigation%20Screen_page/Delivery_Navigation%20Screen_page_event.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Navigation%20Screen_page/Delivery_Navigation%20Screen_page_state.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Navigation%20Screen_page/Delivery_Navigation%20Screen_page_repository.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Navigation%20Screen_page/Delivery_Navigation%20Screen_page_service.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Navigation%20Screen_page/Delivery_Navigation%20Screen_page_ui.dart';

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
    when(() => mockRepository.fetchActiveOrderData()).thenAnswer((_) async => null);
    when(() => mockRepository.fetchPartnerProfile()).thenAnswer((_) async => null);
    when(() => mockRepository.watchActiveOrder()).thenAnswer((_) => const Stream.empty());
    when(() => mockRepository.watchPartnerProfile()).thenAnswer((_) => const Stream.empty());
  });

  group('DeliveryNavigationScreenPage Localization Tests', () {
    blocTest<DeliveryNavigationBloc, DeliveryNavigationState>(
      'saves and updates locale code to Tamil (ta) on LocaleChangedEvent',
      build: () {
        when(
          () => mockRepository.saveLocaleCode('ta'),
        ).thenAnswer((_) async {});
        return DeliveryNavigationBloc(
          repository: mockRepository,
          service: mockService,
        );
      },
      act: (b) => b.add(const DeliveryNavigationLocaleChangedEvent('ta')),
      expect: () => const [DeliveryNavigationState(localeCode: 'ta')],
      verify: (_) {
        verify(() => mockRepository.saveLocaleCode('ta')).called(1);
      },
    );

    blocTest<DeliveryNavigationBloc, DeliveryNavigationState>(
      'restores saved locale on InitEvent',
      build: () {
        when(
          () => mockService.checkConnectivity(),
        ).thenAnswer((_) async => true);
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
        ).thenAnswer((_) async => 'ta');
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
          localeCode: 'ta',
          order: DeliveryNavigationRepository.defaultOrder,
          pickup: DeliveryNavigationRepository.defaultPickup,
          drop: DeliveryNavigationRepository.defaultDrop,
        ),
      ],
    );

    test('translates UI strings for English and Tamil locales', () {
      expect(
        DeliveryNavigationStrings.of('liveNavigation', 'en'),
        'Live Navigation',
      );
      expect(
        DeliveryNavigationStrings.of('startNavigation', 'en'),
        'Start Navigation',
      );
      expect(
        DeliveryNavigationStrings.of('emergencySos', 'en'),
        'Emergency SOS',
      );

      expect(
        DeliveryNavigationStrings.of('liveNavigation', 'ta'),
        'நேரடி வழிசெலுத்தல்',
      );
      expect(
        DeliveryNavigationStrings.of('startNavigation', 'ta'),
        'வழிசெலுத்தலைத் தொடங்கவும்',
      );
      expect(DeliveryNavigationStrings.of('emergencySos', 'ta'), 'அவசர SOS');
    });

    test('falls back to English for unsupported locale codes', () {
      expect(
        DeliveryNavigationStrings.of('startNavigation', 'fr'),
        'Start Navigation',
      );
      expect(
        DeliveryNavigationStrings.of('liveNavigation', 'xx'),
        'Live Navigation',
      );
    });
  });
}
