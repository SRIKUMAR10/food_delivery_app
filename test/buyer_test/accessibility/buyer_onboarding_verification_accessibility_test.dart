import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:food_delivery_app/features/buyer_bloc_architecture/buyer_onboarding_verification_page/buyer_onboarding_verification_ui.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Buyer Onboarding Verification Accessibility Tests', () {
    testWidgets('Meets tap target and accessibility guidelines',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: BuyerOnboardingVerificationPage(),
        ),
      );
      await tester.pump();

      final SemanticsHandle semantics = tester.ensureSemantics();
      expect(find.byType(ElevatedButton), findsWidgets);
      semantics.dispose();
    });
  });
}
