import 'package:firebase_core_platform_interface/firebase_core_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockFirebaseAppPlatform extends FirebaseAppPlatform
    with MockPlatformInterfaceMixin {
  MockFirebaseAppPlatform(String name, FirebaseOptions options)
    : super(name, options);

  @override
  bool get isAutomaticDataCollectionEnabled => false;

  @override
  Future<void> setAutomaticDataCollectionEnabled(bool enabled) async {}

  @override
  Future<void> setAutomaticResourceManagementEnabled(bool enabled) async {}

  @override
  Future<void> delete() async {}
}

class MockFirebaseCore extends FirebasePlatform
    with MockPlatformInterfaceMixin {
  FirebaseAppPlatform get appInstance => app();

  @override
  List<FirebaseAppPlatform> get apps => [app()];
  @override
  Future<FirebaseAppPlatform> initializeApp({
    String? name,
    FirebaseOptions? options,
  }) async {
    return MockFirebaseAppPlatform(
      name ?? defaultFirebaseAppName,
      options ??
          const FirebaseOptions(
            appId: '123',
            apiKey: '123',
            projectId: '123',
            messagingSenderId: '123',
          ),
    );
  }

  @override
  FirebaseAppPlatform app([String name = defaultFirebaseAppName]) {
    return MockFirebaseAppPlatform(
      name,
      const FirebaseOptions(
        appId: '123',
        apiKey: '123',
        projectId: '123',
        messagingSenderId: '123',
      ),
    );
  }
}

void setupFirebaseAuthMocks() {
  TestWidgetsFlutterBinding.ensureInitialized();
  FirebasePlatform.instance = MockFirebaseCore();
}
