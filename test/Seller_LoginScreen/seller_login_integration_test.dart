import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:food_delivery_app/repositories/seller_repository.dart';

import 'package:mocktail/mocktail.dart';

import '../../lib/Seller Bloc Architecture_Delete/Seller_LoginScreen/Seller_LoginScreen_UI.dart';

class MockSellerRepository extends Mock implements SellerRepository {}

void main() {
  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
  });

  late MockSellerRepository mockRepository;

  setUp(() {
    mockRepository = MockSellerRepository();
  });

  Widget createWidgetUnderTest() {
    return MaterialApp(home: SellerLoginScreenUI(repository: mockRepository));
  }

  group('SellerLoginScreen Integration Tests', () {
    testWidgets('renders correctly and takes input', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      final emailField = find.byType(TextFormField).first;
      final passwordField = find.byType(TextFormField).last;
      final loginButton = find.text('Log In');

      await tester.enterText(emailField, 'test@example.com');
      await tester.enterText(passwordField, 'password123');
      await tester.pumpAndSettle();

      expect(loginButton, findsOneWidget);
      expect(emailField, findsOneWidget);
      expect(passwordField, findsOneWidget);
      // Not tapping submit to avoid initializing real firebase app in pure tests
    });
  });
}
