import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Orders_page/Delivery_Orders_page_bloc.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Orders_page/Delivery_Orders_page_event.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Orders_page/Delivery_Orders_page_state.dart';
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

const activeOrder = DeliveryOrderCardModel(
  orderId: 'ORD12346',
  customerName: 'Arun Prakash',
  restaurantName: 'Spice Route',
  pickupAddress: '108 Greams Road, Nungambakkam',
  deliveryAddress: '7 Lake View Road, Adyar',
  amount: 732.00,
  itemsCount: 4,
  status: DeliveryOrderStatus.active,
  distance: 4.1,
  time: '10:42 AM',
  paymentType: 'Card',
);

const completedOrder = DeliveryOrderCardModel(
  orderId: 'ORD12347',
  customerName: 'Meena Krishnan',
  restaurantName: 'The Pasta Lab',
  pickupAddress: '15 Cathedral Road',
  deliveryAddress: '33 Besant Nagar Main Road',
  amount: 1204.75,
  itemsCount: 6,
  status: DeliveryOrderStatus.completed,
  distance: 5.8,
  time: '11:05 AM',
  paymentType: 'Online',
);

const availableOrder = DeliveryOrderCardModel(
  orderId: 'ORD20001',
  customerName: 'Kavya Raman',
  restaurantName: 'Crispy Dosa House',
  pickupAddress: '12 T Nagar, Chennai',
  deliveryAddress: '45 Kodambakkam, Chennai',
  amount: 520.00,
  itemsCount: 3,
  status: DeliveryOrderStatus.pending,
  distance: 6.0,
  time: '10:30 AM',
  paymentType: 'Cash',
  etaMins: 25,
  restaurantLocation: '12 T Nagar, Chennai',
  customerArea: '45 Kodambakkam, Chennai',
  estimatedEarnings: 85.0,
  pickupDistance: 1.8,
  deliveryDistance: 4.2,
  sellerId: 'seller-1',
  customerId: 'buyer-1',
  assignmentStatus: 'available',
  isAvailable: true,
);

const sampleOrders = [pendingOrder, activeOrder, completedOrder];

const availableState = DeliveryOrdersPageState(
  status: DeliveryOrdersPageStatus.loaded,
  orders: [availableOrder],
  filteredOrders: [availableOrder],
);

const loadedState = DeliveryOrdersPageState(
  status: DeliveryOrdersPageStatus.loaded,
  orders: sampleOrders,
  filteredOrders: sampleOrders,
);

const errorState = DeliveryOrdersPageState(
  status: DeliveryOrdersPageStatus.error,
  errorMessage: 'Database offline',
);

const emptyState = DeliveryOrdersPageState(
  status: DeliveryOrdersPageStatus.empty,
);

const noResultsState = DeliveryOrdersPageState(
  status: DeliveryOrdersPageStatus.loaded,
  orders: sampleOrders,
  filteredOrders: <DeliveryOrderCardModel>[],
);

void main() {
  late MockDeliveryOrdersPageBloc mockBloc;

  setUpAll(() {
    registerFallbackValue(const DeliveryOrdersInitEvent());
    registerFallbackValue(
      const DeliveryOrdersTabChangedEvent(DeliveryOrdersTab.all),
    );
    registerFallbackValue(const DeliveryOrdersSearchQueryChangedEvent(''));
    registerFallbackValue(const DeliveryOrdersRefreshEvent());
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
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0B1219),
      ),
      home: Scaffold(body: DeliveryOrdersPage(bloc: mockBloc)),
    );
  }

  group('DeliveryOrdersPage Widget Tests', () {
    testWidgets('renders header, search field and statistics counters', (
      tester,
    ) async {
      setDesktopSize(tester);
      await tester.pumpWidget(buildPage());
      await tester.pump();

      expect(find.byKey(const Key('dp_orders_page')), findsOneWidget);
      expect(find.byKey(const Key('dp_orders_header')), findsOneWidget);
      expect(find.text('Orders Overview'), findsOneWidget);
      expect(find.byKey(const Key('dp_orders_search_field')), findsOneWidget);

      expect(find.byKey(const Key('dp_orders_stat_total')), findsOneWidget);
      expect(find.byKey(const Key('dp_orders_stat_today')), findsOneWidget);
      expect(find.byKey(const Key('dp_orders_stat_active')), findsOneWidget);
      expect(find.byKey(const Key('dp_orders_stat_pending')), findsOneWidget);
      expect(find.byKey(const Key('dp_orders_stat_completed')), findsOneWidget);
      expect(find.byKey(const Key('dp_orders_stat_cancelled')), findsOneWidget);
      expect(
        find.byKey(const Key('dp_orders_stat_acceptance')),
        findsOneWidget,
      );
      expect(find.byKey(const Key('dp_orders_stat_avg_time')), findsOneWidget);
      expect(find.byKey(const Key('dp_orders_stat_rating')), findsOneWidget);
      expect(find.byKey(const Key('dp_orders_stat_earnings')), findsOneWidget);
      expect(find.text('Total'), findsOneWidget);
      expect(
        find.descendant(
          of: find.byKey(const Key('dp_orders_stat_total')),
          matching: find.text('3'),
        ),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: find.byKey(const Key('dp_orders_stat_active')),
          matching: find.text('1'),
        ),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: find.byKey(const Key('dp_orders_stat_pending')),
          matching: find.text('1'),
        ),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: find.byKey(const Key('dp_orders_stat_completed')),
          matching: find.text('1'),
        ),
        findsOneWidget,
      );
    });

    testWidgets('renders the order tab bar', (tester) async {
      setDesktopSize(tester);
      await tester.pumpWidget(buildPage());
      await tester.pump();

      expect(find.byKey(const Key('dp_orders_tab_all')), findsOneWidget);
      expect(find.byKey(const Key('dp_orders_tab_active')), findsOneWidget);
      expect(find.byKey(const Key('dp_orders_tab_pending')), findsOneWidget);
      expect(find.byKey(const Key('dp_orders_tab_completed')), findsOneWidget);
      expect(find.text('All'), findsOneWidget);
      expect(
        find.descendant(
          of: find.byKey(const Key('dp_orders_tab_active')),
          matching: find.text('Active'),
        ),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: find.byKey(const Key('dp_orders_tab_pending')),
          matching: find.text('Pending'),
        ),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: find.byKey(const Key('dp_orders_tab_completed')),
          matching: find.text('Completed'),
        ),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: find.byKey(const Key('dp_orders_tab_all')),
          matching: find.text('3'),
        ),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: find.byKey(const Key('dp_orders_tab_active')),
          matching: find.text('1'),
        ),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: find.byKey(const Key('dp_orders_tab_pending')),
          matching: find.text('1'),
        ),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: find.byKey(const Key('dp_orders_tab_completed')),
          matching: find.text('1'),
        ),
        findsOneWidget,
      );
    });

    testWidgets('renders order cards with restaurant and customer details', (
      tester,
    ) async {
      setDesktopSize(tester);
      await tester.pumpWidget(buildPage());
      await tester.pump();

      expect(find.byKey(const Key('dp_orders_card_ORD12345')), findsOneWidget);
      expect(find.byKey(const Key('dp_orders_card_ORD12346')), findsOneWidget);
      expect(find.byKey(const Key('dp_orders_card_ORD12347')), findsOneWidget);

      expect(find.text('#ORD12345'), findsOneWidget);
      expect(find.text('Green Bowl Kitchen'), findsOneWidget);
      expect(find.text('Priya Sharma'), findsOneWidget);
      expect(find.text('Spice Route'), findsNWidgets(2));
      expect(find.text('The Pasta Lab'), findsOneWidget);
    });

    testWidgets('renders status tags, earnings and payment type per card', (
      tester,
    ) async {
      setDesktopSize(tester);
      await tester.pumpWidget(buildPage());
      await tester.pump();

      expect(
        find.descendant(
          of: find.byKey(const Key('dp_orders_card_ORD12345')),
          matching: find.text('Pending'),
        ),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: find.byKey(const Key('dp_orders_card_ORD12346')),
          matching: find.text('In Progress'),
        ),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: find.byKey(const Key('dp_orders_card_ORD12347')),
          matching: find.text('Delivered'),
        ),
        findsNWidgets(2),
      );
      expect(find.textContaining('Your Earnings'), findsNWidgets(3));
      expect(find.textContaining('Payment: Cash'), findsOneWidget);
      expect(find.text('₹486.50'), findsOneWidget);
      expect(find.text('3 items'), findsOneWidget);
      expect(find.text('2.4 km'), findsOneWidget);
    });

    testWidgets('dispatches tab changed event when a tab is tapped', (
      tester,
    ) async {
      setDesktopSize(tester);
      await tester.pumpWidget(buildPage());
      await tester.pump();

      await tester.tap(find.byKey(const Key('dp_orders_tab_active')));
      await tester.pump();

      verify(
        () => mockBloc.add(
          const DeliveryOrdersTabChangedEvent(DeliveryOrdersTab.active),
        ),
      ).called(1);
    });

    testWidgets('dispatches search query event when typing', (tester) async {
      setDesktopSize(tester);
      await tester.pumpWidget(buildPage());
      await tester.pump();

      await tester.enterText(
        find.byKey(const Key('dp_orders_search_field')),
        'Green',
      );
      await tester.pump();

      verify(
        () =>
            mockBloc.add(const DeliveryOrdersSearchQueryChangedEvent('Green')),
      ).called(1);
    });

    testWidgets('shows directions snackbar when navigate is tapped', (
      tester,
    ) async {
      setDesktopSize(tester);
      await tester.pumpWidget(buildPage());
      await tester.pump();

      await tester.tap(find.byKey(const Key('dp_orders_navigate_ORD12345')));
      await tester.pump();

      expect(
        find.textContaining('Opening directions to 21 MG Road, Velachery'),
        findsOneWidget,
      );
    });

    testWidgets('dispatches update status event when update is tapped', (
      tester,
    ) async {
      setDesktopSize(tester);
      await tester.pumpWidget(buildPage());
      await tester.pump();

      await tester.tap(find.byKey(const Key('dp_orders_update_ORD12345')));
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

    testWidgets('disables update button for completed orders', (tester) async {
      setDesktopSize(tester);
      await tester.pumpWidget(buildPage());
      await tester.pump();

      final updateButton = tester.widget<ElevatedButton>(
        find.byKey(const Key('dp_orders_update_ORD12347')),
      );
      expect(updateButton.onPressed, isNull);
    });

    testWidgets('shows the current delivery banner for an active order', (
      tester,
    ) async {
      setDesktopSize(tester);
      await tester.pumpWidget(buildPage());
      await tester.pump();

      expect(find.byKey(const Key('dp_orders_banner')), findsOneWidget);
      expect(find.text('Current Delivery'), findsOneWidget);
      expect(
        find.byKey(const Key('dp_orders_banner_navigate')),
        findsOneWidget,
      );
      expect(find.byKey(const Key('dp_orders_banner_call')), findsOneWidget);
    });

    testWidgets('shows the live map panel on wide viewports', (tester) async {
      setDesktopSize(tester);
      await tester.pumpWidget(buildPage());
      await tester.pump();

      expect(find.byKey(const Key('dp_orders_map_panel')), findsOneWidget);
      expect(find.text('Live Map'), findsOneWidget);
    });

    testWidgets('shows a calling fallback bottom sheet with warning badge when phone is missing', (
      tester,
    ) async {
      setDesktopSize(tester);
      await tester.pumpWidget(buildPage());
      await tester.pump();

      await tester.tap(find.byKey(const Key('dp_orders_call_ORD12345')));
      await tester.pumpAndSettle();

      expect(
        find.text('No phone number available for Priya Sharma'),
        findsAtLeastNWidgets(1),
      );
      expect(find.byIcon(Icons.phone_disabled), findsAtLeastNWidgets(1));

      final callButton = tester.widget<ElevatedButton>(
        find.widgetWithText(ElevatedButton, 'No phone number available for Priya Sharma'),
      );
      expect(callButton.onPressed, isNull);
    });

    testWidgets('dispatches sort changed event from the sort menu', (
      tester,
    ) async {
      setDesktopSize(tester);
      await tester.pumpWidget(buildPage());
      await tester.pump();

      await tester.tap(find.byKey(const Key('dp_orders_sort')));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('dp_orders_sort_distance')));
      await tester.pumpAndSettle();

      verify(
        () => mockBloc.add(
          const DeliveryOrdersSortChangedEvent(DeliveryOrdersSort.distance),
        ),
      ).called(1);
    });

    testWidgets('dispatches payment filter event from the filter menu', (
      tester,
    ) async {
      setDesktopSize(tester);
      await tester.pumpWidget(buildPage());
      await tester.pump();

      await tester.tap(find.byKey(const Key('dp_orders_filter')));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('dp_orders_filter_cash')));
      await tester.pumpAndSettle();

      verify(
        () => mockBloc.add(
          const DeliveryOrdersPaymentFilterChangedEvent(
            DeliveryOrdersPaymentFilter.cash,
          ),
        ),
      ).called(1);
    });

    testWidgets('dispatches auto refresh toggle event', (tester) async {
      setDesktopSize(tester);
      await tester.pumpWidget(buildPage());
      await tester.pump();

      await tester.tap(find.byKey(const Key('dp_orders_autorefresh')));
      await tester.pump();

      verify(
        () => mockBloc.add(const DeliveryOrdersAutoRefreshToggledEvent(true)),
      ).called(1);
    });

    testWidgets('dispatches refresh from the floating action button', (
      tester,
    ) async {
      setDesktopSize(tester);
      await tester.pumpWidget(buildPage());
      await tester.pump();

      await tester.tap(find.byKey(const Key('dp_orders_fab_refresh')));
      await tester.pump();

      verify(() => mockBloc.add(const DeliveryOrdersRefreshEvent())).called(1);
    });

    testWidgets('renders error shell and dispatches init on retry', (
      tester,
    ) async {
      setDesktopSize(tester);
      when(() => mockBloc.state).thenReturn(errorState);
      await tester.pumpWidget(buildPage());
      await tester.pump();

      expect(find.byKey(const Key('dp_orders_error')), findsOneWidget);
      expect(
        find.text('Something went wrong while loading your orders.'),
        findsOneWidget,
      );
      expect(find.text('Database offline'), findsOneWidget);

      await tester.tap(find.byKey(const Key('dp_orders_retry')));
      await tester.pump();

      verify(() => mockBloc.add(const DeliveryOrdersInitEvent())).called(1);
    });

    testWidgets('renders empty shell and dispatches refresh', (tester) async {
      setDesktopSize(tester);
      when(() => mockBloc.state).thenReturn(emptyState);
      await tester.pumpWidget(buildPage());
      await tester.pump();

      expect(find.byKey(const Key('dp_orders_empty')), findsOneWidget);
      expect(find.text('No orders available'), findsOneWidget);

      await tester.tap(find.byKey(const Key('dp_orders_refresh')));
      await tester.pump();

      verify(() => mockBloc.add(const DeliveryOrdersRefreshEvent())).called(1);
    });

    testWidgets('renders no-results fallback when filters match nothing', (
      tester,
    ) async {
      setDesktopSize(tester);
      when(() => mockBloc.state).thenReturn(noResultsState);
      await tester.pumpWidget(buildPage());
      await tester.pump();

      expect(find.byKey(const Key('dp_orders_no_results')), findsOneWidget);
      expect(find.text('No orders found'), findsOneWidget);
      expect(find.byKey(const Key('dp_orders_refresh')), findsOneWidget);
    });

    testWidgets('renders loading skeleton while initialising', (tester) async {
      setDesktopSize(tester);
      when(() => mockBloc.state).thenReturn(
        const DeliveryOrdersPageState(status: DeliveryOrdersPageStatus.loading),
      );
      await tester.pumpWidget(buildPage());
      await tester.pump();

      expect(find.byKey(const Key('dp_orders_loading')), findsOneWidget);
    });

    testWidgets(
      'renders notification bell badge and opens notification bottom sheet on tap',
      (tester) async {
        setDesktopSize(tester);
        when(() => mockBloc.state).thenReturn(loadedState);
        await tester.pumpWidget(buildPage());
        await tester.pump();

        expect(find.byKey(const Key('dp_orders_notification')), findsOneWidget);
        expect(
          find.byKey(const Key('dp_orders_notification_badge')),
          findsOneWidget,
        );

        await tester.tap(find.byKey(const Key('dp_orders_notification')));
        await tester.pumpAndSettle();

        expect(find.text('Notifications'), findsWidgets);
        expect(
          find.text('1 pending order requests available'),
          findsOneWidget,
        );
      },
    );

    testWidgets('renders the available order card with all required fields', (
      tester,
    ) async {
      setDesktopSize(tester);
      when(() => mockBloc.state).thenReturn(availableState);
      await tester.pumpWidget(buildPage());
      await tester.pump();

      final card = find.byKey(const Key('dp_orders_available_card_ORD20001'));
      expect(card, findsOneWidget);

      Finder inCard(String text) =>
          find.descendant(of: card, matching: find.text(text));

      expect(inCard('#ORD20001'), findsOneWidget);
      expect(inCard('Crispy Dosa House'), findsOneWidget);
      expect(inCard('Restaurant Location'), findsOneWidget);
      expect(inCard('Customer Area'), findsOneWidget);
      expect(inCard('6.0 km'), findsOneWidget);
      expect(inCard('25 min'), findsOneWidget);
      expect(inCard('Estimated Earnings'), findsOneWidget);
      expect(inCard('₹85.00'), findsOneWidget);
      expect(inCard('3 items'), findsOneWidget);
      expect(inCard('1.8 km to restaurant'), findsOneWidget);
      expect(inCard('4.2 km to customer'), findsOneWidget);
      expect(
        find.byKey(const Key('dp_orders_accept_ORD20001')),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('dp_orders_reject_ORD20001')),
        findsOneWidget,
      );
      expect(find.byKey(const Key('dp_orders_copy_ORD20001')), findsOneWidget);
    });

    testWidgets('dispatches accept event when the accept button is tapped', (
      tester,
    ) async {
      setDesktopSize(tester);
      when(() => mockBloc.state).thenReturn(availableState);
      await tester.pumpWidget(buildPage());
      await tester.pump();

      await tester.tap(find.byKey(const Key('dp_orders_accept_ORD20001')));
      await tester.pump();

      verify(
        () => mockBloc.add(const DeliveryOrdersAcceptOrderEvent('ORD20001')),
      ).called(1);
    });

    testWidgets('dispatches reject event when the reject button is tapped', (
      tester,
    ) async {
      setDesktopSize(tester);
      when(() => mockBloc.state).thenReturn(availableState);
      await tester.pumpWidget(buildPage());
      await tester.pump();

      await tester.tap(find.byKey(const Key('dp_orders_reject_ORD20001')));
      await tester.pump();

      verify(
        () => mockBloc.add(const DeliveryOrdersRejectOrderEvent('ORD20001')),
      ).called(1);
    });

    testWidgets('shows a spinner while an available order is being accepted', (
      tester,
    ) async {
      setDesktopSize(tester);
      when(() => mockBloc.state).thenReturn(
        const DeliveryOrdersPageState(
          status: DeliveryOrdersPageStatus.loaded,
          orders: [availableOrder],
          filteredOrders: [availableOrder],
          acceptingOrderId: 'ORD20001',
        ),
      );
      await tester.pumpWidget(buildPage());
      await tester.pump();

      expect(
        find.descendant(
          of: find.byKey(const Key('dp_orders_accept_ORD20001')),
          matching: find.byType(CircularProgressIndicator),
        ),
        findsOneWidget,
      );
    });
  });
}
