import 'package:firebase_core/firebase_core.dart';
import '../../mock_firebase.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  setUpAll(() async {
    setupFirebaseAuthMocks();
    await Firebase.initializeApp();
  });

  group('Seller Analytics Page widget Tests', () {
    test('Placeholder for widget testing', () {
      expect(true, isTrue);
    });
  });
}
