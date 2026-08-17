import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_core/firebase_core.dart';
import '../../mock_firebase.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/seller_payment_page/seller_payment_page_ui.dart';

void main() {
  setUpAll(() async {
    setupFirebaseAuthMocks();
    await Firebase.initializeApp();
  });

  group('SellerPaymentPage UI Widget Tests', () {
    testWidgets('renders Payments title and LIVE SYNC indicator', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: SellerPaymentPage(),
        ),
      );
      await tester.pump();

      // Verify title exists
      expect(find.text('Payments'), findsOneWidget);

      // Verify Live Sync indicator
      expect(find.text('LIVE SYNC'), findsOneWidget);
    });

    testWidgets('renders loading state or content properly', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: SellerPaymentPage(),
        ),
      );
      await tester.pump();

      // Verify Scaffold and main structure exists
      expect(find.byType(Scaffold), findsOneWidget);
      expect(find.byType(RefreshIndicator), findsOneWidget);
    });
  });
}
