import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/add_product_page_/add_product_page__ui.dart';

void main() {
  group('AddProductPage Accessibility Test', () {
    testWidgets('meets standard accessibility guidelines', (tester) async {
      final SemanticsHandle handle = tester.ensureSemantics();

      await tester.pumpWidget(const MaterialApp(home: AddProductPage()));

      // Check that tap targets are large enough and labels are present
      await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
      await expectLater(tester, meetsGuideline(iOSTapTargetGuideline));
      await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
      await expectLater(tester, meetsGuideline(textContrastGuideline));

      handle.dispose();
    });
  });
}
