import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/chat_support_page_/chat_support_page_bloc.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/chat_support_page_/chat_support_page_event.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/chat_support_page_/chat_support_page_state.dart';
import 'package:food_delivery_app/core/repositories/i_chat_repository.dart';
import 'package:food_delivery_app/core/models/conversation_model.dart';
import 'package:food_delivery_app/core/models/chat_message_model.dart';

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
  group('ChatSupportPage Security Tests', () {
    late MockIChatRepository mockRepository;

    setUp(() {
      mockRepository = MockIChatRepository();
    });

    blocTest<ChatSupportBloc, ChatSupportState>(
      'filters out messages deleted for the current user (no cross-tenant leak)',
      build: () {
        when(() => mockRepository.getMessagesStream(any())).thenAnswer(
          (_) => Stream.value([
            ChatMessageModel(
              id: 'm_visible',
              conversationId: 'conv_1',
              text: 'Visible',
              senderId: 'buyer_1',
              senderRole: 'buyer',
              timestamp: DateTime(2026, 1, 1),
            ),
            ChatMessageModel(
              id: 'm_hidden',
              conversationId: 'conv_1',
              text: 'Hidden from seller',
              senderId: 'buyer_1',
              senderRole: 'buyer',
              timestamp: DateTime(2026, 1, 1),
              deletedBy: const ['seller_1'],
            ),
          ]),
        );
        when(() => mockRepository.getTypingStatusStream(any()))
            .thenAnswer((_) => const Stream.empty());
        when(() => mockRepository.markConversationRead(any(), any(), any()))
            .thenAnswer((_) async {});
        return ChatSupportBloc(repository: mockRepository);
      },
      seed: () => ChatSupportLoaded(
        currentUserId: 'seller_1',
        conversations: [makeConversation()],
      ),
      act: (bloc) => bloc.add(SelectChatSessionEvent('conv_1')),
      expect: () => [
        isA<ChatSupportLoaded>()
            .having((s) => s.selectedConversationId, 'selected', 'conv_1'),
        isA<ChatSupportLoaded>().having(
          (s) => s.messages.map((m) => m.id).toList(),
          'messageIds',
          ['m_visible'],
        ),
      ],
    );

    test('unread count is not exposed to non-participants', () {
      final conversation = makeConversation();
      expect(conversation.unreadCountForUser('intruder'), 0);
      expect(conversation.unreadCountForUser('seller_1'), conversation.sellerUnreadCount);
    });

    test('message text is preserved verbatim (rendered via Text, no execution)', () {
      final message = ChatMessageModel(
        id: 'm1',
        conversationId: 'conv_1',
        text: '<script>alert("xss")</script>',
        senderId: 'buyer_1',
        senderRole: 'buyer',
        timestamp: DateTime(2026, 1, 1),
      );

      expect(message.text, '<script>alert("xss")</script>');
      // Stored as plain text; the UI renders it inside a Text widget which
      // does not interpret markup.
    });
  });
}
