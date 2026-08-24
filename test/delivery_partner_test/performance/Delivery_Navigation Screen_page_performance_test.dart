import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/services.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Navigation%20Screen_page/Delivery_Navigation%20Screen_page_repository.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Navigation%20Screen_page/Delivery_Navigation%20Screen_page_service.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Navigation%20Screen_page/Delivery_Navigation%20Screen_page_ui.dart';

import '../../font_loader_helper.dart';

class MockDeliveryNavigationRepository extends Mock
    implements DeliveryNavigationRepositoryBase {}

class MockDeliveryNavigationService extends Mock
    implements DeliveryNavigationServiceBase {}

void main() {
  late MockDeliveryNavigationRepository mockRepository;
  late MockDeliveryNavigationService mockService;

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
    mockRepository = MockDeliveryNavigationRepository();
    mockService = MockDeliveryNavigationService();

    when(() => mockService.checkConnectivity()).thenAnswer((_) async => true);
    when(() => mockService.checkGpsStatus()).thenAnswer((_) async => true);
    when(() => mockService.streamLiveLocation(highAccuracy: any(named: 'highAccuracy')))
        .thenAnswer((_) => const Stream.empty());
    when(() => mockService.streamLiveLocation()).thenAnswer((_) => const Stream.empty());
    when(
      () => mockService.checkLocationPermission(),
    ).thenAnswer((_) async => true);
    when(
      () => mockRepository.fetchOrderSummary(),
    ).thenAnswer((_) async => DeliveryNavigationRepository.defaultOrder);
    when(
      () => mockRepository.fetchPickup(),
    ).thenAnswer((_) async => DeliveryNavigationRepository.defaultPickup);
    when(
      () => mockRepository.fetchDrop(),
    ).thenAnswer((_) async => DeliveryNavigationRepository.defaultDrop);
    when(() => mockRepository.fetchActiveOrderData()).thenAnswer((_) async => null);
    when(() => mockRepository.fetchPartnerProfile()).thenAnswer((_) async => null);
    when(() => mockRepository.watchActiveOrder()).thenAnswer((_) => const Stream.empty());
    when(() => mockRepository.watchPartnerProfile()).thenAnswer((_) => const Stream.empty());
    when(() => mockRepository.fetchNearbySellers()).thenAnswer((_) async => const []);
    when(() => mockRepository.watchNearbySellers()).thenAnswer((_) => const Stream.empty());
    when(() => mockService.getCurrentLocation(highAccuracy: any(named: 'highAccuracy'))).thenAnswer((_) async => null);
    when(() => mockService.fetchDemandZones()).thenAnswer((_) async => const []);
    when(() => mockRepository.getAudioEnabled()).thenAnswer((_) async => false);
    when(
      () => mockRepository.getEmergencyMode(),
    ).thenAnswer((_) async => false);
    when(() => mockRepository.getLocaleCode()).thenAnswer((_) async => 'en');
    when(() => mockRepository.saveAudioEnabled(any())).thenAnswer((_) async {});
    when(
      () => mockRepository.saveEmergencyMode(any()),
    ).thenAnswer((_) async {});
    when(
      () => mockService.simulateLiveLocation(),
    ).thenAnswer((_) => const Stream<double>.empty());
    SharedPreferences.setMockInitialValues({});
  });

  void setDesktopSize(WidgetTester tester) {
    tester.view.physicalSize = const Size(1280, 1000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
  }

  Widget buildPage() {
    return MaterialApp(
      home: DeliveryNavigationScreenPage(
        repository: mockRepository,
        service: mockService,
      ),
    );
  }

  group('DeliveryNavigationScreenPage Performance & Memory Tests', () {
    testWidgets(
      'renders UI within frame threshold and disposes without leaks',
      (tester) async {
        setDesktopSize(tester);

        final Stopwatch stopwatch = Stopwatch()..start();
        await tester.pumpWidget(buildPage());
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 400));
        stopwatch.stop();

        expect(stopwatch.elapsedMilliseconds, lessThan(3000));
        expect(find.text('Live Navigation'), findsOneWidget);

        await tester.pumpWidget(
          const MaterialApp(home: Scaffold(body: SizedBox())),
        );
        await tester.pump(const Duration(milliseconds: 100));
        expect(find.byType(DeliveryNavigationScreenPage), findsNothing);
      },
    );

    testWidgets('handles rapid control interactions without frame errors', (
      tester,
    ) async {
      setDesktopSize(tester);

      await tester.pumpWidget(buildPage());
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));

      for (var i = 0; i < 5; i++) {
        await tester.tap(
          find.byKey(const Key('dp_navscreen_zoom_in')),
          warnIfMissed: false,
        );
        await tester.pump();
        await tester.tap(
          find.byKey(const Key('dp_navscreen_zoom_out')),
          warnIfMissed: false,
        );
        await tester.pump();
        await tester.tap(
          find.byKey(const Key('dp_navscreen_recenter_button')),
          warnIfMissed: false,
        );
        await tester.pump();
        await tester.tap(
          find.byKey(const Key('dp_navscreen_audio_toggle')),
          warnIfMissed: false,
        );
        await tester.pump();
      }

      expect(tester.takeException(), isNull);
      expect(find.byKey(const Key('dp_navscreen_map')), findsOneWidget);
    });

    testWidgets('rebuilds quickly when toggling between navigation states', (
      tester,
    ) async {
      setDesktopSize(tester);

      await tester.pumpWidget(buildPage());
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));

      final Stopwatch switchStopwatch = Stopwatch()..start();
      await tester.tap(
        find.byKey(const Key('dp_navscreen_start_button')),
        warnIfMissed: false,
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      switchStopwatch.stop();

      expect(switchStopwatch.elapsedMilliseconds, lessThan(1500));
      expect(find.text('Complete Delivery'), findsOneWidget);
    });
  });
}
