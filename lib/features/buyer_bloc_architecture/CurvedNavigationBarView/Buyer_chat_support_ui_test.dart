import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:food_delivery_app/features/buyer_bloc_architecture/CurvedNavigationBarView/Buyer_chat_support_ui.dart';

void main() {
  group('BuyerChatSupportPage Widget Tests', () {
    testWidgets('Renders AppBar and initial loading state', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const MaterialApp(home: BuyerChatSupportPage()));

      // Verify AppBar title
      expect(find.text('Support Chat'), findsOneWidget);

      // Verify initial loading indicator
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      // Wait for simulated network call to finish
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Verify loading indicator is gone
      expect(find.byType(CircularProgressIndicator), findsNothing);

      // Verify initial message from support is displayed
      expect(find.text('Hello! How can I help you today?'), findsOneWidget);
    });

    testWidgets('Sends a message when user types and taps send', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const MaterialApp(home: BuyerChatSupportPage()));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), 'Hello support!');
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pump();

      expect(find.text('Hello support!'), findsOneWidget);
    });
  });
}
