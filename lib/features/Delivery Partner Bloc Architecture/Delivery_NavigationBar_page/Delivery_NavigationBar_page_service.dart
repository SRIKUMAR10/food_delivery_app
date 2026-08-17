import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

abstract class DeliveryNavigationBarServiceBase {
  Future<bool> checkConnectivity();
  Map<String, String> getEnvironmentVariables();
  Future<bool> checkPermission();
  Future<bool> requestPermission();
  Stream<double> simulateChunkedUpload();
}

class DeliveryNavigationBarService
    implements DeliveryNavigationBarServiceBase {
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
  Map<String, String> getEnvironmentVariables() {
    String read(String key) =>
        dotenv.isInitialized ? (dotenv.env[key] ?? '') : '';
    return {
      'BASE_URL': read('BASE_URL'),
      'API_KEY': read('API_KEY'),
      'KEY_SECRET': read('KEY_SECRET'),
    };
  }

  @override
  Future<bool> checkPermission() async {
    return true;
  }

  @override
  Future<bool> requestPermission() async {
    return true;
  }

  @override
  Stream<double> simulateChunkedUpload() async* {
    const int chunks = 10;
    for (var i = 1; i <= chunks; i++) {
      await Future<void>.delayed(const Duration(milliseconds: 50));
      yield i / chunks;
    }
  }
}
