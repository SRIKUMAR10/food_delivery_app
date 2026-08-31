import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:food_delivery_app/features/buyer_bloc_architecture/buyer_onboarding_verification_page/buyer_onboarding_verification_ui.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Buyer Onboarding Verification Golden Tests', () {
    testWidgets('Renders properly without overflow on mobile viewport', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        const MaterialApp(
          home: BuyerOnboardingVerificationPage(),
        ),
      );
      await tester.pump();

      expect(find.byType(BuyerOnboardingVerificationPage), findsOneWidget);
    });

    testWidgets('Renders properly on tablet viewport', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1024, 1366);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        const MaterialApp(
          home: BuyerOnboardingVerificationPage(),
        ),
      );
      await tester.pump();

      expect(find.byType(BuyerOnboardingVerificationPage), findsOneWidget);
    });
  });
}
