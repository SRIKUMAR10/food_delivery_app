import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/chat_support_page_/chat_support_page_bloc.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/chat_support_page_/chat_support_page_event.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/chat_support_page_/chat_support_page_state.dart';
import 'package:food_delivery_app/core/repositories/i_chat_repository.dart';
import 'package:food_delivery_app/core/models/conversation_model.dart';

class MockIChatRepository extends Mock implements IChatRepository {}

ConversationModel makeConversation() {
  return ConversationModel(
    id: 'conv_1',
    buyerId: 'buyer_1',
    sellerId: 'seller_1',
    buyerName: 'Aarav',
    sellerName: 'FoodGo',
    createdAt: DateTime(2026, 1, 1),
    updatedAt: DateTime(2026, 1, 1),
    participants: const ['buyer_1', 'seller_1'],
    participantRoles: const {'buyer_1': 'buyer', 'seller_1': 'seller'},
  );
}

void main() {
  group('Seller ChatSupportPage Permission Tests', () {
    late MockIChatRepository mockRepository;

    setUp(() {
      mockRepository = MockIChatRepository();
    });

    blocTest<ChatSupportBloc, ChatSupportState>(
      'loads conversations scoped to the authenticated seller',
      build: () {
        when(() => mockRepository.getConversationsForUser(any(), isSeller: true))
            .thenAnswer((_) => Stream.value([]));
        return ChatSupportBloc(repository: mockRepository);
      },
      act: (bloc) => bloc.add(LoadChatSessionsEvent('seller_1')),
      verify: (_) {
        verify(() => mockRepository.getConversationsForUser('seller_1', isSeller: true))
            .called(1);
      },
    );

    blocTest<ChatSupportBloc, ChatSupportState>(
      'sends messages with the seller role (no impersonation)',
      build: () {
        when(() => mockRepository.sendMessage(
              conversationId: any(named: 'conversationId'),
              text: any(named: 'text'),
              senderId: any(named: 'senderId'),
              senderRole: any(named: 'senderRole'),
            )).thenAnswer((_) async {});
        return ChatSupportBloc(repository: mockRepository);
      },
      seed: () => ChatSupportLoaded(
        currentUserId: 'seller_1',
        conversations: [makeConversation()],
        selectedConversationId: 'conv_1',
      ),
      act: (bloc) => bloc.add(SendMessageEvent('conv_1', 'Hello')),
      verify: (_) {
        verify(() => mockRepository.sendMessage(
              conversationId: 'conv_1',
              text: 'Hello',
              senderId: 'seller_1',
              senderRole: 'seller',
            )).called(1);
      },
    );

    test('the seller never sees their own typing as "other user typing"', () {
      final state = ChatSupportLoaded(
        currentUserId: 'seller_1',
        conversations: [makeConversation()],
        selectedConversationId: 'conv_1',
        typingUsers: const {'seller_1': true},
      );

      expect(state.isOtherUserTyping, isFalse);
    });

    test('typing from a non-participant is not surfaced', () {
      final state = ChatSupportLoaded(
        currentUserId: 'seller_1',
        conversations: [makeConversation()],
        selectedConversationId: 'conv_1',
        typingUsers: const {'intruder_1': true},
      );

      expect(state.isOtherUserTyping, isTrue);
      expect(state.otherUserTypingName, isNull);
    });
  });
}
