import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Dashboard_page/Delivery_Dashboard_page_bloc.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Dashboard_page/Delivery_Dashboard_page_event.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Dashboard_page/Delivery_Dashboard_page_state.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Dashboard_page/Delivery_Dashboard_page_ui.dart';

class MockDeliveryDashboardPageBloc
    extends MockBloc<DeliveryDashboardPageEvent, DeliveryDashboardState>
    implements DeliveryDashboardPageBloc {}

void main() {
  late MockDeliveryDashboardPageBloc mockBloc;

  const loadedState = DeliveryDashboardState(
    status: DeliveryDashboardStatus.loaded,
    isOnline: true,
    isAvailable: true,
    isBusy: false,
    partnerStatus: DeliveryPartnerStatusType.available,
    todayEarnings: 2450.00,
    walletBalance: 2450.00,
    todayTotalDeliveries: 18,
    completedDeliveriesCount: 15,
    pendingDeliveriesCount: 2,
    cancelledDeliveriesCount: 1,
    todayDistance: 42.5,
    onlineHours: '5h 45m',
    averageRating: 4.8,
    todayOrdersCount: 18,
    activeOrdersCount: 2,
    workingHours: '05h 45m',
    acceptanceRate: 92,
    performanceScore: 4.8,
    partnerName: 'Ravi Kumar',
    vehicleNumber: 'TN 01 AB 1234',
    unreadNotificationCount: 3,
    incomingSellerOrders: [
      DeliveryActivityItem(
        id: 'order_001',
        time: '2:30 PM',
        title: 'Incoming Order #ord00123',
        subtitle: 'Green Mart',
        details: '350.00',
        statusType: 'seller_ready',
      ),
    ],
    recentActivities: [
      DeliveryActivityItem(
        id: 'act_1',
        time: '10:30 AM',
        title: 'Order Delivered',
        subtitle: 'Order #ORD12345',
        details: '₹120.00',
        statusType: 'delivered',
      ),
    ],
  );

  setUpAll(() {
    registerFallbackValue(const DeliveryDashboardInitEvent());
    registerFallbackValue(const DeliveryDashboardToggleOnlineEvent(true));
    registerFallbackValue(
      const DeliveryDashboardQuickActionExecutedEvent('available_orders'),
    );
  });

  setUp(() {
    mockBloc = MockDeliveryDashboardPageBloc();
    when(() => mockBloc.state).thenReturn(loadedState);
  });

  void setDesktopSize(WidgetTester tester) {
    tester.view.physicalSize = const Size(1280, 1000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
  }

  void setMobileSize(WidgetTester tester) {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
  }

  Widget buildPage() {
    return MaterialApp(
      theme: ThemeData(useMaterial3: false),
      home: Scaffold(body: DeliveryDashboardPage(bloc: mockBloc)),
    );
  }

  group('DeliveryDashboardPage Widget Tests', () {
    testWidgets('renders greeting, online status centerpiece and metrics', (
      tester,
    ) async {
      setDesktopSize(tester);
      await tester.pumpWidget(buildPage());
      await tester.pump();

      expect(find.textContaining('Ravi Kumar'), findsWidgets);
      expect(find.text('You are'), findsOneWidget);
      expect(find.text('AVAILABLE'), findsOneWidget);
      expect(find.text('₹2450.00'), findsWidgets);
      expect(find.text('18'), findsOneWidget);
      expect(find.text('15'), findsOneWidget);
      expect(find.text('2'), findsOneWidget);
      expect(find.text('1'), findsOneWidget);
      expect(find.text('42.5 km'), findsOneWidget);
      expect(find.text('4.8 ★'), findsOneWidget);
    });

    testWidgets('renders notification bell badge with unread count', (
      tester,
    ) async {
      setDesktopSize(tester);
      await tester.pumpWidget(buildPage());
      await tester.pump();

      final badge =
          find.byKey(const Key('dp_dashboard_notification_badge'));
      expect(badge, findsOneWidget);
      expect(find.text('3'), findsOneWidget);
    });

    testWidgets('hides notification badge when count is zero', (
      tester,
    ) async {
      setDesktopSize(tester);
      when(() => mockBloc.state).thenReturn(
        loadedState.copyWith(unreadNotificationCount: 0),
      );

      await tester.pumpWidget(buildPage());
      await tester.pump();

      expect(
        find.byKey(const Key('dp_dashboard_notification_badge')),
        findsNothing,
      );
    });

    testWidgets('notification bell is tappable and renders without crash', (
      tester,
    ) async {
      setDesktopSize(tester);
      await tester.pumpWidget(buildPage());
      await tester.pump();

      final bellButton =
          find.byKey(const Key('dp_dashboard_notification_button'));
      expect(bellButton, findsOneWidget);

      await tester.tap(bellButton);
      await tester.pumpAndSettle();

      expect(find.text('Notifications'), findsWidgets);

    });

    testWidgets('renders 2-column grid layout for metrics cards in mobile view', (
      tester,
    ) async {
      setMobileSize(tester);
      await tester.pumpWidget(buildPage());
      await tester.pump();

      final gridViewFinder = find.byType(GridView);
      expect(gridViewFinder, findsWidgets);

      final gridView = tester.widget<GridView>(gridViewFinder.first);
      final delegate =
          gridView.gridDelegate as SliverGridDelegateWithFixedCrossAxisCount;
      expect(delegate.crossAxisCount, equals(2));
    });

    testWidgets('renders recent activities and quick actions cards', (
      tester,
    ) async {
      setDesktopSize(tester);
      await tester.pumpWidget(buildPage());
      await tester.pump();

      expect(find.text('Recent Activity'), findsOneWidget);
      expect(find.text('Order Delivered'), findsWidgets);
      expect(find.text('Active Zone Map'), findsOneWidget);
      expect(find.text('Quick Actions'), findsOneWidget);
      expect(find.text('Today Incentive Goal'), findsOneWidget);
    });

    testWidgets('taps all 7 quick action buttons and verifies bloc events', (
      tester,
    ) async {
      setDesktopSize(tester);
      await tester.pumpWidget(buildPage());
      await tester.pump();

      Future<void> tapAndVerify(Key key, void Function() verifyCall) async {
        final btn = find.byKey(key);
        expect(btn, findsOneWidget);
        await tester.ensureVisible(btn);
        await tester.pump(const Duration(milliseconds: 300));
        await tester.tap(btn);
        await tester.pump(const Duration(milliseconds: 300));
        verifyCall();
        final navigator = tester.state<NavigatorState>(find.byType(Navigator));
        if (navigator.canPop()) {
          navigator.pop();
          await tester.pump(const Duration(milliseconds: 300));
        }
      }

      // 1. Go Online / Offline
      await tapAndVerify(const Key('dp_quick_action_toggle_online'), () {
        verify(
          () =>
              mockBloc.add(any(that: isA<DeliveryDashboardToggleOnlineEvent>())),
        ).called(1);
      });

      // 2. Available Orders
      await tapAndVerify(
          const Key('dp_quick_action_available_orders'), () {
        verify(
          () => mockBloc
              .add(const DeliveryDashboardQuickActionExecutedEvent('available_orders')),
        ).called(1);
      });

      // 3. Current Order
      await tapAndVerify(const Key('dp_quick_action_current_order'), () {
        verify(
          () => mockBloc
              .add(const DeliveryDashboardQuickActionExecutedEvent('current_order')),
        ).called(1);
      });

      // 4. Earnings
      await tapAndVerify(const Key('dp_quick_action_earnings'), () {
        verify(
          () => mockBloc
              .add(const DeliveryDashboardQuickActionExecutedEvent('earnings')),
        ).called(1);
      });

      // 5. Wallet
      await tapAndVerify(const Key('dp_quick_action_wallet'), () {
        verify(
          () => mockBloc
              .add(const DeliveryDashboardQuickActionExecutedEvent('wallet')),
        ).called(1);
      });

      // 6. Incentives
      await tapAndVerify(const Key('dp_quick_action_incentives'), () {
        verify(
          () => mockBloc
              .add(const DeliveryDashboardQuickActionExecutedEvent('incentives')),
        ).called(1);
      });

      // 7. Profile
      await tapAndVerify(const Key('dp_quick_action_profile'), () {
        verify(
          () => mockBloc
              .add(const DeliveryDashboardQuickActionExecutedEvent('profile')),
        ).called(1);
      });
    });

    testWidgets('hides floating online pill when isOnline is false in mobile view', (
      tester,
    ) async {
      setMobileSize(tester);
      when(() => mockBloc.state).thenReturn(
        loadedState.copyWith(isOnline: false, partnerStatus: DeliveryPartnerStatusType.offline),
      );

      await tester.pumpWidget(buildPage());
      await tester.pump();

      expect(find.byKey(const ValueKey('floating_pill_visible')), findsNothing);
    });
  });
}
