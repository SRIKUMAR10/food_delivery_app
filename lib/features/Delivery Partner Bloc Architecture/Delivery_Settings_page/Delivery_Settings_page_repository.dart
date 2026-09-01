import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'Delivery_Settings_page_service.dart';
import 'Delivery_Settings_page_state.dart';

abstract class DeliverySettingsRepositoryBase {
  Future<DeliverySettingsState> fetchSettings();
  Stream<DeliverySettingsState> watchSettings();
  Future<void> saveSettings(DeliverySettingsState settings);
  Future<bool> changePassword(String currentPassword, String newPassword);
  Future<bool> deactivateAccount({String? reason});
  Future<bool> deleteAccount({String? reason});
  Future<bool> clearCache();
}

class DeliverySettingsRepository implements DeliverySettingsRepositoryBase {
  static const String _settingsKey = 'dp_settings_data';

  final SharedPreferences? _prefs;
  final DeliverySettingsServiceBase _service;

  DeliverySettingsRepository({
    SharedPreferences? prefs,
    DeliverySettingsServiceBase? service,
  })  : _prefs = prefs,
        _service = service ?? DeliverySettingsService();

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
      partnerId: '',
      partnerName: '',
      vehicleType: '',
      vehicleNumber: '',
      bankName: '',
      bankAccountNumber: '',
      bankAccountStatus: '',
      todayEarnings: 0.0,
      totalEarnings: 0.0,
      completedOrdersCount: 0,
      estimatedDailyEarnings: 0.0,
      appVersion: _service.getAppVersion(),
    );
  }

  Future<SharedPreferences?> _getPrefs() async {
    try {
      return _prefs ?? await SharedPreferences.getInstance();
    } catch (_) {
      return null;
    }
  }

  DeliverySettingsState mapDataToSettings(
    Map<String, dynamic> data,
    DeliverySettingsState fallback,
  ) {
    if (data.isEmpty) return fallback;

    final notif = data['notificationsEnabled'] as bool? ??
        data['notifications'] as bool? ??
        fallback.notificationsEnabled;
    final autoAcc = data['autoAcceptEnabled'] as bool? ??
        data['autoAccept'] as bool? ??
        fallback.autoAcceptEnabled;
    final darkM = data['darkModeEnabled'] as bool? ??
        data['darkMode'] as bool? ??
        fallback.darkModeEnabled;
    final sunM = data['sunModeEnabled'] as bool? ??
        data['sunMode'] as bool? ??
        fallback.sunModeEnabled;
    final oledM = data['oledModeEnabled'] as bool? ??
        data['oledMode'] as bool? ??
        fallback.oledModeEnabled;

    final radius = (data['deliveryRadius'] ?? data['deliveryRadiusKm'] as num?)?.toDouble() ??
        fallback.deliveryRadius;
    final lang = (data['languageCode'] as String?)?.isNotEmpty == true
        ? data['languageCode'] as String
        : fallback.languageCode;
    final locale = (data['localeCode'] as String?)?.isNotEmpty == true
        ? data['localeCode'] as String
        : lang;

    final sound = data['soundAlertsEnabled'] as bool? ?? fallback.soundAlertsEnabled;
    final vibe = data['vibrationAlertsEnabled'] as bool? ?? fallback.vibrationAlertsEnabled;
    final gps = data['highAccuracyGps'] as bool? ?? fallback.highAccuracyGps;
    final bgLoc = data['backgroundLocationEnabled'] as bool? ?? fallback.backgroundLocationEnabled;
    final bio = data['biometricLockEnabled'] as bool? ?? fallback.biometricLockEnabled;
    final tfa = data['twoFactorAuthEnabled'] as bool? ?? fallback.twoFactorAuthEnabled;
    final dataConsent = data['dataSharingConsent'] as bool? ?? fallback.dataSharingConsent;
    final deactivated = data['isAccountDeactivated'] as bool? ??
        (data['isActive'] == false || data['status'] == 'inactive');

    final pId = (data['partnerId'] ?? data['id'] ?? fallback.partnerId).toString();
    final pName = (data['partnerName'] ?? data['displayName'] ?? data['fullName'] ?? fallback.partnerName).toString();
    final phone = (data['phone'] ?? data['phoneNumber'] ?? fallback.phone).toString();
    final email = (data['email'] ?? fallback.email).toString();

    final vType = (data['vehicleType'] ?? fallback.vehicleType).toString();
    final vNum = (data['vehicleNumber'] ?? fallback.vehicleNumber).toString();
    final bName = (data['bankName'] ?? fallback.bankName).toString();
    final bNum = (data['bankAccountNumber'] ?? fallback.bankAccountNumber).toString();
    final bStatus = (data['bankAccountStatus'] ?? (bNum.isNotEmpty ? 'Active' : '')).toString();

    final todayE = (data['todayEarnings'] as num?)?.toDouble() ?? fallback.todayEarnings;
    final totalE = (data['totalEarnings'] as num?)?.toDouble() ?? fallback.totalEarnings;
    final trips = (data['completedOrdersCount'] ?? data['totalDeliveries'] as num?)?.toInt() ??
        fallback.completedOrdersCount;

    // Dynamic verified calculation: base coverage rate + historical earnings indicator
    final double estimated = todayE > 0
        ? todayE * (radius / 5.0).clamp(0.8, 2.5)
        : (totalE > 0 && trips > 0)
            ? (totalE / trips) * 12.0 * (radius / 5.0).clamp(0.8, 2.5)
            : radius * 240.0;

    return fallback.copyWith(
      status: DeliverySettingsStatus.loaded,
      notificationsEnabled: notif,
      autoAcceptEnabled: autoAcc,
      darkModeEnabled: darkM,
      sunModeEnabled: sunM,
      oledModeEnabled: oledM,
      deliveryRadius: radius,
      languageCode: lang,
      localeCode: locale,
      items: buildDefaultItems(
        notificationsEnabled: notif,
        autoAcceptEnabled: autoAcc,
        darkModeEnabled: darkM,
        sunModeEnabled: sunM,
        oledModeEnabled: oledM,
      ),
      soundAlertsEnabled: sound,
      vibrationAlertsEnabled: vibe,
      highAccuracyGps: gps,
      backgroundLocationEnabled: bgLoc,
      biometricLockEnabled: bio,
      twoFactorAuthEnabled: tfa,
      dataSharingConsent: dataConsent,
      isAccountDeactivated: deactivated,
      partnerId: pId,
      partnerName: pName,
      phone: phone,
      email: email,
      vehicleType: vType,
      vehicleNumber: vNum,
      bankName: bName,
      bankAccountNumber: bNum,
      bankAccountStatus: bStatus,
      todayEarnings: todayE,
      totalEarnings: totalE,
      completedOrdersCount: trips,
      estimatedDailyEarnings: estimated,
      appVersion: _service.getAppVersion(),
    );
  }

  @override
  Stream<DeliverySettingsState> watchSettings() async* {
    final prefs = await _getPrefs();
    DeliverySettingsState initial = buildDefaultSettings();
    if (prefs != null) {
      final raw = prefs.getString(_settingsKey);
      if (raw != null) {
        try {
          final map = jsonDecode(raw) as Map<String, dynamic>;
          initial = DeliverySettingsState.fromJson(map);
        } catch (_) {}
      }
    }

    yield* _service.watchSettingsData().map((data) {
      if (data.isEmpty) return initial;
      final updated = mapDataToSettings(data, initial);
      // Update local storage cache asynchronously
      _saveToCache(updated);
      return updated;
    });
  }

  Future<void> _saveToCache(DeliverySettingsState settings) async {
    try {
      final prefs = await _getPrefs();
      if (prefs != null) {
        await prefs.setString(_settingsKey, jsonEncode(settings.toJson()));
      }
    } catch (_) {}
  }

  @override
  Future<DeliverySettingsState> fetchSettings() async {
    final defaultSettings = buildDefaultSettings();
    try {
      final remoteData = await _service.fetchSettingsData();
      if (remoteData.isNotEmpty) {
        final mapped = mapDataToSettings(remoteData, defaultSettings);
        await _saveToCache(mapped);
        return mapped;
      }
    } catch (_) {}

    final prefs = await _getPrefs();
    if (prefs == null) {
      return defaultSettings;
    }
    final raw = prefs.getString(_settingsKey);
    if (raw == null) {
      return defaultSettings;
    }
    try {
      final map = jsonDecode(raw) as Map<String, dynamic>;
      return DeliverySettingsState.fromJson(map);
    } catch (_) {
      return defaultSettings;
    }
  }

  @override
  Future<void> saveSettings(DeliverySettingsState settings) async {
    // 1. Save to Firestore
    await _service.saveSettingsData(settings.toJson());

    // 2. Save to local SharedPreferences
    final prefs = await _getPrefs();
    if (prefs != null) {
      await prefs.setString(_settingsKey, jsonEncode(settings.toJson()));
    }
  }

  @override
  Future<bool> changePassword(String currentPassword, String newPassword) async {
    return await _service.changePassword(currentPassword, newPassword);
  }

  @override
  Future<bool> deactivateAccount({String? reason}) async {
    return await _service.deactivateAccount(reason: reason);
  }

  @override
  Future<bool> deleteAccount({String? reason}) async {
    return await _service.deleteAccount(reason: reason);
  }

  @override
  Future<bool> clearCache() async {
    final prefs = await _getPrefs();
    if (prefs != null) {
      await prefs.remove('cached_temp_data');
      await prefs.remove(_settingsKey);
    }
    return await _service.clearAppCache();
  }
}

