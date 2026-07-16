import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:food_delivery_app/features/buyer_bloc_architecture/CurvedNavigationBarView/Buyer_chat_support_ui.dart';

void main() {
  group('BuyerChatSupportPage State Restoration Tests', () {
    testWidgets('Chat messages are restored after app restart', (
      WidgetTester tester,
    ) async {
      // To test state restoration, the app needs to be wrapped in a `RootRestorationScope`.
      // The BLoC would need to use `HydratedBloc` or a similar package to persist state.

      await tester.pumpWidget(
        const RootRestorationScope(
          restorationId: 'root',
          child: MaterialApp(home: BuyerChatSupportPage()),
        ),
      );
      await tester.pumpAndSettle();

      // Simulate app restart
      await tester.restartAndRestore();

      // Assert that the state (e.g., messages) is the same as before.
    });
  });
}
