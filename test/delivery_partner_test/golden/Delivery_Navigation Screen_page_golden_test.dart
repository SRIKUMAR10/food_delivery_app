import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/services.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Navigation%20Screen_page/Delivery_Navigation%20Screen_page_bloc.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Navigation%20Screen_page/Delivery_Navigation%20Screen_page_event.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Navigation%20Screen_page/Delivery_Navigation%20Screen_page_state.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Navigation%20Screen_page/Delivery_Navigation%20Screen_page_ui.dart';

import '../../font_loader_helper.dart';

class MockDeliveryNavigationBloc
    extends MockBloc<DeliveryNavigationEvent, DeliveryNavigationState>
    implements DeliveryNavigationBloc {}

void main() {
  late MockDeliveryNavigationBloc mockBloc;

  const DeliveryNavigationState loadedState = DeliveryNavigationState(
    status: DeliveryNavigationStatus.loaded,
    hasLocationPermission: true,
    gpsStatus: DeliveryGpsStatus.active,
    audioEnabled: true,
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
    mockBloc = MockDeliveryNavigationBloc();
    when(() => mockBloc.state).thenReturn(loadedState);
  });

  Widget buildPage(Size size) {
    return MaterialApp(
      home: MediaQuery(
        data: const MediaQueryData(),
        child: DeliveryNavigationScreenPage(bloc: mockBloc),
      ),
    );
  }

  group('DeliveryNavigationScreenPage Golden Tests', () {
    testWidgets('renders pixel-perfect dark navigation dashboard on desktop', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(1440, 1024);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(buildPage(const Size(1440, 1024)));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));

      expect(find.byType(DeliveryNavigationScreenPage), findsOneWidget);
      expect(find.byKey(const Key('dp_navscreen_map')), findsOneWidget);
      expect(find.byKey(const Key('dp_navscreen_order_panel')), findsOneWidget);
      expect(find.text('Live Navigation'), findsOneWidget);
      expect(find.text('Start Navigation'), findsOneWidget);
      expect(find.text('Emergency SOS'), findsOneWidget);
    });

    testWidgets('renders split map + order panel layout on tablet viewport', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(800, 1024);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(buildPage(const Size(800, 1024)));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));

      expect(find.byType(DeliveryNavigationScreenPage), findsOneWidget);
      expect(find.byKey(const Key('dp_navscreen_map')), findsOneWidget);
      expect(find.byKey(const Key('dp_navscreen_order_panel')), findsOneWidget);
      expect(find.text('Live Traffic'), findsOneWidget);
    });

    testWidgets('renders stacked map and panel layout on mobile viewport', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(buildPage(const Size(390, 844)));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));

      expect(find.byType(DeliveryNavigationScreenPage), findsOneWidget);
      expect(find.byKey(const Key('dp_navscreen_map')), findsOneWidget);
      expect(find.byKey(const Key('dp_navscreen_sos_button')), findsOneWidget);
      expect(find.text('Emergency SOS'), findsOneWidget);
      expect(find.textContaining('Kuruppanaickenpalayam'), findsWidgets);
      expect(tester.takeException(), isNull);
    });

    testWidgets('matches dark theme color palette on desktop', (tester) async {
      tester.view.physicalSize = const Size(1280, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(buildPage(const Size(1280, 900)));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));

      final scaffold = tester.widget<Scaffold>(find.byType(Scaffold));
      expect(scaffold.backgroundColor, const Color(0xFF060B11));
    });
  });
}
