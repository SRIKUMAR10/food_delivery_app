import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_NavigationBar_page/Delivery_NavigationBar_page_bloc.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_NavigationBar_page/Delivery_NavigationBar_page_event.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_NavigationBar_page/Delivery_NavigationBar_page_state.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_NavigationBar_page/Delivery_NavigationBar_page_repository.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_NavigationBar_page/Delivery_NavigationBar_page_service.dart';

class MockDeliveryNavigationBarRepository extends Mock
    implements DeliveryNavigationBarRepositoryBase {}

class MockDeliveryNavigationBarService extends Mock
    implements DeliveryNavigationBarServiceBase {}

void main() {
  late MockDeliveryNavigationBarRepository mockRepository;
  late MockDeliveryNavigationBarService mockService;

  const List<DeliveryNavigationBarItem> navItems =
      DeliveryNavigationBarRepository.defaultNavItems;

  setUp(() {
    mockRepository = MockDeliveryNavigationBarRepository();
    mockService = MockDeliveryNavigationBarService();
  });

  DeliveryNavigationBarPageBloc buildBloc() {
    return DeliveryNavigationBarPageBloc(
      repository: mockRepository,
      service: mockService,
    );
  }

  group('DeliveryNavigationBarPage Error Handling Tests', () {
    blocTest<DeliveryNavigationBarPageBloc, DeliveryNavigationBarState>(
      'emits error state when repository fails to load nav menu',
      build: () {
        when(
          () => mockService.checkConnectivity(),
        ).thenAnswer((_) async => true);
        when(
          () => mockRepository.getNavItems(),
        ).thenThrow(Exception('Failed to fetch menu'));
        return buildBloc();
      },
      act: (b) => b.add(const DeliveryNavigationBarInitEvent()),
      expect: () => const [
        DeliveryNavigationBarState(
          status: DeliveryNavigationBarStatus.loading,
          selectedIndex: 4,
        ),
        DeliveryNavigationBarState(
          status: DeliveryNavigationBarStatus.error,
          errorMessage: 'Failed to fetch menu',
        ),
      ],
    );

    blocTest<DeliveryNavigationBarPageBloc, DeliveryNavigationBarState>(
      'recovers from failure on retry refresh',
      build: () {
        when(
          () => mockService.checkConnectivity(),
        ).thenAnswer((_) async => true);
        when(() => mockService.checkPermission()).thenAnswer((_) async => true);
        var calls = 0;
        when(() => mockRepository.getNavItems()).thenAnswer((_) async {
          calls++;
          if (calls == 1) {
            throw Exception('Network failure');
          }
          return navItems;
        });
        return buildBloc();
      },
      act: (b) {
        b.add(const DeliveryNavigationBarInitEvent());
        b.add(const DeliveryNavigationBarRefreshEvent());
      },
      expect: () => const [
        DeliveryNavigationBarState(
          status: DeliveryNavigationBarStatus.loading,
          selectedIndex: 4,
        ),
        DeliveryNavigationBarState(
          status: DeliveryNavigationBarStatus.error,
          errorMessage: 'Network failure',
        ),
        DeliveryNavigationBarState(
          status: DeliveryNavigationBarStatus.loaded,
          selectedIndex: 4,
          navItems: navItems,
          hasPermission: true,
        ),
      ],
    );

    blocTest<DeliveryNavigationBarPageBloc, DeliveryNavigationBarState>(
      'emits empty state when navigation menu is empty',
      build: () {
        when(
          () => mockService.checkConnectivity(),
        ).thenAnswer((_) async => true);
        when(() => mockRepository.getNavItems()).thenAnswer((_) async => []);
        when(
          () => mockRepository.getSavedSelectedIndex(),
        ).thenAnswer((_) async => -1);
        when(
          () => mockRepository.getLocaleCode(),
        ).thenAnswer((_) async => 'en');
        when(
          () => mockRepository.getPartnerName(),
        ).thenAnswer((_) async => 'Ravi Kumar');
        when(() => mockService.checkPermission()).thenAnswer((_) async => true);
        return buildBloc();
      },
      act: (b) => b.add(const DeliveryNavigationBarInitEvent()),
      expect: () => const [
        DeliveryNavigationBarState(
          status: DeliveryNavigationBarStatus.loading,
          selectedIndex: 4,
        ),
        DeliveryNavigationBarState(
          status: DeliveryNavigationBarStatus.empty,
          selectedIndex: 4,
        ),
      ],
    );

    blocTest<DeliveryNavigationBarPageBloc, DeliveryNavigationBarState>(
      'degrades gracefully to offline loaded state without connectivity',
      build: () {
        when(
          () => mockService.checkConnectivity(),
        ).thenAnswer((_) async => false);
        when(
          () => mockRepository.getNavItems(),
        ).thenAnswer((_) async => navItems);
        when(
          () => mockRepository.getSavedSelectedIndex(),
        ).thenAnswer((_) async => -1);
        when(
          () => mockRepository.getLocaleCode(),
        ).thenAnswer((_) async => 'en');
        when(
          () => mockRepository.getPartnerName(),
        ).thenAnswer((_) async => 'Ravi Kumar');
        when(() => mockService.checkPermission()).thenAnswer((_) async => true);
        return buildBloc();
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
          localeCode: 'en',
          partnerName: 'Ravi Kumar',
          hasPermission: true,
          isOffline: true,
        ),
      ],
    );

    blocTest<DeliveryNavigationBarPageBloc, DeliveryNavigationBarState>(
      'emits error state when upload stream fails',
      build: () {
        when(() => mockService.simulateChunkedUpload()).thenAnswer(
          (_) => Stream<double>.error(Exception('Upload interrupted')),
        );
        return buildBloc();
      },
      seed: () => const DeliveryNavigationBarState(
        status: DeliveryNavigationBarStatus.loaded,
        navItems: navItems,
      ),
      act: (b) => b.add(const DeliveryNavigationBarSimulateUploadEvent()),
      expect: () => const [
        DeliveryNavigationBarState(
          status: DeliveryNavigationBarStatus.error,
          selectedIndex: 4,
          navItems: navItems,
          errorMessage: 'Upload failed: Upload interrupted',
        ),
      ],
    );
  });
}
