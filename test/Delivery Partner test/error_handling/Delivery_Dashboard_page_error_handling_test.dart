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

class MockDeliveryDashboardRepository extends Mock
    implements DeliveryDashboardRepositoryBase {}

class MockDeliveryDashboardService extends Mock
    implements DeliveryDashboardServiceBase {}

void main() {
  late MockDeliveryDashboardRepository mockRepository;
  late MockDeliveryDashboardService mockService;

  const loadedState = DeliveryDashboardState(
    status: DeliveryDashboardStatus.loaded,
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

  setUp(() async {
    SharedPreferences.setMockInitialValues({});

    mockRepository = MockDeliveryDashboardRepository();
    mockService = MockDeliveryDashboardService();

    when(
      () => mockRepository.loadDashboardData(),
    ).thenAnswer((_) async => loadedState);
    when(() => mockRepository.getOnlineStatus()).thenAnswer((_) async => true);
    when(
      () => mockRepository.saveOnlineStatus(any()),
    ).thenAnswer((_) async => true);
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
          repository: mockRepository,
          service: mockService,
        ),
      ),
    );
  }

  group('DeliveryDashboardPage Error Handling Tests', () {
    testWidgets('shows fallback error UI when initialization fails', (
      tester,
    ) async {
      setDesktopSize(tester);
      when(
        () => mockRepository.loadDashboardData(),
      ).thenThrow(Exception('Server unreachable'));

      await tester.pumpWidget(buildPage());
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.byKey(const Key('dp_dashboard_error')), findsOneWidget);
      expect(find.textContaining('Server unreachable'), findsWidgets);
      expect(find.byKey(const Key('dp_dashboard_retry')), findsOneWidget);
    });

    testWidgets('retry recovers and loads the dashboard', (tester) async {
      setDesktopSize(tester);
      var calls = 0;
      when(() => mockRepository.loadDashboardData()).thenAnswer((_) async {
        calls++;
        if (calls == 1) {
          throw Exception('Temporary failure');
        }
        return loadedState;
      });

      await tester.pumpWidget(buildPage());
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.byKey(const Key('dp_dashboard_error')), findsOneWidget);

      await tester.tap(find.byKey(const Key('dp_dashboard_retry')));
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
      var fetchCalls = 0;
      when(() => mockRepository.loadDashboardData()).thenAnswer((_) async {
        fetchCalls++;
        if (fetchCalls == 1) {
          return const DeliveryDashboardState(
            status: DeliveryDashboardStatus.empty,
          );
        }
        return loadedState;
      });

      await tester.pumpWidget(buildPage());
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.byKey(const Key('dp_dashboard_empty')), findsOneWidget);

      await tester.tap(find.byKey(const Key('dp_dashboard_refresh')));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      expect(find.byKey(const Key('dp_dashboard_empty')), findsNothing);
      expect(find.text('ONLINE'), findsOneWidget);
    });
  });
}
