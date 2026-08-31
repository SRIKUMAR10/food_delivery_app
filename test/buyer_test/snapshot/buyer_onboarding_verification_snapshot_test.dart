import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:food_delivery_app/features/buyer_bloc_architecture/buyer_onboarding_verification_page/buyer_onboarding_verification_ui.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Buyer Onboarding Verification Snapshot Tests', () {
    testWidgets('Validates UI tree structural integrity', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: BuyerOnboardingVerificationPage(),
        ),
      );
      await tester.pump();

      expect(find.byType(Scaffold), findsOneWidget);
      expect(find.byType(AppBar), findsOneWidget);
      expect(find.byType(LinearProgressIndicator), findsOneWidget);
    });
  });
}
