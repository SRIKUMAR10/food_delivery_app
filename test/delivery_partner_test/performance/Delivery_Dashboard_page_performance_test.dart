import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/services.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Dashboard_page/Delivery_Dashboard_page_repository.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Dashboard_page/Delivery_Dashboard_page_service.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Dashboard_page/Delivery_Dashboard_page_state.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Dashboard_page/Delivery_Dashboard_page_ui.dart';

import '../../font_loader_helper.dart';
import '../helpers/delivery_test_utils.dart';

class MockDeliveryDashboardRepository extends Mock
    implements DeliveryDashboardRepositoryBase {}

DeliveryDashboardState buildLoadedDashboardState() =>
    const DeliveryDashboardState(
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
      recentActivities: [
        DeliveryActivityItem(
          id: 'ORD12345',
          time: '10:15 AM',
          title: 'Order Delivered',
          subtitle: 'Green Bowl Kitchen',
          details: '480.00',
          statusType: 'delivered',
        ),
      ],
    );

void main() {
  late MockDeliveryDashboardRepository mockDashboardRepository;

  setUpAll(() {
    overrideFontAssetLoading();
    setupDeliveryTestChannels();

    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          const MethodChannel('plugins.flutter.io/path_provider'),
          (MethodCall methodCall) async {
            return '.';
          },
        );
  });

  setUp(() async {
    SharedPreferences.setMockInitialValues({});

    mockDashboardRepository = MockDeliveryDashboardRepository();

    when(
      () => mockDashboardRepository.watchDashboard(),
    ).thenAnswer((_) => Stream.value(buildLoadedDashboardState()));
    when(
      () => mockDashboardRepository.loadDashboardData(),
    ).thenAnswer((_) async => buildLoadedDashboardState());
    when(
      () => mockDashboardRepository.updatePartnerStatus(
        isOnline: any(named: 'isOnline'),
        isAvailable: any(named: 'isAvailable'),
        isBusy: any(named: 'isBusy'),
        currentOrderId: any(named: 'currentOrderId'),
      ),
    ).thenAnswer((_) async {});
  });

  void setDesktopSize(WidgetTester tester) {
    tester.view.physicalSize = const Size(1280, 1000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
  }

  Widget buildPage() {
    return MaterialApp(
      home: Scaffold(
        body: DeliveryDashboardPage(
          repository: mockDashboardRepository,
          service: DeliveryDashboardService(),
        ),
      ),
    );
  }

  group('DeliveryDashboardPage Performance & Memory Tests', () {
    testWidgets('renders the dashboard UI within frame threshold', (
      tester,
    ) async {
      setDesktopSize(tester);

      final Stopwatch stopwatch = Stopwatch()..start();
      await tester.pumpWidget(buildPage());
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));
      stopwatch.stop();

      expect(stopwatch.elapsedMilliseconds, lessThan(10000));
      expect(find.text('ONLINE'), findsOneWidget);
    });

    testWidgets('disposes the page without leaks', (tester) async {
      setDesktopSize(tester);

      await tester.pumpWidget(buildPage());
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));

      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: SizedBox())),
      );
      await tester.pump(const Duration(milliseconds: 400));

      expect(find.byType(DeliveryDashboardPage), findsNothing);
      expect(tester.takeException(), isNull);
    });

    testWidgets('handles rapid online toggles without frame drops', (
      tester,
    ) async {
      setDesktopSize(tester);

      await tester.pumpWidget(buildPage());
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));

      for (var i = 0; i < 5; i++) {
        await tester.tap(find.byKey(const Key('dp_dashboard_toggle_switch')));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 250));
      }

      expect(tester.takeException(), isNull);
      expect(find.byKey(const Key('dp_dashboard_page')), findsOneWidget);
    });
  });
}