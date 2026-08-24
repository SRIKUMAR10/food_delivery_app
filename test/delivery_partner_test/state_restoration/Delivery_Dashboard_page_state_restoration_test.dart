import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/services.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_NavigationBar_page/Delivery_NavigationBar_page_ui.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_NavigationBar_page/Delivery_NavigationBar_page_state.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_NavigationBar_page/Delivery_NavigationBar_page_repository.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_NavigationBar_page/Delivery_NavigationBar_page_service.dart';

import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Orders_page/Delivery_Orders_page_ui.dart';

import '../../font_loader_helper.dart';
import '../helpers/delivery_test_utils.dart';

class MockDeliveryNavigationBarRepository extends Mock
    implements DeliveryNavigationBarRepositoryBase {}

class MockDeliveryNavigationBarService extends Mock
    implements DeliveryNavigationBarServiceBase {}

void main() {
  late MockDeliveryNavigationBarRepository mockRepository;
  late MockDeliveryNavigationBarService mockService;

  const List<DeliveryNavigationBarItem> navItems =
      DeliveryNavigationBarRepository.defaultNavItems;

  setUpAll(() {
    overrideFontAssetLoading();
    setupDeliveryTestChannels();

    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          const MethodChannel('plugins.flutter.io/path_provider'),
          (MethodCall methodCall) async {
            return '.';
          },
        );
  });

  setUp(() {
    mockRepository = MockDeliveryNavigationBarRepository();
    mockService = MockDeliveryNavigationBarService();

    when(() => mockService.checkConnectivity()).thenAnswer((_) async => true);
    when(() => mockRepository.getNavItems()).thenAnswer((_) async => navItems);
    when(
      () => mockRepository.getSavedSelectedIndex(),
    ).thenAnswer((_) async => 0);
    when(() => mockRepository.getLocaleCode()).thenAnswer((_) async => 'en');
    when(
      () => mockRepository.getPartnerName(),
    ).thenAnswer((_) async => 'Ravi Kumar');
    when(
      () => mockRepository.saveSelectedIndex(any()),
    ).thenAnswer((_) async {});
    when(() => mockService.checkPermission()).thenAnswer((_) async => true);

    SharedPreferences.setMockInitialValues({});
  });

  void setDesktopSize(WidgetTester tester) {
    tester.view.physicalSize = const Size(1280, 1000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
  }

  Future<void> pumpNavBar(WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: DeliveryNavigationBarPage(
          repository: mockRepository,
          service: mockService,
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
  }

  Future<void> openDashboard(WidgetTester tester) async {
    await tester.tap(find.text('Dashboard'), warnIfMissed: false);
    await tester.pump();
    await tester.pump(const Duration(seconds: 2));
    expect(find.byKey(const Key('dp_dashboard_page')), findsOneWidget);
  }

  Future<void> switchTab(WidgetTester tester, String label) async {
    await tester.tap(find.text(label), warnIfMissed: false);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
  }

  group('DeliveryDashboardPage State Restoration Tests', () {
    testWidgets('preserves online status when switching tabs away and back', (
      tester,
    ) async {
      setDesktopSize(tester);
      await pumpNavBar(tester);

      await openDashboard(tester);
      expect(find.text('OFFLINE'), findsOneWidget);

      await tester.tap(find.byType(Switch));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));
      expect(find.text('AVAILABLE'), findsOneWidget);

      await switchTab(tester, 'Orders');
      expect(find.byType(DeliveryOrdersPage), findsOneWidget);

      await switchTab(tester, 'Dashboard');

      expect(find.byKey(const Key('dp_dashboard_page')), findsOneWidget);
      expect(find.text('AVAILABLE'), findsOneWidget);
    });

    testWidgets('preserves metric values when returning to dashboard tab', (
      tester,
    ) async {
      setDesktopSize(tester);
      await pumpNavBar(tester);

      await openDashboard(tester);
      expect(find.text('₹0.00'), findsWidgets);

      await switchTab(tester, 'Orders');
      expect(find.byType(DeliveryOrdersPage), findsOneWidget);

      await switchTab(tester, 'Dashboard');

      expect(find.byKey(const Key('dp_dashboard_page')), findsOneWidget);
      expect(find.text('₹0.00'), findsWidgets);
      expect(find.text('0h 0m'), findsOneWidget);
    });

    testWidgets('preserves notification badge state across tab changes', (
      tester,
    ) async {
      setDesktopSize(tester);
      await pumpNavBar(tester);

      await openDashboard(tester);
      expect(
        find.byKey(const Key('dp_dashboard_notification_button')),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('dp_dashboard_notification_badge')),
        findsNothing,
      );

      await switchTab(tester, 'Orders');
      expect(find.byType(DeliveryOrdersPage), findsOneWidget);

      await switchTab(tester, 'Dashboard');

      expect(
        find.byKey(const Key('dp_dashboard_notification_button')),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('dp_dashboard_notification_badge')),
        findsNothing,
      );
    });
  });
}