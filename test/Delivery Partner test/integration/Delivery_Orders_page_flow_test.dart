import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/services.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Orders_page/Delivery_Orders_page_repository.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Orders_page/Delivery_Orders_page_service.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Orders_page/Delivery_Orders_page_ui.dart';
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
    ).thenAnswer((_) async => -1);
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
    tester.view.physicalSize = const Size(1280, 1600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
  }

  Future<void> pumpOrdersPage(WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: DeliveryOrdersPage(
            repository: DeliveryOrdersRepository(),
            service: DeliveryOrdersService(),
          ),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
  }

  group('DeliveryOrdersPage Integration Flow Tests', () {
    testWidgets('loads orders and renders them in the list', (tester) async {
      setDesktopSize(tester);
      await pumpOrdersPage(tester);

      expect(find.byKey(const Key('dp_orders_page')), findsOneWidget);
      expect(find.byKey(const Key('dp_orders_card_ORD12345')), findsOneWidget);
      expect(find.byKey(const Key('dp_orders_card_ORD12346')), findsOneWidget);
      expect(find.text('Green Bowl Kitchen'), findsOneWidget);
      expect(find.text('Spice Route'), findsNWidgets(2));
    });

    testWidgets('filters the order list by the active tab', (tester) async {
      setDesktopSize(tester);
      await pumpOrdersPage(tester);

      expect(find.byKey(const Key('dp_orders_card_ORD12345')), findsOneWidget);

      await tester.tap(find.byKey(const Key('dp_orders_tab_active')));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));

      expect(find.byKey(const Key('dp_orders_card_ORD12346')), findsOneWidget);
      expect(find.byKey(const Key('dp_orders_card_ORD12347')), findsOneWidget);
      expect(find.byKey(const Key('dp_orders_card_ORD12345')), findsNothing);

      await tester.tap(find.byKey(const Key('dp_orders_tab_pending')));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));

      expect(find.byKey(const Key('dp_orders_card_ORD12345')), findsOneWidget);
      expect(find.byKey(const Key('dp_orders_card_ORD12346')), findsNothing);
    });

    testWidgets('filters orders by search query', (tester) async {
      setDesktopSize(tester);
      await pumpOrdersPage(tester);

      await tester.enterText(
        find.byKey(const Key('dp_orders_search_field')),
        'Green Bowl',
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));

      expect(find.byKey(const Key('dp_orders_card_ORD12345')), findsOneWidget);
      expect(find.byKey(const Key('dp_orders_card_ORD12346')), findsNothing);

      await tester.enterText(
        find.byKey(const Key('dp_orders_search_field')),
        'ORD12352',
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));

      expect(find.byKey(const Key('dp_orders_card_ORD12352')), findsOneWidget);
      expect(find.byKey(const Key('dp_orders_card_ORD12345')), findsNothing);
    });

    testWidgets('updates an order status through the card action', (
      tester,
    ) async {
      setDesktopSize(tester);
      await pumpOrdersPage(tester);

      expect(
        find.descendant(
          of: find.byKey(const Key('dp_orders_card_ORD12345')),
          matching: find.text('Pending'),
        ),
        findsOneWidget,
      );

      await tester.tap(find.byKey(const Key('dp_orders_update_ORD12345')));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));

      expect(
        find.descendant(
          of: find.byKey(const Key('dp_orders_card_ORD12345')),
          matching: find.text('In Progress'),
        ),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: find.byKey(const Key('dp_orders_card_ORD12345')),
          matching: find.text('Pending'),
        ),
        findsNothing,
      );
      expect(
        find.descendant(
          of: find.byKey(const Key('dp_orders_card_ORD12345')),
          matching: find.text('Complete Delivery'),
        ),
        findsOneWidget,
      );
    });

    testWidgets('shows the no-results fallback for a non-matching search', (
      tester,
    ) async {
      setDesktopSize(tester);
      await pumpOrdersPage(tester);

      await tester.enterText(
        find.byKey(const Key('dp_orders_search_field')),
        'nonexistent-order',
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));

      expect(find.byKey(const Key('dp_orders_no_results')), findsOneWidget);
      expect(find.text('No orders found'), findsOneWidget);
    });

    testWidgets('renders the orders page when the Orders tab is selected', (
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

      await tester.tap(find.text('Orders'), warnIfMissed: false);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));

      expect(find.byKey(const Key('dp_orders_page')), findsOneWidget);
      expect(find.byKey(const Key('dp_orders_search_field')), findsOneWidget);
      expect(find.byKey(const Key('dp_orders_card_ORD12345')), findsOneWidget);
      expect(find.text('Orders Overview'), findsOneWidget);
    });
  });
}
