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

  group('DeliveryNavigationBarPage Permission Tests', () {
    test('service checks initial permission state', () async {
      when(() => mockService.checkPermission()).thenAnswer((_) async => false);

      expect(await mockService.checkPermission(), isFalse);
      verify(() => mockService.checkPermission()).called(1);
    });

    test(
      'service requests notification permission and returns grant',
      () async {
        when(
          () => mockService.requestPermission(),
        ).thenAnswer((_) async => true);

        expect(await mockService.requestPermission(), isTrue);
        verify(() => mockService.requestPermission()).called(1);
      },
    );

    blocTest<DeliveryNavigationBarPageBloc, DeliveryNavigationBarState>(
      'tracks permission grant on PermissionRequestedEvent',
      build: () {
        when(
          () => mockService.requestPermission(),
        ).thenAnswer((_) async => true);
        return buildBloc();
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

    blocTest<DeliveryNavigationBarPageBloc, DeliveryNavigationBarState>(
      'keeps permission denied when request is declined',
      build: () {
        when(
          () => mockService.requestPermission(),
        ).thenAnswer((_) async => false);
        return buildBloc();
      },
      seed: () => const DeliveryNavigationBarState(
        status: DeliveryNavigationBarStatus.loaded,
        navItems: navItems,
        hasPermission: true,
      ),
      act: (b) => b.add(const DeliveryNavigationBarPermissionRequestedEvent()),
      expect: () => const [
        DeliveryNavigationBarState(
          status: DeliveryNavigationBarStatus.loaded,
          navItems: navItems,
          hasPermission: false,
        ),
      ],
    );

    blocTest<DeliveryNavigationBarPageBloc, DeliveryNavigationBarState>(
      'surfaces error message when permission request fails',
      build: () {
        when(
          () => mockService.requestPermission(),
        ).thenThrow(Exception('Permission service unavailable'));
        return buildBloc();
      },
      seed: () => const DeliveryNavigationBarState(
        status: DeliveryNavigationBarStatus.loaded,
        navItems: navItems,
        hasPermission: true,
      ),
      act: (b) => b.add(const DeliveryNavigationBarPermissionRequestedEvent()),
      expect: () => const [
        DeliveryNavigationBarState(
          status: DeliveryNavigationBarStatus.loaded,
          navItems: navItems,
          hasPermission: false,
          errorMessage: 'Permission service unavailable',
        ),
      ],
    );
  });
}
