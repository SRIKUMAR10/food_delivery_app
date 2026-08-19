import 'dart:async';

import 'package:flutter_test/flutter_test.dart';

import 'mock_firebase.dart';

Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  TestWidgetsFlutterBinding.ensureInitialized();
  setupFirebaseAuthMocks();
  await testMain();
}
