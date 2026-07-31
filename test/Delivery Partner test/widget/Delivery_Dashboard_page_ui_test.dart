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
    todayEarnings: 2450.00,
    walletBalance: 2450.00,
    todayOrdersCount: 18,
    activeOrdersCount: 2,
    workingHours: '05h 45m',
    acceptanceRate: 92,
    performanceScore: 4.8,
    partnerName: 'Ravi Kumar',
    vehicleNumber: 'TN 01 AB 1234',
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

  Widget buildPage() {
    return MaterialApp(
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
      expect(find.text('ONLINE'), findsOneWidget);
      expect(find.text('₹2450.00'), findsWidgets);
      expect(find.text('18'), findsOneWidget);
      expect(find.text('2'), findsOneWidget);
      expect(find.text('05h 45m'), findsOneWidget);
      expect(find.text('92%'), findsOneWidget);
      expect(find.text('4.8 / 5.0'), findsOneWidget);
    });

    testWidgets('renders recent activities and map preview cards', (
      tester,
    ) async {
      setDesktopSize(tester);
      await tester.pumpWidget(buildPage());
      await tester.pump();

      expect(find.text('Recent Activity'), findsOneWidget);
      expect(find.text('Order Delivered'), findsOneWidget);
      expect(find.text('Active Zone Map'), findsOneWidget);
      expect(find.text('Quick Actions'), findsOneWidget);
      expect(find.text('Today Incentive Goal'), findsOneWidget);
    });
  });
}
