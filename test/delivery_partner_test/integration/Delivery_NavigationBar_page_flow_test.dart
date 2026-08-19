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

  Widget buildPage() {
    return MaterialApp(
      home: DeliveryNavigationBarPage(
        repository: mockRepository,
        service: mockService,
      ),
    );
  }

  Future<void> pumpNavBar(WidgetTester tester) async {
    await tester.pumpWidget(buildPage());
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
  }

  Future<void> switchTab(WidgetTester tester, String label) async {
    await tester.tap(find.text(label), warnIfMissed: false);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
  }

  group('DeliveryNavigationBarPage Integration Flow Tests', () {
    testWidgets('loads menu and defaults to the Profile tab', (tester) async {
      setDesktopSize(tester);
      when(
        () => mockRepository.getSavedSelectedIndex(),
      ).thenAnswer((_) async => 11);

      await pumpNavBar(tester);

      expect(find.text('DELIVERY PARTNER'), findsOneWidget);
      expect(find.text('Ravi Kumar'), findsWidgets);
      expect(find.text('My Profile'), findsOneWidget);
    });

    testWidgets('navigates between tabs with BLoC state integration', (
      tester,
    ) async {
      setDesktopSize(tester);

      await pumpNavBar(tester);

      await switchTab(tester, 'Dashboard');
      await tester.pump(const Duration(seconds: 2));

      expect(
        find.descendant(
          of: find.byKey(const ValueKey('dp_nav_dashboard')),
          matching: find.byKey(const Key('dp_nav_indicator')),
        ),
        findsOneWidget,
      );
      expect(
        find.text('You will not receive any new order requests'),
        findsOneWidget,
      );
      verify(() => mockRepository.saveSelectedIndex(0)).called(1);

      await switchTab(tester, 'Orders');

      expect(find.byKey(const Key('dp_orders_loading')), findsOneWidget);
      verify(() => mockRepository.saveSelectedIndex(1)).called(1);

      await switchTab(tester, 'Bank Details');

      expect(find.text('Bank Details Overview'), findsOneWidget);
      verify(() => mockRepository.saveSelectedIndex(8)).called(1);
    });

    testWidgets(
      'tapping Contact Support opens help feedback and dispatches event',
      (tester) async {
        setDesktopSize(tester);

        await pumpNavBar(tester);

        await tester.tap(find.text('Contact Support'), warnIfMissed: false);
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 300));

        expect(find.text('Contacting support...'), findsOneWidget);

        await tester.pump(const Duration(seconds: 5));
      },
    );
  });
}