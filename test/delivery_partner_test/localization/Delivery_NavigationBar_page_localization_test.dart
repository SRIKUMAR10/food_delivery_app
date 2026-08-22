import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_NavigationBar_page/Delivery_NavigationBar_page_bloc.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_NavigationBar_page/Delivery_NavigationBar_page_event.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_NavigationBar_page/Delivery_NavigationBar_page_state.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_NavigationBar_page/Delivery_NavigationBar_page_repository.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_NavigationBar_page/Delivery_NavigationBar_page_service.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_NavigationBar_page/Delivery_NavigationBar_page_ui.dart';
import 'package:food_delivery_app/repositories/delivery_partner_repository.dart';

class MockDeliveryNavigationBarRepository extends Mock
    implements DeliveryNavigationBarRepositoryBase {}

class MockDeliveryNavigationBarService extends Mock
    implements DeliveryNavigationBarServiceBase {}

class MockDeliveryPartnerRepository extends Mock
    implements DeliveryPartnerRepository {}

void main() {
  late MockDeliveryNavigationBarRepository mockRepository;
  late MockDeliveryNavigationBarService mockService;

  setUp(() {
    mockRepository = MockDeliveryNavigationBarRepository();
    mockService = MockDeliveryNavigationBarService();
  });

  group('DeliveryNavigationBarPage Localization Tests', () {
    blocTest<DeliveryNavigationBarPageBloc, DeliveryNavigationBarState>(
      'saves and updates locale code to Tamil (ta) on LocaleChangedEvent',
      build: () {
        when(
          () => mockRepository.saveLocaleCode('ta'),
        ).thenAnswer((_) async {});
        return DeliveryNavigationBarPageBloc(
          repository: mockRepository,
          service: mockService,
        );
      },
      act: (b) => b.add(const DeliveryNavigationBarLocaleChangedEvent('ta')),
      expect: () => const [DeliveryNavigationBarState(localeCode: 'ta')],
      verify: (_) {
        verify(() => mockRepository.saveLocaleCode('ta')).called(1);
      },
    );

    blocTest<DeliveryNavigationBarPageBloc, DeliveryNavigationBarState>(
      'restores saved locale on InitEvent',
      build: () {
        when(
          () => mockService.checkConnectivity(),
        ).thenAnswer((_) async => true);
        when(() => mockRepository.getNavItems()).thenAnswer(
          (_) async => DeliveryNavigationBarRepository.defaultNavItems,
        );
        when(
          () => mockRepository.getSavedSelectedIndex(),
        ).thenAnswer((_) async => -1);
        when(
          () => mockRepository.getLocaleCode(),
        ).thenAnswer((_) async => 'ta');
        when(
          () => mockRepository.getPartnerName(),
        ).thenAnswer((_) async => 'Ravi Kumar');
        when(() => mockService.checkPermission()).thenAnswer((_) async => true);
        final mockPartnerRepo = MockDeliveryPartnerRepository();
        when(
          () => mockPartnerRepo.getSession(),
        ).thenAnswer((_) async => {'uid': null, 'email': null});
        when(() => mockPartnerRepo.currentUser).thenReturn(null);
        return DeliveryNavigationBarPageBloc(
          repository: mockRepository,
          service: mockService,
          partnerRepo: mockPartnerRepo,
        );
      },
      act: (b) => b.add(const DeliveryNavigationBarInitEvent()),
      expect: () => const [
        DeliveryNavigationBarState(
          status: DeliveryNavigationBarStatus.loading,
          selectedIndex: 4,
        ),
        DeliveryNavigationBarState(
          status: DeliveryNavigationBarStatus.loaded,
          selectedIndex: 4,
          navItems: DeliveryNavigationBarRepository.defaultNavItems,
          localeCode: 'ta',
          partnerName: 'Ravi Kumar',
          hasPermission: true,
        ),
      ],
    );

    test('translates UI strings for English and Tamil locales', () {
      expect(
        DeliveryNavigationBarStrings.of('brand', 'en'),
        'DELIVERY PARTNER',
      );
      expect(DeliveryNavigationBarStrings.of('needHelp', 'en'), 'Need Help?');
      expect(
        DeliveryNavigationBarStrings.of('contactSupport', 'en'),
        'Contact Support',
      );

      expect(
        DeliveryNavigationBarStrings.of('brand', 'ta'),
        'டெலிவரி பார்ட்னர்',
      );
      expect(DeliveryNavigationBarStrings.of('needHelp', 'ta'), 'உதவி தேவையா?');
      expect(
        DeliveryNavigationBarStrings.of('contactSupport', 'ta'),
        'ஆதரவைத் தொடர்பு கொள்ளுங்கள்',
      );
    });

    test('falls back to English for unsupported locale codes', () {
      expect(
        DeliveryNavigationBarStrings.of('contactSupport', 'fr'),
        'Contact Support',
      );
      expect(
        DeliveryNavigationBarStrings.of('brand', 'xx'),
        'DELIVERY PARTNER',
      );
    });
  });
}
