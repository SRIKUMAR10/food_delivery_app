import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:food_delivery_app/features/buyer_bloc_architecture/CurvedNavigationBarView/Buyer_chat_support_ui.dart';

void main() {
  group('BuyerChatSupportPage Performance Tests', () {
    testWidgets('Scrolling performance with many messages', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const MaterialApp(home: BuyerChatSupportPage()));
      await tester.pumpAndSettle();

      // The BLoC would need to be mocked or seeded with hundreds of messages here.

      await binding.traceAction(() async {
        await tester.fling(find.byType(ListView), const Offset(0, -500), 10000);
        await tester.pumpAndSettle();
      }, reportKey: 'chat_scrolling_performance');
    });
  });
}
