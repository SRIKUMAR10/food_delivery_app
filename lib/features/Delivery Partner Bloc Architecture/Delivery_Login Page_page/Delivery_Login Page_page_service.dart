import 'dart:async';
import 'package:flutter_dotenv/flutter_dotenv.dart';

abstract class DeliveryLoginServiceBase {
  Future<bool> checkNetworkConnectivity();
  Map<String, String> getEnvironmentVariables();
  Stream<double> uploadVideoChunked(String filePath);
  Future<bool> checkStoragePermission();
}

class DeliveryLoginService implements DeliveryLoginServiceBase {
  @override
  Future<bool> checkNetworkConnectivity() async {
    await Future.delayed(const Duration(milliseconds: 100));
    return true;
  }

  @override
  Map<String, String> getEnvironmentVariables() {
    final bool isDotenvReady = dotenv.isInitialized;
    return {
      'BASE_URL': isDotenvReady ? (dotenv.env['BASE_URL'] ?? 'https://api.fooddelivery.example.com') : 'https://api.fooddelivery.example.com',
      'API_KEY': isDotenvReady ? (dotenv.env['API_KEY'] ?? 'mock_api_key_12345') : 'mock_api_key_12345',
      'KEY_SECRET': isDotenvReady ? (dotenv.env['KEY_SECRET'] ?? 'mock_key_secret_67890') : 'mock_key_secret_67890',
    };
  }

  @override
  Stream<double> uploadVideoChunked(String filePath) async* {
    final totalChunks = 10;
    for (int i = 1; i <= totalChunks; i++) {
      await Future.delayed(const Duration(milliseconds: 100));
      yield i / totalChunks;
    }
  }

  @override
  Future<bool> checkStoragePermission() async {
    await Future.delayed(const Duration(milliseconds: 50));
    return true;
  }
}
