import 'package:flutter_test/flutter_test.dart';
import 'package:food_delivery_app/features/buyer_bloc_architecture/CurvedNavigationBarView/Buyer_chat_support_state.dart';

void main() {
  group('BuyerChatSupportState Snapshot Tests', () {
    test('Initial state matches snapshot', () {
      const initialState = BuyerChatSupportState();
      // In a real scenario, you might serialize the state to JSON and compare.
      expect(initialState.status, ChatStatus.initial);
      expect(initialState.messages, isEmpty);
    });

    test('Success state matches snapshot', () {
      final successState = const BuyerChatSupportState().copyWith(
        status: ChatStatus.success,
        messages: [
          {'sender': 'user', 'text': 'hi'},
        ],
      );
      expect(successState.status, ChatStatus.success);
      expect(successState.messages.first['text'], 'hi');
    });
  });
}
