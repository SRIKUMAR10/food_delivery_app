import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:food_delivery_app/repositories/seller_repository.dart';

import 'package:mocktail/mocktail.dart';

import '../../lib/Seller Bloc Architecture_Delete/Seller_SignUpPage/Seller_SignUpPage_UI.dart';
import '../mock_firebase.dart';

class MockSellerRepository extends Mock implements SellerRepository {}

void main() {
  setUpAll(() {
    setupFirebaseAuthMocks();
    TestWidgetsFlutterBinding.ensureInitialized();
  });

  late MockSellerRepository mockRepository;

  setUp(() {
    mockRepository = MockSellerRepository();
  });

  Widget createWidgetUnderTest() {
    return MaterialApp(home: SellerSignUpScreenUI(repository: mockRepository));
  }

  group('SellerSignUpScreen Integration Tests', () {
    testWidgets('renders correctly and takes input', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      final nameField = find.byType(TextFormField).at(0);
      final emailField = find.byType(TextFormField).at(1);
      final passwordField = find.byType(TextFormField).at(2);
      final signUpButton = find.byKey(const Key('signup_button'));

      await tester.enterText(nameField, 'John Doe');
      await tester.enterText(emailField, 'test@example.com');
      await tester.enterText(passwordField, 'password123');
      await tester.pumpAndSettle();

      expect(signUpButton, findsOneWidget);
      expect(nameField, findsOneWidget);
      expect(emailField, findsOneWidget);
      expect(passwordField, findsOneWidget);
      // Not tapping submit to avoid initializing real firebase app in pure tests
    });
  });
}
