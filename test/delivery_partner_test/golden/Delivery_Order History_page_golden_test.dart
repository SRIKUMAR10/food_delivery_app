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

const goldenOrder1 = DeliveryOrderHistoryModel(
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

const goldenOrder2 = DeliveryOrderHistoryModel(
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

const goldenOrder3 = DeliveryOrderHistoryModel(
  orderId: 'ORD-1004',
  customerName: 'Karthik Raja',
  phoneNumber: '9003112220',
  pickupAddress: '2 T Nagar 3rd Main Road',
  dropAddress: '19 Ashok Nagar 1st Avenue',
  dateLabel: 'May 23, 2025 • 16:20',
  epochSeconds: 1748017200,
  distanceKm: 1.2,
  amount: 245.00,
  status: DeliveryOrderHistoryStatus.cancelled,
  paymentType: 'COD',
);

const goldenOrders = [goldenOrder1, goldenOrder2, goldenOrder3];

const goldenStats = DeliveryOrderHistoryStats(
  totalOrders: 3,
  completedCount: 1,
  cancelledCount: 1,
  pendingCount: 1,
  totalEarnings: 1463.50,
  totalOrdersDelta: 12.5,
  earningsDelta: 18.6,
);

const goldenLoadedState = DeliveryOrderHistoryPageState(
  status: DeliveryOrderHistoryPageStatus.loaded,
  orders: goldenOrders,
  filteredOrders: goldenOrders,
  pageOrders: goldenOrders,
  stats: goldenStats,
  pageSize: 5,
);

void main() {
  late MockDeliveryOrderHistoryPageBloc mockBloc;

  setUp(() {
    mockBloc = MockDeliveryOrderHistoryPageBloc();
    when(() => mockBloc.state).thenReturn(goldenLoadedState);
  });

  Widget buildPage() {
    return MaterialApp(
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0C1017),
      ),
      home: Scaffold(body: DeliveryOrderHistoryPage(bloc: mockBloc)),
    );
  }

  group('DeliveryOrderHistoryPage Golden Tests', () {
    testWidgets('renders pixel-perfect dark history layout on desktop', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(1440, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(buildPage());
      await tester.pump();

      expect(find.byType(DeliveryOrderHistoryPage), findsOneWidget);
      expect(find.byKey(const Key('dp_oh_page')), findsOneWidget);
      expect(find.byKey(const Key('dp_oh_topbar')), findsOneWidget);
      expect(find.byKey(const Key('dp_oh_table')), findsOneWidget);
      expect(find.byKey(const Key('dp_oh_stat_total')), findsOneWidget);
    });

    testWidgets('renders dark theme history layout on tablet viewport', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      when(
        () => mockBloc.state,
      ).thenReturn(goldenLoadedState.copyWith(sidebarOpen: false));

      await tester.pumpWidget(buildPage());
      await tester.pump();

      expect(find.byKey(const Key('dp_oh_page')), findsOneWidget);
      expect(find.byKey(const Key('dp_oh_stat_earnings')), findsOneWidget);
      expect(find.byKey(const Key('dp_oh_card_ORD-1001')), findsOneWidget);
    });

    testWidgets('renders dark theme history layout on mobile viewport', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      when(
        () => mockBloc.state,
      ).thenReturn(goldenLoadedState.copyWith(sidebarOpen: false));

      await tester.pumpWidget(buildPage());
      await tester.pump();

      expect(find.byKey(const Key('dp_oh_page')), findsOneWidget);
      expect(find.byKey(const Key('dp_oh_sidebar_toggle')), findsOneWidget);
      expect(find.byKey(const Key('dp_oh_card_ORD-1001')), findsOneWidget);
      expect(find.byKey(const Key('dp_oh_table')), findsNothing);
    });

    testWidgets('matches the dark theme color palette', (tester) async {
      tester.view.physicalSize = const Size(1440, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(buildPage());
      await tester.pump();

      final root = tester.widget<Container>(
        find.byKey(const Key('dp_oh_page')),
      );
      expect(root.color, const Color(0xFF060B11));

      final stat = tester.widget<Container>(
        find.byKey(const Key('dp_oh_stat_total')),
      );
      final statDecoration = stat.decoration as BoxDecoration;
      expect(statDecoration.color, const Color(0xFF161B22));

      expect(tester.takeException(), isNull);
    });

    testWidgets('renders the loading skeleton with the dark palette', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(1280, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      when(() => mockBloc.state).thenReturn(
        const DeliveryOrderHistoryPageState(
          status: DeliveryOrderHistoryPageStatus.loading,
        ),
      );

      await tester.pumpWidget(buildPage());
      await tester.pump();

      expect(find.byKey(const Key('dp_oh_loading')), findsOneWidget);
    });
  });
}
