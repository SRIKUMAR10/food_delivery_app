import 'package:firebase_core/firebase_core.dart';
import '../../mock_firebase.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/seller_payment_page/seller_payment_page_ui.dart';
// Note: In a real test, use mocktail to mock the Bloc

void main() {
  setUpAll(() async {
    setupFirebaseAuthMocks();
    await Firebase.initializeApp();
  });

  group('SellerPaymentPage UI Widget Tests', () {
    testWidgets('renders Payments title', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: SellerPaymentPage()));

      // Verify title
      expect(find.text('Payments'), findsOneWidget);
    });

    testWidgets('shows loading skeleton initially', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const MaterialApp(home: SellerPaymentPage()));

      // Before API finishes
      expect(find.byKey(const ValueKey('loading_state')), findsOneWidget);
    });
  });
}
