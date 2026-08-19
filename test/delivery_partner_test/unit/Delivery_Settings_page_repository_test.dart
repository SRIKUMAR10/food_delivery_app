import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Settings_page/Delivery_Settings_page_repository.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Settings_page/Delivery_Settings_page_state.dart';

void main() {
  late DeliverySettingsRepository repository;
  late SharedPreferences prefs;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();
    repository = DeliverySettingsRepository(prefs: prefs);
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

    test(
      'settings can be saved and loaded repeatedly without corruption',
      () async {
        for (var i = 1; i <= 3; i++) {
          final current = (await repository.fetchSettings()).copyWith(
            deliveryRadius: 3.0 + i,
          );
          await repository.saveSettings(current);
        }

        final restored = await repository.fetchSettings();
        expect(restored.deliveryRadius, 6.0);
        expect(restored.status, DeliverySettingsStatus.loaded);
      },
    );

    test('corrupt persisted data falls back to default settings', () async {
      await prefs.setString('dp_settings_data', '{not-valid-json');

      final settings = await repository.fetchSettings();
      expect(settings.status, DeliverySettingsStatus.loaded);
      expect(settings.notificationsEnabled, isTrue);
      expect(settings.items, hasLength(5));
    });

    test('changePassword validates password length', () async {
      expect(await repository.changePassword('old', 'secretPass'), isTrue);
      expect(await repository.changePassword('old', '12'), isFalse);
    });

    test('deactivateAccount completes with boolean', () async {
      expect(await repository.deactivateAccount(reason: 'Temp break'), isTrue);
    });

    test('deleteAccount completes with boolean', () async {
      expect(await repository.deleteAccount(reason: 'Permanent delete'), isTrue);
    });

    test('clearCache clears cached items', () async {
      await prefs.setString('cached_temp_data', 'foo');
      expect(await repository.clearCache(), isTrue);
      expect(prefs.getString('cached_temp_data'), isNull);
    });
  });
}

