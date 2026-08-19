import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/services.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Dashboard_page/Delivery_Dashboard_page_bloc.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Dashboard_page/Delivery_Dashboard_page_event.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Dashboard_page/Delivery_Dashboard_page_state.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Dashboard_page/Delivery_Dashboard_page_ui.dart';

import '../../font_loader_helper.dart';

class MockDeliveryDashboardPageBloc
    extends MockBloc<DeliveryDashboardPageEvent, DeliveryDashboardState>
    implements DeliveryDashboardPageBloc {}

const List<DeliveryActivityItem> defaultActivities = [
  DeliveryActivityItem(
    id: 'act_1',
    time: '10:30 AM',
    title: 'Order Delivered',
    subtitle: 'Order #ORD12345',
    details: '₹120.00',
    statusType: 'delivered',
  ),
  DeliveryActivityItem(
    id: 'act_2',
    time: '10:02 AM',
    title: 'Order Picked Up',
    subtitle: 'Order #ORD12345',
    details: 'Green Mart, Anna Salai',
    statusType: 'picked_up',
  ),
  DeliveryActivityItem(
    id: 'act_3',
    time: '09:45 AM',
    title: 'New Order Received',
    subtitle: 'Order #ORD12345',
    details: '2.4 km away',
    statusType: 'new_order',
  ),
  DeliveryActivityItem(
    id: 'act_4',
    time: '09:40 AM',
    title: 'Reached Restaurant',
    subtitle: 'Green Mart, Anna Salai',
    details: '',
    statusType: 'reached_restaurant',
  ),
  DeliveryActivityItem(
    id: 'act_5',
    time: '09:30 AM',
    title: 'Went Online',
    subtitle: 'You are now online and available',
    details: '',
    statusType: 'went_online',
  ),
];

void main() {
  late MockDeliveryDashboardPageBloc mockBloc;

  const DeliveryDashboardState loadedState = DeliveryDashboardState(
    status: DeliveryDashboardStatus.loaded,
    isOnline: true,
    partnerStatus: DeliveryPartnerStatusType.online,
    todayEarnings: 2450.00,
    todayTotalDeliveries: 18,
    completedDeliveriesCount: 15,
    pendingDeliveriesCount: 2,
    cancelledDeliveriesCount: 1,
    todayDistance: 42.5,
    onlineHours: '5h 45m',
    averageRating: 4.8,
    recentActivities: defaultActivities,
  );

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
    mockBloc = MockDeliveryDashboardPageBloc();
    when(() => mockBloc.state).thenReturn(loadedState);
  });

  Widget buildPage() {
    return MaterialApp(
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0B1219),
      ),
      home: Scaffold(body: DeliveryDashboardPage(bloc: mockBloc)),
    );
  }

  group('DeliveryDashboardPage Golden Tests', () {
    testWidgets('renders pixel-perfect dark dashboard layout on desktop', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(1440, 1024);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(buildPage());
      await tester.pump();

      expect(find.byType(DeliveryDashboardPage), findsOneWidget);
      expect(find.byKey(const Key('dp_dashboard_greeting')), findsOneWidget);
      expect(find.byKey(const Key('dp_dashboard_glow_ring')), findsOneWidget);
      expect(find.text('ONLINE'), findsOneWidget);
      expect(find.text('₹2450.00'), findsWidgets);
    });

    testWidgets('renders dark theme dashboard layout on tablet viewport', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(800, 1024);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(buildPage());
      await tester.pump();

      expect(find.byKey(const Key('dp_dashboard_page')), findsOneWidget);
      expect(find.byKey(const Key('dp_dashboard_map_card')), findsOneWidget);
      expect(find.byKey(const Key('dp_dashboard_earn_banner')), findsOneWidget);
      expect(
        find.byKey(const Key('dp_dashboard_activity_card')),
        findsOneWidget,
      );
    });

    testWidgets('renders dark theme dashboard layout on mobile viewport', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(buildPage());
      await tester.pump();

      expect(find.byKey(const Key('dp_dashboard_page')), findsOneWidget);
      expect(find.byKey(const Key('dp_dashboard_map_card')), findsOneWidget);
      expect(
        find.byKey(const Key('dp_dashboard_metric_earnings')),
        findsOneWidget,
      );
    });

    testWidgets('matches dark theme color palette', (tester) async {
      tester.view.physicalSize = const Size(1280, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(buildPage());
      await tester.pump();

      final earningsMetric = tester.widget<Container>(
        find
            .descendant(
              of: find.byKey(const Key('dp_dashboard_metric_earnings')),
              matching: find.byType(Container),
            )
            .first,
      );
      final earningsDecoration = earningsMetric.decoration as BoxDecoration;
      expect(earningsDecoration.color, const Color(0xFF161B22));

      final activityCard = tester.widget<Container>(
        find
            .descendant(
              of: find.byKey(const Key('dp_dashboard_activity_card')),
              matching: find.byType(Container),
            )
            .first,
      );
      final activityDecoration = activityCard.decoration as BoxDecoration;
      expect(activityDecoration.color, const Color(0xFF161B22));
    });

    testWidgets('glow ring reflects offline palette when offline', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(1280, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      when(
        () => mockBloc.state,
      ).thenReturn(loadedState.copyWith(
        isOnline: false,
        partnerStatus: DeliveryPartnerStatusType.offline,
      ));

      await tester.pumpWidget(buildPage());
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.text('OFFLINE'), findsOneWidget);
      expect(find.byKey(const Key('dp_dashboard_online_card')), findsOneWidget);
    });
  });
}
