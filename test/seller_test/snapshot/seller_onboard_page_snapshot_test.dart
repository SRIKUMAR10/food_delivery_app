import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/seller_onboard_page/seller_onboard_page_ui.dart';

void main() {
  group('Snapshot Test (Widget Tree)', () {
    testWidgets('Widget tree matches expected snapshot structure', (
      tester,
    ) async {
      await tester.pumpWidget(const MaterialApp(home: SellerOnboardPageUI()));
      await tester.pumpAndSettle();

      // We verify the structure doesn't change unexpectedly
      expect(find.byType(Scaffold), findsOneWidget);
      expect(find.byType(Column), findsWidgets);
      expect(find.byType(ElevatedButton), findsOneWidget);

      // We can also verify against string representation or layout trees in snapshot tests
      final finder = find.byType(SellerOnboardView);
      expect(finder, findsOneWidget);
    });
  });
}
