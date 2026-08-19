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

      await tester.tap(
        find.byKey(const ValueKey('dp_nav_incentives')),
        warnIfMissed: false,
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));
      expect(find.text('Incentives Overview'), findsOneWidget);

      await tester.scrollUntilVisible(
        find.byKey(const ValueKey('dp_nav_help')),
        100,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pump();
      await tester.tap(
        find.byKey(const ValueKey('dp_nav_help')),
        warnIfMissed: false,
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));
      expect(
        find.byKey(const Key('dp_help_skeleton')),
        findsOneWidget,
      );

      await tester.tap(find.text('Contact Support'), warnIfMissed: false);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.text('Contacting support...'), findsOneWidget);

      await tester.drag(
        find.byType(Scrollable).first,
        const Offset(0, 400),
      );
      await tester.pump();
      await tester.tap(
        find.byKey(const ValueKey('dp_nav_dashboard')),
        warnIfMissed: false,
      );
      await tester.pump();
      await tester.pump(const Duration(seconds: 2));
      expect(find.byKey(const Key('dp_dashboard_page')), findsOneWidget);
      expect(
        find.text('You will not receive any new order requests'),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: find.byKey(const ValueKey('dp_nav_dashboard')),
          matching: find.byKey(const Key('dp_nav_indicator')),
        ),
        findsOneWidget,
      );

      await tester.pump(const Duration(seconds: 5));
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
