import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'Delivery_Settings_page_state.dart';

abstract class DeliverySettingsRepositoryBase {
  Future<DeliverySettingsState> fetchSettings();
  Future<void> saveSettings(DeliverySettingsState settings);
}

class DeliverySettingsRepository implements DeliverySettingsRepositoryBase {
  static const String _settingsKey = 'dp_settings_data';

  final SharedPreferences? _prefs;

  DeliverySettingsRepository({SharedPreferences? prefs}) : _prefs = prefs;

  static const List<String> supportedLanguageCodes = ['en', 'ta'];

  static List<DeliverySettingsItem> buildDefaultItems({
    required bool notificationsEnabled,
    required bool autoAcceptEnabled,
    required bool darkModeEnabled,
    required bool sunModeEnabled,
    required bool oledModeEnabled,
  }) {
    return [
      DeliverySettingsItem(
        id: 'notifications',
        titleKey: 'notifications',
        subtitleKey: 'notificationsSub',
        icon: Icons.notifications_outlined,
        value: notificationsEnabled,
      ),
      DeliverySettingsItem(
        id: 'autoAccept',
        titleKey: 'autoAccept',
        subtitleKey: 'autoAcceptSub',
        icon: Icons.bolt_outlined,
        value: autoAcceptEnabled,
      ),
      DeliverySettingsItem(
        id: 'darkMode',
        titleKey: 'darkMode',
        subtitleKey: 'darkModeSub',
        icon: Icons.dark_mode_outlined,
        value: darkModeEnabled,
      ),
      DeliverySettingsItem(
        id: 'sunMode',
        titleKey: 'sunMode',
        subtitleKey: 'sunModeSub',
        icon: Icons.wb_sunny_outlined,
        value: sunModeEnabled,
      ),
      DeliverySettingsItem(
        id: 'oledMode',
        titleKey: 'oledMode',
        subtitleKey: 'oledModeSub',
        icon: Icons.battery_saver,
        value: oledModeEnabled,
      ),
    ];
  }

  DeliverySettingsState buildDefaultSettings() {
    return DeliverySettingsState(
      status: DeliverySettingsStatus.loaded,
      notificationsEnabled: true,
      autoAcceptEnabled: true,
      darkModeEnabled: false,
      sunModeEnabled: false,
      oledModeEnabled: false,
      deliveryRadius: 5.0,
      languageCode: 'en',
      localeCode: 'en',
      items: buildDefaultItems(
        notificationsEnabled: true,
        autoAcceptEnabled: true,
        darkModeEnabled: false,
        sunModeEnabled: false,
        oledModeEnabled: false,
      ),
    );
  }

  Future<SharedPreferences?> _getPrefs() async {
    try {
      return _prefs ?? await SharedPreferences.getInstance();
    } catch (_) {
      return null;
    }
  }

  @override
  Future<DeliverySettingsState> fetchSettings() async {
    final prefs = await _getPrefs();
    if (prefs == null) {
      return buildDefaultSettings();
    }
    final raw = prefs.getString(_settingsKey);
    if (raw == null) {
      return buildDefaultSettings();
    }
    try {
      final map = jsonDecode(raw) as Map<String, dynamic>;
      return DeliverySettingsState.fromJson(map);
    } catch (_) {
      return buildDefaultSettings();
    }
  }

  @override
  Future<void> saveSettings(DeliverySettingsState settings) async {
    final prefs = await _getPrefs();
    if (prefs == null) return;
    await prefs.setString(_settingsKey, jsonEncode(settings.toJson()));
  }
}
