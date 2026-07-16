import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:flutter/material.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/business_hours_page_/business_hours_page_ui.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('BusinessHoursPage Integration Flow', () {
    testWidgets('Toggle emergency close', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(
        home: BusinessHoursPage(sellerId: 'test_seller'),
      ));
      await tester.pumpAndSettle(const Duration(seconds: 2));
      
      expect(find.text('Business Hours'), findsOneWidget);
      expect(find.byType(Switch), findsWidgets);
    });
  });
}
