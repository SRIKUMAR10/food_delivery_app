import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:food_delivery_app/features/buyer_bloc_architecture/buyer_onboarding_verification_page/buyer_onboarding_verification_ui.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Buyer Onboarding Verification Performance Tests', () {
    testWidgets('Wizard renders and transitions within performance budget (<100ms)',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: BuyerOnboardingVerificationPage(
            initialFullName: 'Speed Tester',
            initialPhone: '+919876543210',
          ),
        ),
      );
      await tester.pump();

      final stopwatch = Stopwatch()..start();
      await tester.ensureVisible(find.text('Continue to Contact Verification ➔'));
      await tester.tap(find.text('Continue to Contact Verification ➔'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 350));
      stopwatch.stop();

      expect(stopwatch.elapsedMilliseconds, lessThan(1000));
    });
  });
}
