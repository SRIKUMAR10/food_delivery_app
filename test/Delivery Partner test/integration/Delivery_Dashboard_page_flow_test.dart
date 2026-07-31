import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/services.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Dashboard_page/Delivery_Dashboard_page_repository.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Dashboard_page/Delivery_Dashboard_page_service.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Dashboard_page/Delivery_Dashboard_page_ui.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_NavigationBar_page/Delivery_NavigationBar_page_ui.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_NavigationBar_page/Delivery_NavigationBar_page_state.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_NavigationBar_page/Delivery_NavigationBar_page_repository.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_NavigationBar_page/Delivery_NavigationBar_page_service.dart';

import '../../font_loader_helper.dart';

class MockDeliveryNavigationBarRepository extends Mock
    implements DeliveryNavigationBarRepositoryBase {}

class MockDeliveryNavigationBarService extends Mock
    implements DeliveryNavigationBarServiceBase {}

void main() {
  late MockDeliveryNavigationBarRepository mockNavRepository;
  late MockDeliveryNavigationBarService mockNavService;

  const List<DeliveryNavigationBarItem> navItems =
      DeliveryNavigationBarRepository.defaultNavItems;

  setUpAll(() {
    overrideFontAssetLoading();

    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          const MethodChannel('plugins.flutter.io/path_provider'),
          (MethodCall methodCall) async {
            return '.';
          },
        );
  });

  setUp(() async {
    SharedPreferences.setMockInitialValues({});

    mockNavRepository = MockDeliveryNavigationBarRepository();
    mockNavService = MockDeliveryNavigationBarService();

    when(
      () => mockNavService.checkConnectivity(),
    ).thenAnswer((_) async => true);
    when(
      () => mockNavRepository.getNavItems(),
    ).thenAnswer((_) async => navItems);
    when(
      () => mockNavRepository.getSavedSelectedIndex(),
    ).thenAnswer((_) async => 0);
    when(() => mockNavRepository.getLocaleCode()).thenAnswer((_) async => 'en');
    when(
      () => mockNavRepository.getPartnerName(),
    ).thenAnswer((_) async => 'Ravi Kumar');
    when(
      () => mockNavRepository.saveSelectedIndex(any()),
    ).thenAnswer((_) async {});
    when(() => mockNavService.checkPermission()).thenAnswer((_) async => true);
  });

  void setDesktopSize(WidgetTester tester) {
    tester.view.physicalSize = const Size(1280, 1000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
  }

  group('DeliveryDashboardPage Integration Flow Tests', () {
    testWidgets('loads dashboard and toggles online status live', (
      tester,
    ) async {
      setDesktopSize(tester);
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DeliveryDashboardPage(
              repository: DeliveryDashboardRepository(),
              service: DeliveryDashboardService(),
            ),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));

      expect(find.byKey(const Key('dp_dashboard_online_card')), findsOneWidget);
      expect(find.text('ONLINE'), findsOneWidget);
      expect(find.text('₹2450.00'), findsWidgets);

      await tester.tap(find.byKey(const Key('dp_dashboard_toggle_switch')));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));

      expect(find.text('OFFLINE'), findsOneWidget);

      final prefs = await SharedPreferences.getInstance();
      expect(
        DeliveryDashboardRepository(prefs: prefs).getOnlineStatus(),
        completion(isFalse),
      );

      await tester.tap(find.byKey(const Key('dp_dashboard_toggle_switch')));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));

      expect(find.text('ONLINE'), findsOneWidget);
    });

    testWidgets('renders activity timeline and notification panel', (
      tester,
    ) async {
      setDesktopSize(tester);
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DeliveryDashboardPage(
              repository: DeliveryDashboardRepository(),
              service: DeliveryDashboardService(),
            ),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));

      expect(find.text('Recent Activity'), findsOneWidget);
      expect(find.text('Order Delivered'), findsOneWidget);
      expect(find.text('Notifications'), findsOneWidget);
      expect(find.text('Went Online'), findsOneWidget);
    });

    testWidgets('renders dashboard when Dashboard tab is selected in nav bar', (
      tester,
    ) async {
      setDesktopSize(tester);
      await tester.pumpWidget(
        MaterialApp(
          home: DeliveryNavigationBarPage(
            repository: mockNavRepository,
            service: mockNavService,
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));

      await tester.tap(find.text('Dashboard'), warnIfMissed: false);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));

      expect(find.byKey(const Key('dp_dashboard_online_card')), findsOneWidget);
      expect(find.text('ONLINE'), findsOneWidget);
      expect(find.text('Recent Activity'), findsOneWidget);
    });
  });
}
