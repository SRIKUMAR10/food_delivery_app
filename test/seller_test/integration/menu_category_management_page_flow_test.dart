import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:flutter/material.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/menu_category_management_page_/menu_category_management_page_ui.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('MenuCategoryManagementPage Integration Flow', () {
    testWidgets('Load and display categories', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(
        home: MenuCategoryManagementPage(sellerId: 'test_seller'),
      ));
      await tester.pumpAndSettle(const Duration(seconds: 2));
      
      expect(find.text('Manage Categories'), findsOneWidget);
    });
  });
}
