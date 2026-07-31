import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

abstract class DeliveryNavigationServiceBase {
  Future<bool> checkConnectivity();
  Future<bool> checkLocationPermission();
  Future<bool> requestLocationPermission();
  Map<String, String> getEnvironmentVariables();
  String? sanitizeInput(String? input);
  double calculateEstimatedEta(double distanceKm);
  Stream<double> simulateLiveLocation();
}

class DeliveryNavigationService implements DeliveryNavigationServiceBase {
  static const double _defaultSpeedKmh = 20.5;

  @override
  Future<bool> checkConnectivity() async {
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
  Future<bool> checkLocationPermission() async {
    return true;
  }

  @override
  Future<bool> requestLocationPermission() async {
    return true;
  }

  @override
  Map<String, String> getEnvironmentVariables() {
    String read(String key) =>
        dotenv.isInitialized ? (dotenv.env[key] ?? '') : '';
    return {
      'BASE_URL': read('BASE_URL'),
      'API_KEY': read('API_KEY'),
      'KEY_SECRET': read('KEY_SECRET'),
      'MAPS_API_KEY': read('MAPS_API_KEY'),
    };
  }

  @override
  String? sanitizeInput(String? input) {
    if (input == null) return null;
    final sanitized = input
        .replaceAll(RegExp(r'[^\w\s@.,+\-]'), '')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
    if (sanitized.isEmpty) return null;
    return sanitized.length > 200 ? sanitized.substring(0, 200) : sanitized;
  }

  @override
  double calculateEstimatedEta(double distanceKm) {
    if (distanceKm <= 0) return 0;
    return (distanceKm * 60 / _defaultSpeedKmh).round().toDouble();
  }

  @override
  Stream<double> simulateLiveLocation() async* {
    const List<double> deltas = [40, 35, 30, 25, 20, 15, 10];
    for (final delta in deltas) {
      await Future<void>.delayed(const Duration(milliseconds: 40));
      yield delta;
    }
  }
}
