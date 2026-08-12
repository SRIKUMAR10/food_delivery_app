import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/services.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
  late MockDeliveryNavigationBarRepository mockRepository;
  late MockDeliveryNavigationBarService mockService;

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

  setUp(() {
    mockRepository = MockDeliveryNavigationBarRepository();
    mockService = MockDeliveryNavigationBarService();

    when(() => mockService.checkConnectivity()).thenAnswer((_) async => true);
    when(() => mockRepository.getNavItems()).thenAnswer((_) async => navItems);
    when(
      () => mockRepository.getSavedSelectedIndex(),
    ).thenAnswer((_) async => -1);
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

  group('Delivery NavigationBar End-to-End User Flow Tests', () {
    testWidgets('completes full app shell navigation journey', (tester) async {
      setDesktopSize(tester);

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

      expect(find.text('DELIVERY PARTNER'), findsOneWidget);
      expect(find.text('Need Help?'), findsOneWidget);
      expect(find.text('Contact Support'), findsOneWidget);
      expect(find.text('Ravi Kumar'), findsWidgets);
      expect(find.text('My Profile'), findsOneWidget);

      await tester.tap(find.text('Incentives'), warnIfMissed: false);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));
      expect(find.text('Incentives Overview'), findsOneWidget);

      await tester.tap(find.text('Help & Support'), warnIfMissed: false);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));
      expect(find.text('Emergency Assistance'), findsOneWidget);
      expect(find.text('Create Support Ticket'), findsOneWidget);
      expect(
        find.byKey(const Key('dp_help_emergency_banner')),
        findsOneWidget,
      );

      await tester.tap(find.text('Contact Support'), warnIfMissed: false);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.text('Contacting support...'), findsOneWidget);

      await tester.tap(find.text('Dashboard'), warnIfMissed: false);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));
      expect(find.byKey(const Key('dp_dashboard_online_card')), findsOneWidget);
      expect(
        find.text('You are visible to receive new delivery requests'),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: find.byKey(const ValueKey('dp_nav_dashboard')),
          matching: find.byKey(const Key('dp_nav_indicator')),
        ),
        findsOneWidget,
      );
    });

    testWidgets('shows offline banner when connectivity is lost', (
      tester,
    ) async {
      setDesktopSize(tester);
      when(
        () => mockService.checkConnectivity(),
      ).thenAnswer((_) async => false);

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

      expect(
        find.text('You are offline. Some features may be limited.'),
        findsOneWidget,
      );
      expect(find.text('Offline'), findsWidgets);
    });
  });
}
