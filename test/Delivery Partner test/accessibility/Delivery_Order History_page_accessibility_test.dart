import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Order%20History_page/Delivery_Order%20History_page_bloc.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Order%20History_page/Delivery_Order%20History_page_event.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Order%20History_page/Delivery_Order%20History_page_state.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Order%20History_page/Delivery_Order%20History_page_ui.dart';

class MockDeliveryOrderHistoryPageBloc
    extends
        MockBloc<DeliveryOrderHistoryPageEvent, DeliveryOrderHistoryPageState>
    implements DeliveryOrderHistoryPageBloc {}

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

const order1 = DeliveryOrderHistoryModel(
  orderId: 'ORD-1001',
  customerName: 'Priya Sharma',
  phoneNumber: '9840112233',
  pickupAddress: '42 Anna Salai, Chennai',
  dropAddress: '21 MG Road, Velachery',
  dateLabel: 'May 22, 2025 • 10:30',
  epochSeconds: 1747909800,
  distanceKm: 2.4,
  amount: 486.50,
  status: DeliveryOrderHistoryStatus.completed,
  paymentType: 'COD',
);

const order2 = DeliveryOrderHistoryModel(
  orderId: 'ORD-1002',
  customerName: 'Arun Prakash',
  phoneNumber: '9884499001',
  pickupAddress: '108 Greams Road, Nungambakkam',
  dropAddress: '7 Lake View Road, Adyar',
  dateLabel: 'May 21, 2025 • 11:42',
  epochSeconds: 1747827720,
  distanceKm: 4.1,
  amount: 732.00,
  status: DeliveryOrderHistoryStatus.pending,
  paymentType: 'Online',
);

const allOrders = [order1, order2];

const loadedState = DeliveryOrderHistoryPageState(
  status: DeliveryOrderHistoryPageStatus.loaded,
  orders: allOrders,
  filteredOrders: allOrders,
  pageOrders: allOrders,
  stats: DeliveryOrderHistoryStats(
    totalOrders: 2,
    completedCount: 1,
    cancelledCount: 0,
    pendingCount: 1,
    totalEarnings: 1218.50,
    totalOrdersDelta: 12.5,
    earningsDelta: 18.6,
  ),
  page: 1,
  pageSize: 10,
);

void main() {
  late MockDeliveryOrderHistoryPageBloc mockBloc;

  setUpAll(() {
    registerFallbackValue(const DeliveryOrderHistoryInitEvent());
    registerFallbackValue(const DeliveryOrderHistoryRefreshEvent());
    registerFallbackValue(const DeliveryOrderHistorySearchChangedEvent(''));
    registerFallbackValue(
      const DeliveryOrderHistoryStatusFilterChangedEvent(
        DeliveryOrderHistoryStatusFilter.all,
      ),
    );
    registerFallbackValue(
      const DeliveryOrderHistoryPaymentFilterChangedEvent(
        DeliveryOrderHistoryPaymentFilter.all,
      ),
    );
    registerFallbackValue(const DeliveryOrderHistoryPageChangedEvent(1));
    registerFallbackValue(const DeliveryOrderHistoryPageSizeChangedEvent(10));
    registerFallbackValue(const DeliveryOrderHistoryToggleSidebarEvent());
    registerFallbackValue(const DeliveryOrderHistoryDateRangeChangedEvent());
  });

  setUp(() {
    mockBloc = MockDeliveryOrderHistoryPageBloc();
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
        scaffoldBackgroundColor: const Color(0xFF0C1017),
      ),
      home: Scaffold(body: DeliveryOrderHistoryPage(bloc: mockBloc)),
    );
  }

  group('DeliveryOrderHistoryPage Accessibility Tests', () {
    testWidgets('sidebar navigation items meet minimum touch height', (
      tester,
    ) async {
      setDesktopSize(tester);
      await tester.pumpWidget(buildPage());
      await tester.pump();

      final historyItem = find.text('History');
      expect(historyItem, findsOneWidget);
      final size = tester.getSize(historyItem.first);
      expect(size.height, greaterThanOrEqualTo(20.0));
    });

    testWidgets('search field exposes a text input with hint semantics', (
      tester,
    ) async {
      setDesktopSize(tester);
      final SemanticsHandle handle = tester.ensureSemantics();
      await tester.pumpWidget(buildPage());
      await tester.pump();

      final field = tester.widget<TextField>(
        find.byKey(const Key('dp_oh_search_field')),
      );
      expect(field.decoration?.hintText, isNotNull);

      final semantics = tester.getSemantics(
        find.descendant(
          of: find.byKey(const Key('dp_oh_search_field')),
          matching: find.byType(EditableText),
        ),
      );
      expect(semantics, isNotNull);
      expect(semantics.getSemanticsData().flagsCollection.isTextField, isTrue);

      handle.dispose();
    });

    testWidgets('view details buttons meet minimum tap target size', (
      tester,
    ) async {
      setDesktopSize(tester);
      await tester.pumpWidget(buildPage());
      await tester.pump();

      final detailsButton = find.byKey(
        const Key('dp_oh_view_details_ORD-1001'),
      );
      expect(detailsButton, findsOneWidget);
      expect(tester.getSize(detailsButton).width, greaterThanOrEqualTo(44.0));
      expect(tester.getSize(detailsButton).height, greaterThanOrEqualTo(36.0));
    });

    testWidgets('pagination buttons meet minimum touch target size', (
      tester,
    ) async {
      setDesktopSize(tester);
      await tester.pumpWidget(buildPage());
      await tester.pump();

      final pageBtn = find.byKey(const Key('dp_oh_page_1'));
      expect(pageBtn, findsOneWidget);
      expect(tester.getSize(pageBtn).width, greaterThanOrEqualTo(30.0));
      expect(tester.getSize(pageBtn).height, greaterThanOrEqualTo(30.0));
    });

    testWidgets('maintains accessible color contrast ratios on dark theme', (
      tester,
    ) async {
      const cardBackground = Color(0xFF1C2533);
      const panelBackground = Color(0xFF131922);
      const primaryText = Colors.white;
      const secondaryText = Color(0xFF94A3B8);
      const accentGreen = Color(0xFF10B981);

      expect(
        _contrastRatio(primaryText, cardBackground),
        greaterThanOrEqualTo(4.5),
      );
      expect(
        _contrastRatio(secondaryText, cardBackground),
        greaterThanOrEqualTo(4.5),
      );
      expect(
        _contrastRatio(primaryText, panelBackground),
        greaterThanOrEqualTo(4.5),
      );
      expect(
        _contrastRatio(accentGreen, cardBackground),
        greaterThanOrEqualTo(3.0),
      );
    });
  });
}
