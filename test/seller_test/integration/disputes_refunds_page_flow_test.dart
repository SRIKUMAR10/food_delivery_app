import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:flutter/material.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/disputes_refunds_page_/disputes_refunds_page_ui.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('DisputesRefundsPage Integration Flow', () {
    testWidgets('Load and display disputes', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(
        home: DisputesRefundsPage(sellerId: 'test_seller'),
      ));
      await tester.pumpAndSettle(const Duration(seconds: 2));
      
      expect(find.text('Disputes & Refunds'), findsOneWidget);
    });
  });
}
