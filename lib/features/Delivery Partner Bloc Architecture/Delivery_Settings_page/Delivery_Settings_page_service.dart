import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

abstract class DeliverySettingsServiceBase {
  Future<bool> checkNetworkConnectivity();
  Map<String, String> getSecureEnvironmentConfigs();
  Stream<double> syncProgress();
  Future<bool> requestNotificationPermission();
  Future<bool> requestLocationPermission();
  double parseDeliveryRadius(String value, {double fallback = 5.0});
  Future<bool> changePassword(String currentPassword, String newPassword);
  Future<bool> deactivateAccount({String? reason});
  Future<bool> deleteAccount({String? reason});
  Future<bool> clearAppCache();
}

class DeliverySettingsService implements DeliverySettingsServiceBase {
  @override
  Future<bool> checkNetworkConnectivity() async {
    if (kIsWeb) {
      return true;
    }
    try {
      final result = await InternetAddress.lookup('google.com')
          .timeout(const Duration(seconds: 5));
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } on SocketException {
      return false;
    } on TimeoutException {
      return false;
    } catch (_) {
      return false;
    }
  }

  @override
  Map<String, String> getSecureEnvironmentConfigs() {
    final bool isInitialized = dotenv.isInitialized;
    return {
      'BASE_URL':
          (isInitialized ? dotenv.env['BASE_URL'] : null) ?? 'https://api.foodgo.com',
      'API_KEY': (isInitialized ? dotenv.env['API_KEY'] : null) ??
          'settings_prod_api_key_default',
      'KEY_SECRET': (isInitialized ? dotenv.env['KEY_SECRET'] : null) ??
          'settings_prod_secret_default',
      'SETTINGS_ENDPOINT':
          (isInitialized ? dotenv.env['SETTINGS_ENDPOINT'] : null) ??
              'https://api.foodgo.com/delivery/settings',
    };
  }

  @override
  Stream<double> syncProgress() async* {
    const int chunks = 10;
    for (var i = 1; i <= chunks; i++) {
      await Future<void>.delayed(const Duration(milliseconds: 30));
      yield i / chunks;
    }
  }

  @override
  Future<bool> requestNotificationPermission() async {
    return true;
  }

  @override
  Future<bool> requestLocationPermission() async {
    return true;
  }

  @override
  double parseDeliveryRadius(String value, {double fallback = 5.0}) {
    final parsed = double.tryParse(value.trim());
    if (parsed == null || parsed <= 0 || parsed > 50) return fallback;
    return parsed;
  }

  @override
  Future<bool> changePassword(String currentPassword, String newPassword) async {
    await Future<void>.delayed(const Duration(milliseconds: 100));
    return newPassword.length >= 6;
  }

  @override
  Future<bool> deactivateAccount({String? reason}) async {
    await Future<void>.delayed(const Duration(milliseconds: 100));
    return true;
  }

  @override
  Future<bool> deleteAccount({String? reason}) async {
    await Future<void>.delayed(const Duration(milliseconds: 100));
    return true;
  }

  @override
  Future<bool> clearAppCache() async {
    await Future<void>.delayed(const Duration(milliseconds: 50));
    return true;
  }
}

