import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Navigation%20Screen_page/Delivery_Navigation%20Screen_page_bloc.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Navigation%20Screen_page/Delivery_Navigation%20Screen_page_state.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Navigation%20Screen_page/Delivery_Navigation%20Screen_page_repository.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Navigation%20Screen_page/Delivery_Navigation%20Screen_page_service.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Navigation%20Screen_page/Delivery_Navigation%20Screen_page_ui.dart';

import '../../font_loader_helper.dart';

class _FakeNavigationRepository implements DeliveryNavigationRepositoryBase {
  bool audioEnabled = false;
  bool emergencyMode = false;
  bool hasLocationPermission = true;
  String localeCode = 'en';

  @override
  Future<DeliveryNavigationOrderSummary> fetchOrderSummary() async {
    return DeliveryNavigationRepository.defaultOrder;
  }

  @override
  Future<DeliveryNavigationRoutePoint> fetchPickup() async {
    return DeliveryNavigationRepository.defaultPickup;
  }

  @override
  Future<DeliveryNavigationRoutePoint> fetchDrop() async {
    return DeliveryNavigationRepository.defaultDrop;
  }

  @override
  Future<Map<String, dynamic>?> fetchActiveOrderData({String? orderId}) async => null;

  @override
  Stream<Map<String, dynamic>?> watchActiveOrder() =>
      const Stream<Map<String, dynamic>?>.empty();

  @override
  Future<Map<String, dynamic>?> fetchPartnerProfile() async => null;

  @override
  Stream<Map<String, dynamic>?> watchPartnerProfile() =>
      const Stream<Map<String, dynamic>?>.empty();

  @override
  Future<Map<String, dynamic>> collectCodCash({
    required String orderId,
    required double amountReceived,
  }) async {
    return {
      'success': true,
      'changeAmount': 0.0,
      'collectedAmount': amountReceived,
    };
  }

  @override
  Future<bool> getAudioEnabled() async => audioEnabled;

  @override
  Future<void> saveAudioEnabled(bool enabled) async {
    audioEnabled = enabled;
  }

  @override
  Future<bool> getEmergencyMode() async => emergencyMode;

  @override
  Future<void> saveEmergencyMode(bool active) async {
    emergencyMode = active;
  }

  @override
  Future<bool> getHasLocationPermission() async => hasLocationPermission;

  @override
  Future<void> saveHasLocationPermission(bool value) async {
    hasLocationPermission = value;
  }

  @override
  Future<String> getLocaleCode() async => localeCode;

  @override
  Future<void> saveLocaleCode(String value) async {
    localeCode = value;
  }
}

class _FakeNavigationService implements DeliveryNavigationServiceBase {
  bool connectivity = true;

  @override
  Future<bool> checkConnectivity() async => connectivity;

  @override
  Future<bool> checkLocationPermission() async => true;

  @override
  Future<bool> requestLocationPermission() async => true;

  @override
  Future<bool> checkGpsStatus() async => true;

  @override
  Map<String, String> getEnvironmentVariables() {
    return {
      'BASE_URL': 'https://api.fooddelivery.example.com',
      'API_KEY': 'env_api_key_secure',
      'KEY_SECRET': 'env_secret_key_secure',
      'MAPS_API_KEY': 'env_maps_api_key_secure',
    };
  }

  @override
  String? sanitizeInput(String? input) => input;

  @override
  double calculateEstimatedEta(double distanceKm) => distanceKm * 3;

  @override
  double calculateDistanceKm(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) =>
      1.0;

  @override
  double calculateEtaMinutes(double distanceKm, double currentSpeedKmh) =>
      distanceKm * 3;

  @override
  double calculateBearing(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) =>
      0.0;

  @override
  Stream<Map<String, dynamic>> streamLiveLocation({bool highAccuracy = true}) =>
      const Stream<Map<String, dynamic>>.empty();

  @override
  Stream<double> simulateLiveLocation() => const Stream<double>.empty();

  @override
  Future<String?> currentDriverId() async => null;

  @override
  Future<void> updateDriverLocation({
    required double latitude,
    required double longitude,
  }) async {}

  @override
  Future<void> updatePartnerLocation({
    required double latitude,
    required double longitude,
  }) async {}

  @override
  Future<void> updateLiveLocation({
    required String orderId,
    required double lat,
    required double lng,
    double? heading,
    double? speed,
    required String stage,
  }) async {}

  @override
  Future<void> updateOrderStatus(String orderId, String status) async {}

  @override
  Future<Map<String, dynamic>?> fetchActiveOrder({String? orderId}) async => null;

  @override
  Future<List<Map<String, dynamic>>?> fetchDemandZones() async => null;

  @override
  Stream<Map<String, dynamic>?> watchActiveOrder(String driverId) =>
      const Stream<Map<String, dynamic>?>.empty();

  @override
  Future<Map<String, dynamic>?> fetchPartnerProfile() async => null;

  @override
  Stream<Map<String, dynamic>?> watchPartnerProfile() =>
      const Stream<Map<String, dynamic>?>.empty();

  @override
  Future<Map<String, dynamic>> collectCodCash(
    String orderId, {
    required double amountReceived,
  }) async {
    return {
      'success': true,
      'changeAmount': 0.0,
      'collectedAmount': amountReceived,
    };
  }
}

void main() {
  late _FakeNavigationRepository repository;
  late _FakeNavigationService service;

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
    SharedPreferences.setMockInitialValues({});
    repository = _FakeNavigationRepository();
    service = _FakeNavigationService();
  });

  void setDesktopSize(WidgetTester tester) {
    tester.view.physicalSize = const Size(1280, 1000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
  }

  DeliveryNavigationBloc blocOf(WidgetTester tester) {
    final element = tester.element(find.byKey(const Key('dp_navscreen_page')));
    return element.read<DeliveryNavigationBloc>();
  }

  Widget buildPage() {
    return MaterialApp(
      home: DeliveryNavigationScreenPage(
        repository: repository,
        service: service,
      ),
    );
  }

  group('DeliveryNavigationScreenPage Integration Flow Tests', () {
    testWidgets('loads real order data through BLoC and renders dashboard', (
      tester,
    ) async {
      setDesktopSize(tester);

      await tester.pumpWidget(buildPage());
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(blocOf(tester).state.status, DeliveryNavigationStatus.loaded);
      expect(find.textContaining('#ORD-789456'), findsOneWidget);
      expect(find.text('Live Navigation'), findsOneWidget);
      expect(find.text('Start Navigation'), findsOneWidget);
    });

    testWidgets('completes start, exit and SOS lifecycle with state changes', (
      tester,
    ) async {
      setDesktopSize(tester);

      await tester.pumpWidget(buildPage());
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      await tester.tap(
        find.byKey(const Key('dp_navscreen_start_button')),
        warnIfMissed: false,
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      expect(blocOf(tester).state.status, DeliveryNavigationStatus.navigating);
      expect(blocOf(tester).state.audioEnabled, isTrue);
      expect(find.text('Complete Delivery'), findsOneWidget);

      await tester.tap(
        find.byKey(const Key('dp_navscreen_sos_button')),
        warnIfMissed: false,
      );
      await tester.pump();

      expect(blocOf(tester).state.emergencyMode, isTrue);
      expect(
        find.text('Emergency alert sent. Nearest support team notified.'),
        findsOneWidget,
      );

      // Dismiss the floating snackbar so the exit control is tappable.
      tester
          .state<ScaffoldMessengerState>(find.byType(ScaffoldMessenger))
          .hideCurrentSnackBar();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      expect(
        find.text('Emergency alert sent. Nearest support team notified.'),
        findsNothing,
      );

      await tester.tap(
        find.byKey(const Key('dp_navscreen_exit_button')),
        warnIfMissed: false,
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      expect(blocOf(tester).state.status, DeliveryNavigationStatus.loaded);
      expect(blocOf(tester).state.emergencyMode, isFalse);
      expect(find.text('Start Navigation'), findsOneWidget);
    });

    testWidgets('toggles audio guidance and persists across lifecycle', (
      tester,
    ) async {
      setDesktopSize(tester);

      await tester.pumpWidget(buildPage());
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(blocOf(tester).state.audioEnabled, isFalse);

      await tester.tap(
        find.byKey(const Key('dp_navscreen_audio_toggle')),
        warnIfMissed: false,
      );
      await tester.pump();

      expect(blocOf(tester).state.audioEnabled, isTrue);
      expect(repository.audioEnabled, isTrue);
    });

    testWidgets('shows offline banner and limits navigation when offline', (
      tester,
    ) async {
      setDesktopSize(tester);
      service.connectivity = false;

      await tester.pumpWidget(buildPage());
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(blocOf(tester).state.isOffline, isTrue);
      expect(
        find.byKey(const Key('dp_navscreen_offline_banner')),
        findsOneWidget,
      );
    });
  });
}
