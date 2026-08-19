import 'dart:async';

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

void main() {
  late MockDeliveryDashboardPageBloc mockBloc;
  late DeliveryDashboardState currentState;
  late StreamController<DeliveryDashboardState> stateController;

  const DeliveryDashboardState errorState = DeliveryDashboardState(
    status: DeliveryDashboardStatus.error,
    errorMessage: 'Server unreachable',
  );

  const DeliveryDashboardState emptyState = DeliveryDashboardState(
    status: DeliveryDashboardStatus.empty,
  );

  const DeliveryDashboardState loadedState = DeliveryDashboardState(
    status: DeliveryDashboardStatus.loaded,
    isOnline: true,
    isAvailable: true,
    partnerStatus: DeliveryPartnerStatusType.online,
    partnerName: 'Ravi Kumar',
    walletBalance: 2450.0,
    todayEarnings: 2450.0,
    todayTotalDeliveries: 4,
    completedDeliveriesCount: 3,
    pendingDeliveriesCount: 1,
    workingHours: '5h 45m',
    onlineHours: '5h 45m',
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
    stateController = StreamController<DeliveryDashboardState>.broadcast();
    currentState = const DeliveryDashboardState();
    when(() => mockBloc.state).thenAnswer((_) => currentState);
    when(() => mockBloc.stream).thenAnswer((_) => stateController.stream);
  });

  tearDown(() async {
    await stateController.close();
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

  group('DeliveryDashboardPage Error Handling Tests', () {
    testWidgets('shows fallback error UI when initialization fails', (
      tester,
    ) async {
      setDesktopSize(tester);
      currentState = errorState;

      await tester.pumpWidget(buildPage());
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.byKey(const Key('dp_dashboard_error')), findsOneWidget);
      expect(find.textContaining('Server unreachable'), findsWidgets);
      expect(find.byKey(const Key('dp_dashboard_retry')), findsOneWidget);
    });

    testWidgets('retry recovers and loads the dashboard', (tester) async {
      setDesktopSize(tester);
      currentState = errorState;

      await tester.pumpWidget(buildPage());
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.byKey(const Key('dp_dashboard_error')), findsOneWidget);

      await tester.tap(find.byKey(const Key('dp_dashboard_retry')));
      await tester.pump();

      verify(
        () => mockBloc.add(const DeliveryDashboardInitEvent()),
      ).called(1);

      currentState = loadedState;
      stateController.add(loadedState);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      expect(find.byKey(const Key('dp_dashboard_error')), findsNothing);
      expect(find.text('ONLINE'), findsOneWidget);
      expect(find.text('₹2450.00'), findsWidgets);
    });

    testWidgets('shows empty state and refresh recovers dashboard', (
      tester,
    ) async {
      setDesktopSize(tester);
      currentState = emptyState;

      await tester.pumpWidget(buildPage());
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.byKey(const Key('dp_dashboard_empty')), findsOneWidget);

      await tester.tap(find.byKey(const Key('dp_dashboard_refresh')));
      await tester.pump();

      verify(
        () => mockBloc.add(const DeliveryDashboardRefreshEvent()),
      ).called(1);

      currentState = loadedState;
      stateController.add(loadedState);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      expect(find.byKey(const Key('dp_dashboard_empty')), findsNothing);
      expect(find.text('ONLINE'), findsOneWidget);
    });
  });
}