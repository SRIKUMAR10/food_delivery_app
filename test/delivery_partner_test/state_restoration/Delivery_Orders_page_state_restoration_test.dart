import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/services.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_NavigationBar_page/Delivery_NavigationBar_page_ui.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_NavigationBar_page/Delivery_NavigationBar_page_state.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_NavigationBar_page/Delivery_NavigationBar_page_repository.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_NavigationBar_page/Delivery_NavigationBar_page_service.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Orders_page/Delivery_Orders_page_repository.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Orders_page/Delivery_Orders_page_state.dart';

import '../../font_loader_helper.dart';
import '../helpers/demo_orders.dart';

class MockDeliveryNavigationBarRepository extends Mock
    implements DeliveryNavigationBarRepositoryBase {}

class MockDeliveryNavigationBarService extends Mock
    implements DeliveryNavigationBarServiceBase {}

class MockDeliveryOrdersRepository extends Mock
    implements DeliveryOrdersRepositoryBase {}

void main() {
  late MockDeliveryNavigationBarRepository mockRepository;
  late MockDeliveryNavigationBarService mockService;
  late MockDeliveryOrdersRepository mockOrdersRepository;

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
    mockOrdersRepository = MockDeliveryOrdersRepository();
    registerFallbackValue(DeliveryOrderStatus.pending);

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
    when(
      () => mockOrdersRepository.watchOrders(),
    ).thenAnswer((_) => Stream.value(demoOrders()));
    when(
      () => mockOrdersRepository.fetchOrders(),
    ).thenAnswer((_) async => demoOrders());
    when(
      () => mockOrdersRepository.updateOrderStatus(any(), any()),
    ).thenAnswer((invocation) async {
      final orderId = invocation.positionalArguments[0] as String;
      final status = invocation.positionalArguments[1] as DeliveryOrderStatus;
      return demoOrders().firstWhere((o) => o.orderId == orderId).copyWith(
            status: status,
          );
    });

    SharedPreferences.setMockInitialValues({});
  });

  void setDesktopSize(WidgetTester tester) {
    tester.view.physicalSize = const Size(1280, 1600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
  }

  Future<void> pumpNavBar(WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: DeliveryNavigationBarPage(
          repository: mockRepository,
          service: mockService,
          ordersRepository: mockOrdersRepository,
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
  }

  Future<void> openOrders(WidgetTester tester) async {
    await tester.tap(find.text('Orders'), warnIfMissed: false);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.byKey(const Key('dp_orders_page')), findsOneWidget);
  }

  Future<void> switchToProfile(WidgetTester tester) async {
    await tester.tap(find.text('Earnings'), warnIfMissed: false);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
  }

  group('DeliveryOrdersPage State Restoration Tests', () {
    testWidgets(
      'preserves the search query when switching tabs away and back',
      (tester) async {
        setDesktopSize(tester);
        await pumpNavBar(tester);
        await openOrders(tester);

        await tester.enterText(
          find.byKey(const Key('dp_orders_search_field')),
          'Green Bowl',
        );
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 50));

        expect(
          find.byKey(const Key('dp_orders_card_ORD12345')),
          findsOneWidget,
        );
        expect(find.byKey(const Key('dp_orders_card_ORD12346')), findsNothing);

        await switchToProfile(tester);

        await openOrders(tester);

        final editable = tester.widget<EditableText>(
          find.descendant(
            of: find.byKey(const Key('dp_orders_search_field')),
            matching: find.byType(EditableText),
          ),
        );
        expect(editable.controller.text, 'Green Bowl');
        expect(
          find.byKey(const Key('dp_orders_card_ORD12345')),
          findsOneWidget,
        );
        expect(find.byKey(const Key('dp_orders_card_ORD12346')), findsNothing);
      },
    );

    testWidgets('preserves the active tab selection across tab switches', (
      tester,
    ) async {
      setDesktopSize(tester);
      await pumpNavBar(tester);
      await openOrders(tester);

      await tester.tap(find.byKey(const Key('dp_orders_tab_active')));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));

      expect(find.byKey(const Key('dp_orders_card_ORD12346')), findsOneWidget);
      expect(find.byKey(const Key('dp_orders_card_ORD12345')), findsNothing);

      await switchToProfile(tester);

      await openOrders(tester);

      expect(find.byKey(const Key('dp_orders_card_ORD12346')), findsOneWidget);
      expect(find.byKey(const Key('dp_orders_card_ORD12345')), findsNothing);
    });

    testWidgets('preserves updated order status across tab switches', (
      tester,
    ) async {
      setDesktopSize(tester);
      await pumpNavBar(tester);
      await openOrders(tester);

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

      await switchToProfile(tester);

      await openOrders(tester);

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
    });
  });
}
