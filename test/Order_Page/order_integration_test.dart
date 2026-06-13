import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:food_delivery_app/Buyer%20Bloc%20Architecture/Order%20Page/order_UI.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('OrderPage end-to-end user flow', (tester) async {
    // 1. Setup the app
    await tester.pumpWidget(
      const MaterialApp(
        home: OrderPageUI(),
      ),
    );

    // Initial state is loading
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    // Wait for mock data to load
    await tester.pumpAndSettle(const Duration(seconds: 2));

    // Verify orders are displayed
    expect(find.text('My Orders'), findsOneWidget);
    expect(find.text('Double Cheese Burger'), findsOneWidget);
    
    // Tap on an image to open preview
    final imageFinder = find.byType(Image).first;
    await tester.tap(imageFinder);
    await tester.pumpAndSettle();

    // Verify the preview dialog is open
    expect(find.byType(InteractiveViewer), findsOneWidget);

    // Tap outside or close button to dismiss
    await tester.tap(find.byIcon(Icons.close));
    await tester.pumpAndSettle();

    // Verify dialog closed
    expect(find.byType(InteractiveViewer), findsNothing);
  });
}
