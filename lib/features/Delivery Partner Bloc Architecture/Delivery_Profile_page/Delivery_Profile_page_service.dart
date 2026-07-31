import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

abstract class DeliveryProfileServiceBase {
  Future<bool> checkNetworkConnectivity();
  Stream<double> chunkedUpload(String documentId);
  Map<String, String> getEnvironmentVariables();
  String? validateMedia(String? filePath);
  Future<bool> requestMediaPermission();
}

class DeliveryProfileService implements DeliveryProfileServiceBase {
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
  Stream<double> chunkedUpload(String documentId) async* {
    const int chunks = 10;
    for (var i = 1; i <= chunks; i++) {
      await Future<void>.delayed(const Duration(milliseconds: 40));
      yield i / chunks;
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
      'UPLOAD_ENDPOINT': read('UPLOAD_ENDPOINT'),
    };
  }

  @override
  String? validateMedia(String? filePath) {
    if (filePath == null || filePath.isEmpty) {
      return 'Please choose a file to upload';
    }
    final extension = filePath.split('.').last.toLowerCase();
    const allowed = ['jpg', 'jpeg', 'png', 'pdf', 'webp'];
    if (!allowed.contains(extension)) {
      return 'Unsupported file type: .$extension';
    }
    return null;
  }

  @override
  Future<bool> requestMediaPermission() async {
    return true;
  }
}
