import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/services.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Dashboard_page/Delivery_Dashboard_page_bloc.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Dashboard_page/Delivery_Dashboard_page_event.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Dashboard_page/Delivery_Dashboard_page_state.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Dashboard_page/Delivery_Dashboard_page_service.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Dashboard_page/Delivery_Dashboard_page_ui.dart';

import '../../font_loader_helper.dart';

class MockDeliveryDashboardPageBloc
    extends MockBloc<DeliveryDashboardPageEvent, DeliveryDashboardState>
    implements DeliveryDashboardPageBloc {}

void main() {
  late MockDeliveryDashboardPageBloc mockBloc;

  const DeliveryDashboardState loadedState = DeliveryDashboardState(
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

  setUp(() {
    mockBloc = MockDeliveryDashboardPageBloc();
    when(() => mockBloc.state).thenReturn(loadedState);
  });

  void setDesktopSize(WidgetTester tester) {
    tester.view.physicalSize = const Size(1280, 1000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
  }

  group('DeliveryDashboardPage Permission Tests', () {
    test('service exposes online status updates safely', () async {
      final service = DeliveryDashboardService();
      expect(await service.updateOnlineStatus(true), isTrue);
      expect(await service.updateOnlineStatus(false), isFalse);
    });

    test(
      'service metric payload does not expose raw environment secrets',
      () async {
        final service = DeliveryDashboardService();
        final metrics = await service.fetchDashboardMetrics();
        final raw = metrics.toString();

        expect(
          raw.contains(
            RegExp(r'(token|password|passwd|secret)', caseSensitive: false),
          ),
          isFalse,
        );
      },
    );

    testWidgets('renders online status card when running', (tester) async {
      setDesktopSize(tester);
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: DeliveryDashboardPage(bloc: mockBloc)),
        ),
      );
      await tester.pump();

      expect(find.byKey(const Key('dp_dashboard_online_card')), findsOneWidget);
      expect(
        find.byKey(const Key('dp_dashboard_toggle_switch')),
        findsOneWidget,
      );
      expect(find.text('ONLINE'), findsOneWidget);
    });

    testWidgets('online toggle is reachable and tappable', (tester) async {
      setDesktopSize(tester);
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: DeliveryDashboardPage(bloc: mockBloc)),
        ),
      );
      await tester.pump();

      final toggle = find.byKey(const Key('dp_dashboard_toggle_switch'));
      expect(toggle, findsOneWidget);
      await tester.tap(toggle);
      await tester.pump();

      verify(
        () => mockBloc.add(const DeliveryDashboardToggleOnlineEvent(false)),
      ).called(1);
    });
  });
}
