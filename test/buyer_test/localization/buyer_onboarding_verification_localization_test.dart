import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:food_delivery_app/features/buyer_bloc_architecture/buyer_onboarding_verification_page/buyer_onboarding_verification_ui.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Buyer Onboarding Verification Localization Tests', () {
    testWidgets('Renders localized strings accurately across step 1',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          locale: Locale('en', 'US'),
          home: BuyerOnboardingVerificationPage(),
        ),
      );
      await tester.pump();

      expect(find.text('Step 1 of 8'), findsOneWidget);
      expect(find.text('👤 Personal Identity & Avatar'), findsOneWidget);
    });
  });
}
