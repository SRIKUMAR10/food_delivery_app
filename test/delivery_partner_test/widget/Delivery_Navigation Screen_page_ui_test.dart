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
    audioEnabled: false,
    emergencyMode: false,
    isOffline: false,
    gpsStatus: DeliveryGpsStatus.disabled,
    partnerName: 'Dinesh Kumar',
  );

  const DeliveryNavigationState navigatingState = DeliveryNavigationState(
    status: DeliveryNavigationStatus.navigating,
    hasLocationPermission: true,
    audioEnabled: true,
    gpsStatus: DeliveryGpsStatus.disabled,
    partnerName: 'Dinesh Kumar',
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

  void setDesktopSize(WidgetTester tester) {
    tester.view.physicalSize = const Size(1280, 1000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
  }

  void setMobileSize(WidgetTester tester) {
    tester.view.physicalSize = const Size(430, 844);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
  }

  Widget buildPage() {
    return MaterialApp(home: DeliveryNavigationScreenPage(bloc: mockBloc));
  }

  group('DeliveryNavigationScreenPage Widget Tests', () {
    testWidgets(
      'renders navigation dashboard with all key elements on desktop',
      (tester) async {
        setDesktopSize(tester);
        await tester.pumpWidget(buildPage());
        await tester.pump();

        expect(find.text('Live Navigation'), findsOneWidget);
        expect(find.text('Dashboard / Navigate'), findsOneWidget);
        expect(find.text('Dinesh Kumar'), findsOneWidget);
        expect(find.text('Delivery Partner'), findsOneWidget);

        expect(find.byKey(const Key('dp_navscreen_map')), findsOneWidget);
        expect(find.byKey(const Key('dp_navscreen_turn_card')), findsOneWidget);
        expect(find.text('250 m'), findsOneWidget);
        expect(find.text('Turn Left onto 2nd Avenue'), findsOneWidget);

        expect(
          find.byKey(const Key('dp_navscreen_order_panel')),
          findsOneWidget,
        );
        expect(find.textContaining('#ORD-789456'), findsOneWidget);
        expect(find.text('On the Way'), findsOneWidget);
        expect(find.text('Reliance Digital Store'), findsWidgets);
        expect(find.text('Arun Kumar'), findsWidgets);
        expect(find.text('18 min'), findsOneWidget);
        expect(find.text('6.2 km'), findsOneWidget);
        expect(find.text('Live Traffic'), findsOneWidget);

        expect(
          find.byKey(const Key('dp_navscreen_sos_button')),
          findsOneWidget,
        );
        expect(
          find.byKey(const Key('dp_navscreen_start_button')),
          findsOneWidget,
        );
        expect(
          find.byKey(const Key('dp_navscreen_exit_button')),
          findsOneWidget,
        );
        expect(
          find.byKey(const Key('dp_navscreen_location_badge')),
          findsOneWidget,
        );
        expect(find.text('Nungambakkam High Rd, Chennai'), findsOneWidget);

        expect(
          find.byKey(const Key('dp_navscreen_pickup_marker')),
          findsOneWidget,
        );
        expect(
          find.byKey(const Key('dp_navscreen_drop_marker')),
          findsOneWidget,
        );
        expect(
          find.byKey(const Key('dp_navscreen_recenter_button')),
          findsOneWidget,
        );
      },
    );

    testWidgets('switches primary action label based on navigation state', (
      tester,
    ) async {
      setDesktopSize(tester);
      when(() => mockBloc.state).thenReturn(navigatingState);
      whenListen(
        mockBloc,
        Stream<DeliveryNavigationState>.fromIterable([navigatingState]),
      );
      await tester.pumpWidget(buildPage());
      await tester.pump();
      await tester.pump();
      expect(find.text('Follow Route'), findsNothing);
      expect(find.text('Complete Delivery'), findsOneWidget);
      expect(find.text('Start Navigation'), findsNothing);
    });

    testWidgets(
      'dispatches start navigation event when primary button tapped',
      (tester) async {
        setDesktopSize(tester);
        await tester.pumpWidget(buildPage());
        await tester.pump();

        await tester.tap(
          find.byKey(const Key('dp_navscreen_start_button')),
          warnIfMissed: false,
        );
        await tester.pump();

        verify(
          () => mockBloc.add(const DeliveryNavigationStartNavigationEvent()),
        ).called(1);
      },
    );

    testWidgets('dispatches exit navigation event when exit button tapped', (
      tester,
    ) async {
      setDesktopSize(tester);
      when(() => mockBloc.state).thenReturn(navigatingState);
      await tester.pumpWidget(buildPage());
      await tester.pump();

      await tester.tap(
        find.byKey(const Key('dp_navscreen_exit_button')),
        warnIfMissed: false,
      );
      await tester.pump();

      verify(
        () => mockBloc.add(const DeliveryNavigationExitNavigationEvent()),
      ).called(1);
    });

    testWidgets('dispatches SOS event and shows alert snackbar', (
      tester,
    ) async {
      setDesktopSize(tester);
      await tester.pumpWidget(buildPage());
      await tester.pump();

      await tester.tap(
        find.byKey(const Key('dp_navscreen_sos_button')),
        warnIfMissed: false,
      );
      await tester.pump();

      verify(
        () => mockBloc.add(const DeliveryNavigationSOSClickedEvent()),
      ).called(1);
      expect(
        find.text('Emergency alert sent. Nearest support team notified.'),
        findsOneWidget,
      );
    });

    testWidgets('dispatches audio toggle event from top bar', (tester) async {
      setDesktopSize(tester);
      await tester.pumpWidget(buildPage());
      await tester.pump();

      await tester.tap(
        find.byKey(const Key('dp_navscreen_audio_toggle')),
        warnIfMissed: false,
      );
      await tester.pump();

      verify(
        () => mockBloc.add(const DeliveryNavigationToggleAudioEvent()),
      ).called(1);
    });

    testWidgets('dispatches recenter event from map control', (tester) async {
      setDesktopSize(tester);
      await tester.pumpWidget(buildPage());
      await tester.pump();

      await tester.tap(
        find.byKey(const Key('dp_navscreen_recenter_button')),
        warnIfMissed: false,
      );
      await tester.pump();

      verify(
        () => mockBloc.add(const DeliveryNavigationRecenterMapEvent()),
      ).called(1);
    });

    testWidgets('shows calling snackbar when customer contact tapped', (
      tester,
    ) async {
      setDesktopSize(tester);
      await tester.pumpWidget(buildPage());
      await tester.pump();

      await tester.tap(
        find.byKey(const Key('dp_navscreen_contact_button')),
        warnIfMissed: false,
      );
      await tester.pump();

      expect(find.text('Calling customer...'), findsOneWidget);
    });

    testWidgets('shows offline banner when connectivity is lost', (
      tester,
    ) async {
      setDesktopSize(tester);
      when(() => mockBloc.state).thenReturn(
        const DeliveryNavigationState(
          status: DeliveryNavigationStatus.loaded,
          isOffline: true,
          gpsStatus: DeliveryGpsStatus.disabled,
        ),
      );
      await tester.pumpWidget(buildPage());
      await tester.pump();

      expect(
        find.byKey(const Key('dp_navscreen_offline_banner')),
        findsOneWidget,
      );
      expect(
        find.text('You are offline. Live navigation may be limited.'),
        findsOneWidget,
      );
    });

    testWidgets('renders skeleton loader during loading state', (tester) async {
      setDesktopSize(tester);
      when(() => mockBloc.state).thenReturn(
        const DeliveryNavigationState(status: DeliveryNavigationStatus.loading),
      );
      await tester.pumpWidget(buildPage());
      await tester.pump();

      expect(find.byKey(const Key('dp_navscreen_skeleton')), findsOneWidget);
      expect(find.text('Start Navigation'), findsNothing);
    });

    testWidgets('renders error state and retries with refresh event', (
      tester,
    ) async {
      setDesktopSize(tester);
      when(() => mockBloc.state).thenReturn(
        const DeliveryNavigationState(
          status: DeliveryNavigationStatus.error,
          errorMessage: 'Route fetch failed',
        ),
      );
      await tester.pumpWidget(buildPage());
      await tester.pump();

      expect(find.byKey(const Key('dp_navscreen_error')), findsOneWidget);
      expect(find.text('Route fetch failed'), findsOneWidget);

      await tester.tap(find.text('Retry'), warnIfMissed: false);
      await tester.pump();

      verify(
        () => mockBloc.add(const DeliveryNavigationRefreshEvent()),
      ).called(1);
    });

    testWidgets('renders empty state when no active delivery', (tester) async {
      setDesktopSize(tester);
      when(() => mockBloc.state).thenReturn(
        const DeliveryNavigationState(status: DeliveryNavigationStatus.empty),
      );
      await tester.pumpWidget(buildPage());
      await tester.pump();

      expect(find.byKey(const Key('dp_navscreen_empty')), findsOneWidget);
      expect(find.text('No Active Delivery'), findsOneWidget);
      expect(find.text('Retry'), findsOneWidget);
    });

    testWidgets('renders mobile layout with bottom action controls', (
      tester,
    ) async {
      setMobileSize(tester);
      await tester.pumpWidget(buildPage());
      await tester.pump();

      expect(find.text('Live Navigation'), findsOneWidget);
      expect(find.byKey(const Key('dp_navscreen_sos_button')), findsOneWidget);
      expect(
        find.byKey(const Key('dp_navscreen_start_button')),
        findsOneWidget,
      );
      expect(find.byKey(const Key('dp_navscreen_exit_button')), findsOneWidget);
      expect(find.text('Emergency SOS'), findsOneWidget);
      expect(find.text('Start Navigation'), findsOneWidget);
      expect(find.text('Exit Navigation'), findsOneWidget);
      expect(find.text('Nungambakkam High Rd, Chennai'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('dispatches map toggle event from top bar', (tester) async {
      setDesktopSize(tester);
      await tester.pumpWidget(buildPage());
      await tester.pump();

      await tester.tap(
        find.byKey(const Key('dp_navscreen_map_toggle')),
        warnIfMissed: false,
      );
      await tester.pump();

      verify(
        () => mockBloc.add(const DeliveryNavigationToggleMapEvent()),
      ).called(1);
    });

    testWidgets('dispatches map toggle event from map close button', (
      tester,
    ) async {
      setDesktopSize(tester);
      await tester.pumpWidget(buildPage());
      await tester.pump();

      await tester.tap(
        find.byKey(const Key('dp_navscreen_close_map')),
        warnIfMissed: false,
      );
      await tester.pump();

      verify(
        () => mockBloc.add(const DeliveryNavigationToggleMapEvent()),
      ).called(1);
    });
  });
}
