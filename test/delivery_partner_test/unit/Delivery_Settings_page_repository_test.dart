import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Settings_page/Delivery_Settings_page_repository.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Settings_page/Delivery_Settings_page_service.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Settings_page/Delivery_Settings_page_state.dart';

class MockDeliverySettingsService extends Mock
    implements DeliverySettingsServiceBase {}

void main() {
  late DeliverySettingsRepository repository;
  late MockDeliverySettingsService mockService;
  late SharedPreferences prefs;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();
    mockService = MockDeliverySettingsService();

    when(() => mockService.getAppVersion()).thenReturn('v2.4.0 (Build 342)');
    when(() => mockService.fetchSettingsData()).thenAnswer((_) async => {});
    when(() => mockService.watchSettingsData()).thenAnswer((_) => const Stream.empty());
    when(() => mockService.saveSettingsData(any())).thenAnswer((_) async => true);
    when(() => mockService.changePassword(any(), any())).thenAnswer((_) async => true);
    when(() => mockService.deactivateAccount(reason: any(named: 'reason'))).thenAnswer((_) async => true);
    when(() => mockService.deleteAccount(reason: any(named: 'reason'))).thenAnswer((_) async => true);
    when(() => mockService.clearAppCache()).thenAnswer((_) async => true);

    repository = DeliverySettingsRepository(
      prefs: prefs,
      service: mockService,
    );
  });

  group('DeliverySettingsPage Repository Tests', () {
    test('buildDefaultItems contains the five toggle items in order', () {
      final items = DeliverySettingsRepository.buildDefaultItems(
        notificationsEnabled: true,
        autoAcceptEnabled: true,
        darkModeEnabled: false,
        sunModeEnabled: false,
        oledModeEnabled: false,
      );

      expect(items, hasLength(5));
      expect(items.map((i) => i.id).toList(), [
        'notifications',
        'autoAccept',
        'darkMode',
        'sunMode',
        'oledMode',
      ]);
    });

    test('supportedLanguageCodes contains English and Tamil', () {
      expect(DeliverySettingsRepository.supportedLanguageCodes, ['en', 'ta']);
    });

    test('fetchSettings returns default settings on first run', () async {
      final settings = await repository.fetchSettings();

      expect(settings.status, DeliverySettingsStatus.loaded);
      expect(settings.notificationsEnabled, isTrue);
      expect(settings.autoAcceptEnabled, isTrue);
      expect(settings.darkModeEnabled, isFalse);
      expect(settings.deliveryRadius, 5.0);
      expect(settings.languageCode, 'en');
      expect(settings.items, hasLength(5));
    });

    test('saveSettings persists changes that fetchSettings restores', () async {
      final updated = (await repository.fetchSettings()).copyWith(
        notificationsEnabled: false,
        darkModeEnabled: true,
        deliveryRadius: 12.5,
        languageCode: 'ta',
        localeCode: 'ta',
      );

      await repository.saveSettings(updated);

      final restored = await repository.fetchSettings();
      expect(restored.notificationsEnabled, isFalse);
      expect(restored.darkModeEnabled, isTrue);
      expect(restored.deliveryRadius, 12.5);
      expect(restored.languageCode, 'ta');
      expect(restored.localeCode, 'ta');
      expect(restored.autoAcceptEnabled, isTrue);
      expect(restored.items, hasLength(5));
    });

    test('watchSettings streams live data and maps to DeliverySettingsState', () async {
      final controller = StreamController<Map<String, dynamic>>();
      when(() => mockService.watchSettingsData()).thenAnswer((_) => controller.stream);

      final stream = repository.watchSettings();
      final expectation = expectLater(
        stream,
        emits(predicate<DeliverySettingsState>((s) =>
            s.partnerId == 'DP-TEST-1234' &&
            s.deliveryRadius == 7.5 &&
            s.vehicleType == 'Bike')),
      );

      controller.add({
        'partnerId': 'DP-TEST-1234',
        'deliveryRadius': 7.5,
        'vehicleType': 'Bike',
        'vehicleNumber': 'TN-01-AB-1234',
      });

      await expectation;
      await controller.close();
    });

    test('corrupt persisted data falls back to default settings', () async {
      await prefs.setString('dp_settings_data', '{not-valid-json');

      final settings = await repository.fetchSettings();
      expect(settings.status, DeliverySettingsStatus.loaded);
      expect(settings.notificationsEnabled, isTrue);
      expect(settings.items, hasLength(5));
    });

    test('changePassword delegates to service', () async {
      expect(await repository.changePassword('old', 'secretPass'), isTrue);
    });

    test('deactivateAccount delegates to service', () async {
      expect(await repository.deactivateAccount(reason: 'Temp break'), isTrue);
    });

    test('deleteAccount delegates to service', () async {
      expect(await repository.deleteAccount(reason: 'Permanent delete'), isTrue);
    });

    test('clearCache clears cached items', () async {
      await prefs.setString('cached_temp_data', 'foo');
      await prefs.setString('dp_settings_data', 'bar');
      expect(await repository.clearCache(), isTrue);
      expect(prefs.getString('cached_temp_data'), isNull);
      expect(prefs.getString('dp_settings_data'), isNull);
    });
  });
}

