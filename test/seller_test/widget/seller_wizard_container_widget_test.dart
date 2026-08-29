import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/seller_auth_shared/seller_auth_shared_widgets.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/seller_auth_shared/seller_wizard_container.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('SellerWizardContainer & SellerWizardPrimaryButton Widget Tests', () {
    testWidgets('SellerWizardContainer renders step badge, progress bar, title, and child content', (tester) async {
      await tester.binding.setSurfaceSize(const Size(1200, 1000));

      bool backTapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: SellerWizardContainer(
            stepIndex: 3,
            totalSteps: 8,
            stepBadge: 'Step 3 of 8 • Business Schedule',
            title: 'Business Operating Schedule',
            subtitle: 'Define your opening and closing times',
            onBack: () => backTapped = true,
            bottomAction: const SellerWizardPrimaryButton(
              buttonKey: ValueKey('test_bottom_cta'),
              label: 'Save & Continue',
              onPressed: null,
            ),
            child: const Text('Child Business Hours Content'),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Check Header items
      expect(find.text('Step 3 of 8 • Business Schedule'), findsOneWidget);
      expect(find.text('38% Completed'), findsOneWidget);
      expect(find.text('Business Operating Schedule'), findsOneWidget);
      expect(find.text('Define your opening and closing times'), findsOneWidget);
      expect(find.byType(LinearProgressIndicator), findsOneWidget);

      // Check Child
      expect(find.text('Child Business Hours Content'), findsOneWidget);

      // Check Bottom CTA
      expect(find.text('Save & Continue'), findsOneWidget);

      // Test Back Button
      await tester.tap(find.byIcon(Icons.arrow_back_ios_new_rounded));
      expect(backTapped, isTrue);
    });

    testWidgets('SellerWizardPrimaryButton renders green button style and responds to tap', (tester) async {
      await tester.binding.setSurfaceSize(const Size(800, 600));

      bool buttonClicked = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: SellerWizardPrimaryButton(
                buttonKey: const ValueKey('primary_action_btn'),
                label: 'Save & Continue to Next Step',
                onPressed: () => buttonClicked = true,
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Save & Continue to Next Step'), findsOneWidget);
      expect(find.byIcon(Icons.arrow_forward_rounded), findsOneWidget);

      await tester.tap(find.byKey(const ValueKey('primary_action_btn')));
      await tester.pumpAndSettle();

      expect(buttonClicked, isTrue);
    });

    testWidgets('SellerWizardPrimaryButton shows CircularProgressIndicator when isLoading is true', (tester) async {
      await tester.binding.setSurfaceSize(const Size(800, 600));

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Center(
              child: SellerWizardPrimaryButton(
                label: 'Saving Changes...',
                isLoading: true,
                onPressed: null,
              ),
            ),
          ),
        ),
      );

      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Saving Changes...'), findsNothing);
    });
  });
}
