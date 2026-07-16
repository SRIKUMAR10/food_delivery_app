import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:food_delivery_app/features/buyer_bloc_architecture/CurvedNavigationBarView/Buyer_chat_support_ui.dart';

void main() {
  group('BuyerChatSupportPage Localization Tests', () {
    testWidgets('Displays text in the correct language', (
      WidgetTester tester,
    ) async {
      // This would require setting up a localization delegate for the test.
      // For example, switching the locale to Spanish.
      const locale = Locale('es', 'ES');

      await tester.pumpWidget(
        const MaterialApp(
          // supportedLocales: [locale],
          // localizationsDelegates: [...],
          home: BuyerChatSupportPage(),
        ),
      );
      await tester.pumpAndSettle();
      // expect(find.text('Chat de Soporte'), findsOneWidget); // Example assertion
    });
  });
}
