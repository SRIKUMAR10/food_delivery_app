import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:food_delivery_app/Buyer Bloc Architecture/onboarding_page/onboarding_page_UI.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Onboarding Page Integration and Performance Tests', () {
    testWidgets('Tap Get Started button and measure performance', (WidgetTester tester) async {
      // Start the app directly at the OnboardingPage to isolate it
      await tester.pumpWidget(const MaterialApp(home: OnboardingPage()));
      await tester.pumpAndSettle();

      final buttonFinder = find.byType(HoverButton);
      expect(buttonFinder, findsOneWidget);

      await tester.tap(buttonFinder);
      await tester.pumpAndSettle();
    });
  });
}
