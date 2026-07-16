import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:flutter/material.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/chat_support_page_/chat_support_page_ui.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('ChatSupportPage Integration Flow', () {
    testWidgets('Load and display chats', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(
        home: ChatSupportPage(sellerId: 'test_seller'),
      ));
      await tester.pumpAndSettle(const Duration(seconds: 2));
      
      expect(find.text('Customer Support'), findsOneWidget);
    });
  });
}
