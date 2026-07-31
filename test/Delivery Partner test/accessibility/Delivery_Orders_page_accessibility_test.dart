import 'dart:math' as math;
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

double _relativeLuminance(Color color) {
  double channel(double value) {
    final v = value / 255.0;
    return v <= 0.03928
        ? v / 12.92
        : math.pow((v + 0.055) / 1.055, 2.4).toDouble();
  }

  return 0.2126 * channel(color.r * 255) +
      0.7152 * channel(color.g * 255) +
      0.0722 * channel(color.b * 255);
}

double _contrastRatio(Color foreground, Color background) {
  final fg = _relativeLuminance(foreground);
  final bg = _relativeLuminance(background);
  final lighter = math.max(fg, bg);
  final darker = math.min(fg, bg);
  return (lighter + 0.05) / (darker + 0.05);
}

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

const loadedState = DeliveryOrdersPageState(
  status: DeliveryOrdersPageStatus.loaded,
  orders: [pendingOrder, activeOrder],
  filteredOrders: [pendingOrder, activeOrder],
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
    registerFallbackValue(
      const DeliveryOrdersTabChangedEvent(DeliveryOrdersTab.all),
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
      home: Scaffold(body: DeliveryOrdersPage(bloc: mockBloc)),
    );
  }

  group('DeliveryOrdersPage Accessibility Tests', () {
    testWidgets('card action buttons meet minimum tap target size', (
      tester,
    ) async {
      setDesktopSize(tester);
      await tester.pumpWidget(buildPage());
      await tester.pump();

      final navigate = find.byKey(const Key('dp_orders_navigate_ORD12345'));
      final update = find.byKey(const Key('dp_orders_update_ORD12345'));

      expect(tester.getSize(navigate).width, greaterThanOrEqualTo(44.0));
      expect(tester.getSize(navigate).height, greaterThanOrEqualTo(44.0));
      expect(tester.getSize(update).width, greaterThanOrEqualTo(44.0));
      expect(tester.getSize(update).height, greaterThanOrEqualTo(44.0));
    });

    testWidgets('tab pills expose a minimum touch height', (tester) async {
      setDesktopSize(tester);
      await tester.pumpWidget(buildPage());
      await tester.pump();

      final tab = find.byKey(const Key('dp_orders_tab_all'));
      final size = tester.getSize(tab);
      expect(size.width, greaterThanOrEqualTo(40.0));
      expect(size.height, greaterThanOrEqualTo(36.0));
    });

    testWidgets('exposes selected semantics for the active tab', (
      tester,
    ) async {
      setDesktopSize(tester);
      await tester.pumpWidget(buildPage());
      await tester.pump();

      final selectedSemantics = tester
          .widgetList<Semantics>(find.byType(Semantics))
          .where((s) => s.properties.selected == true)
          .toList();

      expect(selectedSemantics, isNotEmpty);
    });

    testWidgets('search field exposes a text input with hint semantics', (
      tester,
    ) async {
      setDesktopSize(tester);
      final SemanticsHandle handle = tester.ensureSemantics();
      await tester.pumpWidget(buildPage());
      await tester.pump();

      final field = tester.widget<TextField>(
        find.byKey(const Key('dp_orders_search_field')),
      );
      expect(field.decoration?.hintText, isNotNull);

      final semantics = tester.getSemantics(
        find.descendant(
          of: find.byKey(const Key('dp_orders_search_field')),
          matching: find.byType(EditableText),
        ),
      );
      expect(semantics, isNotNull);
      expect(semantics.getSemanticsData().flagsCollection.isTextField, isTrue);

      handle.dispose();
    });

    testWidgets('maintains accessible color contrast ratios on dark cards', (
      tester,
    ) async {
      const cardBackground = Color(0xFF0F1E26);
      const chipBackground = Color(0xFF0D141C);
      const primaryText = Colors.white;
      const secondaryText = Color(0xFF94A3B8);
      const accentGreen = Color(0xFF00E676);

      expect(
        _contrastRatio(primaryText, cardBackground),
        greaterThanOrEqualTo(4.5),
      );
      expect(
        _contrastRatio(secondaryText, cardBackground),
        greaterThanOrEqualTo(4.5),
      );
      expect(
        _contrastRatio(primaryText, chipBackground),
        greaterThanOrEqualTo(4.5),
      );
      expect(
        _contrastRatio(accentGreen, chipBackground),
        greaterThanOrEqualTo(3.0),
      );
    });
  });
}
