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
  late DeliveryNavigationBarPageBloc bloc;

  const List<DeliveryNavigationBarItem> navItems =
      DeliveryNavigationBarRepository.defaultNavItems;

  void stubSuccessfulInit() {
    when(() => mockService.checkConnectivity()).thenAnswer((_) async => true);
    when(() => mockRepository.getNavItems()).thenAnswer((_) async => navItems);
    when(
      () => mockRepository.getSavedSelectedIndex(),
    ).thenAnswer((_) async => -1);
    when(() => mockRepository.getLocaleCode()).thenAnswer((_) async => 'en');
    when(
      () => mockRepository.getPartnerName(),
    ).thenAnswer((_) async => 'Ravi Kumar');
    when(() => mockService.checkPermission()).thenAnswer((_) async => true);
  }

  setUp(() {
    mockRepository = MockDeliveryNavigationBarRepository();
    mockService = MockDeliveryNavigationBarService();
    bloc = DeliveryNavigationBarPageBloc(
      repository: mockRepository,
      service: mockService,
    );
  });

  tearDown(() {
    bloc.close();
  });

  group('DeliveryNavigationBarPageBloc Unit Tests', () {
    test('initial state defaults to loaded profile tab (index 4)', () {
      expect(bloc.state.status, DeliveryNavigationBarStatus.initial);
      expect(bloc.state.selectedIndex, 4);
      expect(bloc.state.navItems, isEmpty);
      expect(bloc.state.localeCode, 'en');
      expect(bloc.state.isOffline, isFalse);
      expect(bloc.state.uploadProgress, 0.0);
    });

    blocTest<DeliveryNavigationBarPageBloc, DeliveryNavigationBarState>(
      'emits loading then loaded state on InitEvent success',
      build: () {
        stubSuccessfulInit();
        return DeliveryNavigationBarPageBloc(
          repository: mockRepository,
          service: mockService,
        );
      },
      act: (b) => b.add(const DeliveryNavigationBarInitEvent()),
      expect: () => [
        const DeliveryNavigationBarState(
          status: DeliveryNavigationBarStatus.loading,
          selectedIndex: 4,
        ),
        const DeliveryNavigationBarState(
          status: DeliveryNavigationBarStatus.loaded,
          selectedIndex: 4,
          navItems: navItems,
          localeCode: 'en',
          partnerName: 'Ravi Kumar',
          hasPermission: true,
          isOffline: false,
        ),
      ],
    );

    blocTest<DeliveryNavigationBarPageBloc, DeliveryNavigationBarState>(
      'switches active tab on TabChangedEvent and persists selection',
      build: () {
        when(
          () => mockRepository.saveSelectedIndex(2),
        ).thenAnswer((_) async {});
        return DeliveryNavigationBarPageBloc(
          repository: mockRepository,
          service: mockService,
        );
      },
      seed: () => const DeliveryNavigationBarState(
        status: DeliveryNavigationBarStatus.loaded,
        selectedIndex: 4,
        navItems: navItems,
      ),
      act: (b) => b.add(const DeliveryNavigationBarTabChangedEvent(2)),
      expect: () => const [
        DeliveryNavigationBarState(
          status: DeliveryNavigationBarStatus.loaded,
          selectedIndex: 2,
          navItems: navItems,
        ),
      ],
      verify: (_) {
        verify(() => mockRepository.saveSelectedIndex(2)).called(1);
      },
    );

    blocTest<DeliveryNavigationBarPageBloc, DeliveryNavigationBarState>(
      'ignores out-of-range tab index',
      build: () {
        return DeliveryNavigationBarPageBloc(
          repository: mockRepository,
          service: mockService,
        );
      },
      seed: () => const DeliveryNavigationBarState(
        status: DeliveryNavigationBarStatus.loaded,
        selectedIndex: 4,
        navItems: navItems,
      ),
      act: (b) => b.add(const DeliveryNavigationBarTabChangedEvent(99)),
      expect: () => const <DeliveryNavigationBarState>[],
      verify: (_) {
        verifyNever(() => mockRepository.saveSelectedIndex(any()));
      },
    );

    blocTest<DeliveryNavigationBarPageBloc, DeliveryNavigationBarState>(
      'reloads menu and updates offline status on RefreshEvent',
      build: () {
        when(
          () => mockService.checkConnectivity(),
        ).thenAnswer((_) async => false);
        when(
          () => mockRepository.getNavItems(),
        ).thenAnswer((_) async => navItems);
        when(() => mockService.checkPermission()).thenAnswer((_) async => true);
        return DeliveryNavigationBarPageBloc(
          repository: mockRepository,
          service: mockService,
        );
      },
      seed: () => const DeliveryNavigationBarState(
        status: DeliveryNavigationBarStatus.loaded,
        selectedIndex: 4,
        navItems: navItems,
      ),
      act: (b) => b.add(const DeliveryNavigationBarRefreshEvent()),
      expect: () => const [
        DeliveryNavigationBarState(
          status: DeliveryNavigationBarStatus.loaded,
          selectedIndex: 4,
          navItems: navItems,
          hasPermission: true,
          isOffline: true,
        ),
      ],
    );

    blocTest<DeliveryNavigationBarPageBloc, DeliveryNavigationBarState>(
      'emits chunked upload progress values on SimulateUploadEvent',
      build: () {
        when(
          () => mockService.simulateChunkedUpload(),
        ).thenAnswer((_) => Stream.fromIterable([0.5, 1.0]));
        return DeliveryNavigationBarPageBloc(
          repository: mockRepository,
          service: mockService,
        );
      },
      seed: () => const DeliveryNavigationBarState(
        status: DeliveryNavigationBarStatus.loaded,
        navItems: navItems,
      ),
      act: (b) => b.add(const DeliveryNavigationBarSimulateUploadEvent()),
      expect: () => const [
        DeliveryNavigationBarState(
          status: DeliveryNavigationBarStatus.loaded,
          navItems: navItems,
          uploadProgress: 0.5,
        ),
        DeliveryNavigationBarState(
          status: DeliveryNavigationBarStatus.loaded,
          navItems: navItems,
          uploadProgress: 1.0,
        ),
      ],
    );

    blocTest<DeliveryNavigationBarPageBloc, DeliveryNavigationBarState>(
      'clears error message when contact support is clicked',
      build: () {
        return DeliveryNavigationBarPageBloc(
          repository: mockRepository,
          service: mockService,
        );
      },
      seed: () => const DeliveryNavigationBarState(
        status: DeliveryNavigationBarStatus.error,
        errorMessage: 'Something went wrong',
      ),
      act: (b) =>
          b.add(const DeliveryNavigationBarContactSupportClickedEvent()),
      expect: () => const [
        DeliveryNavigationBarState(status: DeliveryNavigationBarStatus.error),
      ],
    );

    blocTest<DeliveryNavigationBarPageBloc, DeliveryNavigationBarState>(
      'updates permission flag after PermissionRequestedEvent',
      build: () {
        when(
          () => mockService.requestPermission(),
        ).thenAnswer((_) async => true);
        return DeliveryNavigationBarPageBloc(
          repository: mockRepository,
          service: mockService,
        );
      },
      seed: () => const DeliveryNavigationBarState(
        status: DeliveryNavigationBarStatus.loaded,
        navItems: navItems,
        hasPermission: false,
      ),
      act: (b) => b.add(const DeliveryNavigationBarPermissionRequestedEvent()),
      expect: () => const [
        DeliveryNavigationBarState(
          status: DeliveryNavigationBarStatus.loaded,
          navItems: navItems,
          hasPermission: true,
        ),
      ],
    );
  });
}
