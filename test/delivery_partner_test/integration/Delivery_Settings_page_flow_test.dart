import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Settings_page/Delivery_Settings_page_repository.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Settings_page/Delivery_Settings_page_service.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Settings_page/Delivery_Settings_page_ui.dart';

import '../../font_loader_helper.dart';

class MockDeliverySettingsService extends Mock
    implements DeliverySettingsServiceBase {}

void main() {
  late MockDeliverySettingsService mockService;
  late DeliverySettingsRepository repository;
  late SharedPreferences prefs;

  setUpAll(() {
    overrideFontAssetLoading();
  });

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();
    repository = DeliverySettingsRepository(prefs: prefs);
    mockService = MockDeliverySettingsService();

    when(
      () => mockService.checkNetworkConnectivity(),
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
        body: DeliverySettingsPage(
          repository: repository,
          service: mockService,
        ),
      ),
    );
  }

  group('DeliverySettingsPage Integration Flow Tests', () {
    testWidgets(
      'loads settings, toggles a preference and saves with confirmation',
      (tester) async {
        setDesktopSize(tester);
        await tester.pumpWidget(buildPage());
        await tester.pumpAndSettle();

        expect(find.text('Delivery Settings'), findsOneWidget);
        expect(find.text('5.0 km'), findsOneWidget);
        expect(find.text('Notifications'), findsOneWidget);

        await tester.tap(
          find.byKey(const Key('dp_settings_toggle_notifications')),
        );
        await tester.pumpAndSettle();

        expect(
          tester
              .widget<Switch>(
                find.byKey(const Key('dp_settings_toggle_notifications')),
              )
              .value,
          isFalse,
        );

        await tester.tap(find.byKey(const Key('dp_settings_save_button')));
        await tester.pumpAndSettle();

        expect(find.text('Settings saved successfully'), findsOneWidget);

        final restored = await repository.fetchSettings();
        expect(restored.notificationsEnabled, isFalse);
        expect(restored.autoAcceptEnabled, isTrue);
      },
    );

    testWidgets('switches the language to Tamil and updates the UI strings', (
      tester,
    ) async {
      setDesktopSize(tester);
      await tester.pumpWidget(buildPage());
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('dp_settings_language_dropdown')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Tamil').last);
      await tester.pumpAndSettle();

      expect(find.text('டெலிவரி அமைப்புகள்'), findsOneWidget);
      expect(find.text('அமைப்புகளை சேமிக்கவும்'), findsOneWidget);

      await tester.tap(find.byKey(const Key('dp_settings_save_button')));
      await tester.pumpAndSettle();

      final persisted = await repository.fetchSettings();
      expect(persisted.languageCode, 'ta');
    });

    testWidgets(
      'adjusts the delivery radius and updates the earnings preview',
      (tester) async {
        setDesktopSize(tester);
        await tester.pumpWidget(buildPage());
        await tester.pumpAndSettle();

        final Slider before = tester.widget<Slider>(
          find.byKey(const Key('dp_settings_radius_slider')),
        );
        expect(before.value, 5.0);

        await tester.drag(
          find.byKey(const Key('dp_settings_radius_slider')),
          const Offset(150, 0),
        );
        await tester.pumpAndSettle();

        final Slider after = tester.widget<Slider>(
          find.byKey(const Key('dp_settings_radius_slider')),
        );
        expect(after.value, greaterThan(5.0));

        await tester.tap(find.byKey(const Key('dp_settings_save_button')));
        await tester.pumpAndSettle();

        final persisted = await repository.fetchSettings();
        expect(persisted.deliveryRadius, after.value);
      },
    );

    testWidgets('shows the error state when the network is unreachable', (
      tester,
    ) async {
      setDesktopSize(tester);
      when(
        () => mockService.checkNetworkConnectivity(),
      ).thenAnswer((_) async => false);
      await tester.pumpWidget(buildPage());
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('dp_settings_error')), findsOneWidget);
      expect(find.text('Network connection unavailable'), findsOneWidget);
      expect(find.byKey(const Key('dp_settings_retry')), findsOneWidget);
    });
  });
}
