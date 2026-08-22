import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_NavigationBar_page/Delivery_NavigationBar_page_bloc.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_NavigationBar_page/Delivery_NavigationBar_page_event.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_NavigationBar_page/Delivery_NavigationBar_page_state.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_NavigationBar_page/Delivery_NavigationBar_page_repository.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_NavigationBar_page/Delivery_NavigationBar_page_service.dart';
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

  const List<DeliveryNavigationBarItem> navItems =
      DeliveryNavigationBarRepository.defaultNavItems;

  setUp(() {
    mockRepository = MockDeliveryNavigationBarRepository();
    mockService = MockDeliveryNavigationBarService();
  });

  DeliveryNavigationBarPageBloc buildBloc({
    DeliveryPartnerRepository? partnerRepo,
  }) {
    return DeliveryNavigationBarPageBloc(
      repository: mockRepository,
      service: mockService,
      partnerRepo: partnerRepo,
    );
  }

  group('DeliveryNavigationBarPage State Restoration Tests', () {
    blocTest<DeliveryNavigationBarPageBloc, DeliveryNavigationBarState>(
      'restores previously saved selected index on init',
      build: () {
        when(
          () => mockService.checkConnectivity(),
        ).thenAnswer((_) async => true);
        when(
          () => mockRepository.getNavItems(),
        ).thenAnswer((_) async => navItems);
        when(
          () => mockRepository.getSavedSelectedIndex(),
        ).thenAnswer((_) async => 6);
        when(
          () => mockRepository.getLocaleCode(),
        ).thenAnswer((_) async => 'en');
        when(
          () => mockRepository.getPartnerName(),
        ).thenAnswer((_) async => 'Ravi Kumar');
        when(() => mockService.checkPermission()).thenAnswer((_) async => true);
        final mockPartnerRepo = MockDeliveryPartnerRepository();
        when(
          () => mockPartnerRepo.getSession(),
        ).thenAnswer((_) async => {'uid': null, 'email': null});
        when(() => mockPartnerRepo.currentUser).thenReturn(null);
        return buildBloc(partnerRepo: mockPartnerRepo);
      },
      act: (b) => b.add(const DeliveryNavigationBarInitEvent()),
      expect: () => const [
        DeliveryNavigationBarState(
          status: DeliveryNavigationBarStatus.loading,
          selectedIndex: 4,
        ),
        DeliveryNavigationBarState(
          status: DeliveryNavigationBarStatus.loaded,
          selectedIndex: 6,
          navItems: navItems,
          localeCode: 'en',
          partnerName: 'Ravi Kumar',
          hasPermission: true,
        ),
      ],
    );

    blocTest<DeliveryNavigationBarPageBloc, DeliveryNavigationBarState>(
      'restores persisted locale and partner profile on init',
      build: () {
        when(
          () => mockService.checkConnectivity(),
        ).thenAnswer((_) async => true);
        when(
          () => mockRepository.getNavItems(),
        ).thenAnswer((_) async => navItems);
        when(
          () => mockRepository.getSavedSelectedIndex(),
        ).thenAnswer((_) async => -1);
        when(
          () => mockRepository.getLocaleCode(),
        ).thenAnswer((_) async => 'ta');
        when(
          () => mockRepository.getPartnerName(),
        ).thenAnswer((_) async => 'Arjun Kumar');
        when(() => mockService.checkPermission()).thenAnswer((_) async => true);
        final mockPartnerRepo = MockDeliveryPartnerRepository();
        when(
          () => mockPartnerRepo.getSession(),
        ).thenAnswer((_) async => {'uid': null, 'email': null});
        when(() => mockPartnerRepo.currentUser).thenReturn(null);
        return buildBloc(partnerRepo: mockPartnerRepo);
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
          navItems: navItems,
          localeCode: 'ta',
          partnerName: 'Arjun Kumar',
          hasPermission: true,
        ),
      ],
    );

    blocTest<DeliveryNavigationBarPageBloc, DeliveryNavigationBarState>(
      'keeps selected index stable across refresh cycles',
      build: () {
        when(
          () => mockService.checkConnectivity(),
        ).thenAnswer((_) async => true);
        when(
          () => mockRepository.getNavItems(),
        ).thenAnswer((_) async => navItems);
        when(() => mockService.checkPermission()).thenAnswer((_) async => true);
        when(
          () => mockRepository.saveSelectedIndex(any()),
        ).thenAnswer((_) async {});
        return buildBloc();
      },
      seed: () => const DeliveryNavigationBarState(
        status: DeliveryNavigationBarStatus.loaded,
        selectedIndex: 2,
        navItems: navItems,
      ),
      act: (b) => b.add(const DeliveryNavigationBarRefreshEvent()),
      expect: () => const [
        DeliveryNavigationBarState(
          status: DeliveryNavigationBarStatus.loaded,
          selectedIndex: 2,
          navItems: navItems,
          hasPermission: true,
        ),
      ],
    );
  });
}
