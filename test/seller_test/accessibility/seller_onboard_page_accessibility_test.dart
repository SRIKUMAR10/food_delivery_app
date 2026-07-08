import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/seller_onboard_page/seller_onboard_page_ui.dart';

void main() {
  group('Accessibility Tests for SellerOnboardPageUI', () {
    testWidgets('UI meets basic accessibility requirements', (
      WidgetTester tester,
    ) async {
      final SemanticsHandle handle = tester.ensureSemantics();

      await tester.pumpWidget(const MaterialApp(home: SellerOnboardPageUI()));
      await tester.pumpAndSettle();

      // Ensure button has appropriate semantics
      expect(
        tester.getSemantics(find.text('Get Started')),
        matchesSemantics(
          isButton: true,
          label: 'Get Started',
          hasEnabledState: true,
          isEnabled: true,
          hasTapAction: true,
        ),
      );

      // Ensure tap targets meet minimum size requirements
      await expectLater(tester, meetsGuideline(textContrastGuideline));
      await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
      await expectLater(tester, meetsGuideline(iOSTapTargetGuideline));

      handle.dispose();
    });
  });
}
