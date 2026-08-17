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

const enState = DeliveryOrdersPageState(
  status: DeliveryOrdersPageStatus.loaded,
  orders: [pendingOrder, completedOrder],
  filteredOrders: [pendingOrder, completedOrder],
);

const taState = DeliveryOrdersPageState(
  status: DeliveryOrdersPageStatus.loaded,
  localeCode: 'ta',
  orders: [pendingOrder, completedOrder],
  filteredOrders: [pendingOrder, completedOrder],
);

void main() {
  late MockDeliveryOrdersPageBloc mockBloc;

  setUp(() {
    mockBloc = MockDeliveryOrdersPageBloc();
    when(() => mockBloc.state).thenReturn(enState);
  });

  void setDesktopSize(WidgetTester tester) {
    tester.view.physicalSize = const Size(1280, 1600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
  }

  Widget buildPage() {
    return MaterialApp(
      home: Scaffold(body: DeliveryOrdersPage(bloc: mockBloc)),
    );
  }

  group('DeliveryOrdersPage Localization Tests', () {
    testWidgets('renders English UI text by default', (tester) async {
      setDesktopSize(tester);
      await tester.pumpWidget(buildPage());
      await tester.pump();

      expect(find.text('Orders Overview'), findsOneWidget);
      expect(
        find.descendant(
          of: find.byKey(const Key('dp_orders_stat_total')),
          matching: find.text('Total'),
        ),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: find.byKey(const Key('dp_orders_stat_active')),
          matching: find.text('Active'),
        ),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: find.byKey(const Key('dp_orders_stat_pending')),
          matching: find.text('Pending'),
        ),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: find.byKey(const Key('dp_orders_stat_completed')),
          matching: find.text('Completed'),
        ),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: find.byKey(const Key('dp_orders_tab_active')),
          matching: find.text('Active'),
        ),
        findsOneWidget,
      );
      expect(find.text('Your Earnings: ₹87.57'), findsOneWidget);
    });

    testWidgets('renders Tamil UI text when locale is Tamil', (tester) async {
      setDesktopSize(tester);
      when(() => mockBloc.state).thenReturn(taState);
      await tester.pumpWidget(buildPage());
      await tester.pump();

      expect(find.text('ஆர்டர்கள் கண்ணோட்டம்'), findsOneWidget);
      expect(
        find.descendant(
          of: find.byKey(const Key('dp_orders_stat_total')),
          matching: find.text('மொத்தம்'),
        ),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: find.byKey(const Key('dp_orders_stat_active')),
          matching: find.text('செயலில்'),
        ),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: find.byKey(const Key('dp_orders_tab_active')),
          matching: find.text('செயலில்'),
        ),
        findsOneWidget,
      );
      expect(find.text('டெலிவரி ஆனது'), findsNWidgets(3));
    });

    testWidgets('translates order status labels in Tamil', (tester) async {
      setDesktopSize(tester);
      when(() => mockBloc.state).thenReturn(taState);
      await tester.pumpWidget(buildPage());
      await tester.pump();

      expect(find.text('நிலுவையில்'), findsWidgets);
      expect(find.textContaining('உங்கள் வருவாய்'), findsNWidgets(2));
      expect(find.text('வழிகாட்டுதல்'), findsNWidgets(2));
      expect(find.text('ஆர்டரை ஏற்க'), findsOneWidget);
    });

    test('string lookup falls back to English for unknown locales', () {
      expect(DeliveryOrdersStrings.of('title', 'fr'), 'Orders Overview');
      expect(
        DeliveryOrdersStrings.of('searchHint', 'hi'),
        'Search order ID, customer, restaurant or phone',
      );
      expect(DeliveryOrdersStrings.of('earnings', 'de'), 'Your Earnings');
    });

    test('available order labels are localized in English and Tamil', () {
      expect(DeliveryOrdersStrings.of('available', 'en'), 'Available');
      expect(DeliveryOrdersStrings.of('available', 'ta'), 'கிடைக்கிறது');
      expect(DeliveryOrdersStrings.of('accept', 'en'), 'Accept');
      expect(DeliveryOrdersStrings.of('accept', 'ta'), 'ஏற்க');
      expect(DeliveryOrdersStrings.of('reject', 'en'), 'Reject');
      expect(DeliveryOrdersStrings.of('reject', 'ta'), 'நிராகரி');
      expect(
        DeliveryOrdersStrings.of('conflict', 'en'),
        'Order already accepted by another delivery partner',
      );
      expect(
        DeliveryOrdersStrings.of('estimatedEarnings', 'en'),
        'Estimated Earnings',
      );
      expect(
        DeliveryOrdersStrings.of('pickupDistance', 'ta'),
        'பிக்கப் தூரம்',
      );
    });
  });
}
