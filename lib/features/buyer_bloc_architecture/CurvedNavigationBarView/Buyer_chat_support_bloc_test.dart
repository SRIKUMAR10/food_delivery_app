import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';

import 'package:food_delivery_app/features/buyer_bloc_architecture/CurvedNavigationBarView/Buyer_chat_support_bloc.dart';
import 'package:food_delivery_app/features/buyer_bloc_architecture/CurvedNavigationBarView/Buyer_chat_support_event.dart';
import 'package:food_delivery_app/features/buyer_bloc_architecture/CurvedNavigationBarView/Buyer_chat_support_state.dart';

void main() {
  group('BuyerChatSupportBloc Unit Tests', () {
    late BuyerChatSupportBloc buyerChatSupportBloc;

    setUp(() {
      buyerChatSupportBloc = BuyerChatSupportBloc();
    });

    tearDown(() {
      buyerChatSupportBloc.close();
    });

    test('Initial state is correct', () {
      expect(buyerChatSupportBloc.state, const BuyerChatSupportState());
    });

    blocTest<BuyerChatSupportBloc, BuyerChatSupportState>(
      'emits [loading, success] when LoadChatHistory is added.',
      build: () => buyerChatSupportBloc,
      act: (bloc) => bloc.add(const LoadChatHistory()),
      wait: const Duration(milliseconds: 1600),
      expect: () => [
        const BuyerChatSupportState(status: ChatStatus.loading),
        const BuyerChatSupportState(
          status: ChatStatus.success,
          messages: [
            {'sender': 'support', 'text': 'Hello! How can I help you today?'},
          ],
        ),
      ],
    );

    blocTest<BuyerChatSupportBloc, BuyerChatSupportState>(
      'emits new message and support reply when SendMessage is added.',
      build: () => buyerChatSupportBloc,
      act: (bloc) => bloc.add(const SendMessage('Test message')),
      wait: const Duration(seconds: 3),
      expect: () => [
        const BuyerChatSupportState(
          messages: [
            {'sender': 'user', 'text': 'Test message'},
          ],
          isTyping: true,
        ),
        const BuyerChatSupportState(
          messages: [
            {'sender': 'user', 'text': 'Test message'},
            {
              'sender': 'support',
              'text': 'Thank you for your message. We are looking into it.',
            },
          ],
          isTyping: false,
        ),
      ],
    );
  });
}
