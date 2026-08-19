import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import '../../mock_firebase.dart';

/// Initializes Firebase core, secure storage and path provider channels so
/// real repositories/services can construct and fail gracefully inside
/// widget tests instead of throwing synchronously.
void setupDeliveryTestChannels() {
  setupFirebaseAuthMocks();
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(
    const MethodChannel('plugins.it_nomads.com/flutter_secure_storage'),
    (MethodCall methodCall) async => null,
  );
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(
    const MethodChannel('plugins.flutter.io/path_provider'),
    (MethodCall methodCall) async => '.',
  );
}