import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Orders_page/Delivery_Orders_page_bloc.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Orders_page/Delivery_Orders_page_event.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Orders_page/Delivery_Orders_page_state.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Orders_page/Delivery_Orders_page_service.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Orders_page/Delivery_Orders_page_ui.dart';

class MockDeliveryOrdersPageBloc
    extends MockBloc<DeliveryOrdersPageEvent, DeliveryOrdersPageState>
    implements DeliveryOrdersPageBloc {}

const pendingOrder = DeliveryOrderCardModel(
  orderId: 'ORD12345',
  customerName: 'Priya Sharma',
  restaurantName: 'Green Bowl Kitchen',
  pickupAddress: '42 Anna Salai, Chennai',
  deliveryAddress: '21 MG Road, Velachery',
  amount: 486.50,
  itemsCount: 3,
  status: DeliveryOrderStatus.pending,
  distance: 2.4,
  time: '10:30 AM',
  paymentType: 'Cash',
);

const loadedState = DeliveryOrdersPageState(
  status: DeliveryOrdersPageStatus.loaded,
  orders: [pendingOrder],
  filteredOrders: [pendingOrder],
);

void main() {
  late MockDeliveryOrdersPageBloc mockBloc;

  setUpAll(() {
    registerFallbackValue(
      const DeliveryOrdersUpdateStatusEvent(
        orderId: 'ORD12345',
        status: DeliveryOrderStatus.active,
      ),
    );
  });

  setUp(() {
    mockBloc = MockDeliveryOrdersPageBloc();
    when(() => mockBloc.state).thenReturn(loadedState);
  });

  void setDesktopSize(WidgetTester tester) {
    tester.view.physicalSize = const Size(1280, 1600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
  }

  Widget buildPage() {
    return MaterialApp(
      onGenerateRoute: (settings) {
        if (settings.name == '/deliveryNavigationScreen') {
          return MaterialPageRoute<void>(
            builder: (_) => const Scaffold(
              body: Center(
                child: Text(
                  'Opening directions to 21 MG Road, Velachery',
                ),
              ),
            ),
          );
        }
        return null;
      },
      home: Scaffold(body: DeliveryOrdersPage(bloc: mockBloc)),
    );
  }

  group('DeliveryOrdersPage Permission Tests', () {
    test('notification permission service returns granted', () async {
      final service = DeliveryOrdersService();
      expect(await service.requestNotificationPermission(), isTrue);
    });

    test('location permission service returns granted', () async {
      final service = DeliveryOrdersService();
      expect(await service.requestLocationPermission(), isTrue);
    });

    test('permission service does not expose raw environment secrets', () {
      final service = DeliveryOrdersService();
      final env = service.getEnvironmentVariables();
      for (final value in env.values) {
        expect(
          value.contains(
            RegExp(r'(token|password|passwd|secret)', caseSensitive: false),
          ),
          isFalse,
        );
      }
    });

    testWidgets('renders the orders list when running', (tester) async {
      setDesktopSize(tester);
      await tester.pumpWidget(buildPage());
      await tester.pump();

      expect(find.byKey(const Key('dp_orders_page')), findsOneWidget);
      expect(find.byKey(const Key('dp_orders_card_ORD12345')), findsOneWidget);
      expect(
        find.byKey(const Key('dp_orders_search_field')),
        findsAtLeastNWidgets(1),
      );
    });

    testWidgets('update status action is reachable and tappable', (
      tester,
    ) async {
      setDesktopSize(tester);
      await tester.pumpWidget(buildPage());
      await tester.pump();

      final updateButton = find.byKey(const Key('dp_orders_update_ORD12345'));
      expect(updateButton, findsOneWidget);
      await tester.tap(updateButton);
      await tester.pump();

      verify(
        () => mockBloc.add(
          const DeliveryOrdersUpdateStatusEvent(
            orderId: 'ORD12345',
            status: DeliveryOrderStatus.active,
          ),
        ),
      ).called(1);
    });

    testWidgets('navigate action is reachable and tappable', (tester) async {
      setDesktopSize(tester);
      await tester.pumpWidget(buildPage());
      await tester.pump();

      final navigateButton = find.byKey(
        const Key('dp_orders_navigate_ORD12345'),
      );
      expect(navigateButton, findsOneWidget);
      await tester.tap(navigateButton);
      await tester.pump();

      expect(
        find.textContaining('Opening directions to 21 MG Road, Velachery'),
        findsOneWidget,
      );
    });
  });
}
