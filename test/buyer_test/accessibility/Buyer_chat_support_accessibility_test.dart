import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:food_delivery_app/features/buyer_bloc_architecture/CurvedNavigationBarView/Buyer_chat_support_ui.dart';

void main() {
  group('BuyerChatSupportPage Accessibility Tests', () {
    testWidgets('Passes accessibility guidelines', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: BuyerChatSupportPage()));
      await tester.pumpAndSettle();

      // Check for minimum tap targets, contrast, and labels.
      final SemanticsHandle semantics = tester.ensureSemantics();
      await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
      await expectLater(tester, meetsGuideline(iOSTapTargetGuideline));
      await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
      semantics.dispose();
    });
  });
}
