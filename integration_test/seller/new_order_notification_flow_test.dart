import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:flutter/material.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/new_order_notification/new_order_notification_ui.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('New Order Notification Flow Integration Test', () {
    testWidgets(
      'Full flow: Load order, accept order, verify success snackbar',
      (WidgetTester tester) async {
        // Build the app
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(body: NewOrderNotificationPage()),
          ),
        );

        // Wait for loading to finish
        await tester.pumpAndSettle();

        // Verify UI is loaded
        expect(find.text('New Order Received!'), findsOneWidget);
        expect(find.text('#1025'), findsOneWidget);

        // Tap Accept
        await tester.tap(find.text('Accept Order'));

        // Wait for async operations and animations
        await tester.pumpAndSettle();

        // Verify Snackbar
        expect(find.text('Order Accepted Successfully!'), findsOneWidget);
      },
    );
  });
}
