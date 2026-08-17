import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/chat_support_page_/chat_support_page_bloc.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/chat_support_page_/chat_support_page_event.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/chat_support_page_/chat_support_page_state.dart';
import 'package:food_delivery_app/core/repositories/i_chat_repository.dart';
import 'package:food_delivery_app/core/models/conversation_model.dart';

class MockIChatRepository extends Mock implements IChatRepository {}

ConversationModel makeConversation({String id = 'conv_1'}) {
  return ConversationModel(
    id: id,
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
  group('ChatSupportPage Error Handling Test', () {
    late ChatSupportBloc bloc;
    late MockIChatRepository mockRepository;

    setUp(() {
      mockRepository = MockIChatRepository();
      bloc = ChatSupportBloc(repository: mockRepository);
    });

    tearDown(() {
      bloc.close();
    });

    blocTest<ChatSupportBloc, ChatSupportState>(
      'Handles message send failure gracefully',
      build: () {
        when(
          () => mockRepository.sendMessage(
            conversationId: any(named: 'conversationId'),
            text: any(named: 'text'),
            senderId: any(named: 'senderId'),
            senderRole: any(named: 'senderRole'),
          ),
        ).thenThrow(Exception('NetworkError'));
        return bloc;
      },
      seed: () => ChatSupportLoaded(
        currentUserId: 'seller1',
        conversations: [],
      ),
      act: (bloc) => bloc.add(SendMessageEvent('session1', 'Hello')),
      expect: () => [
        isA<ChatSupportLoaded>().having((s) => s.isSendingMessage, 'isSending', true),
        isA<ChatSupportLoaded>()
          .having((s) => s.isSendingMessage, 'isSending', false)
          .having((s) => s.errorMessage, 'error', contains('Failed to send message')),
      ],
    );

    blocTest<ChatSupportBloc, ChatSupportState>(
      'Emits ChatSupportError when conversation stream fails',
      build: () {
        when(() => mockRepository.getConversationsForUser(any(), isSeller: true))
            .thenAnswer((_) => Stream.error(Exception('Network cut')));
        return bloc;
      },
      act: (bloc) => bloc.add(LoadChatSessionsEvent('seller1')),
      expect: () => [
        isA<ChatSupportLoading>(),
        isA<ChatSupportError>()
            .having((s) => s.message, 'message', contains('Failed to load conversations')),
      ],
    );

    blocTest<ChatSupportBloc, ChatSupportState>(
      'Handles message stream failure with an inline error message',
      build: () {
        when(() => mockRepository.getMessagesStream(any()))
            .thenAnswer((_) => Stream.error(Exception('Stream broke')));
        when(() => mockRepository.getTypingStatusStream(any()))
            .thenAnswer((_) => const Stream.empty());
        when(() => mockRepository.markConversationRead(any(), any(), any()))
            .thenAnswer((_) async {});
        return bloc;
      },
      seed: () => ChatSupportLoaded(
        currentUserId: 'seller1',
        conversations: [makeConversation()],
      ),
      act: (bloc) => bloc.add(SelectChatSessionEvent('conv_1')),
      expect: () => [
        isA<ChatSupportLoaded>()
            .having((s) => s.selectedConversationId, 'selected', 'conv_1'),
        isA<ChatSupportLoaded>().having(
          (s) => s.errorMessage,
          'errorMessage',
          contains('Failed to load messages'),
        ),
      ],
    );

    blocTest<ChatSupportBloc, ChatSupportState>(
      'Handles delivery partner chat creation failure',
      build: () {
        when(() => mockRepository.getConversationBetween(
              user1Id: any(named: 'user1Id'),
              user2Id: any(named: 'user2Id'),
              orderId: any(named: 'orderId'),
              type: any(named: 'type'),
            )).thenThrow(Exception('DB down'));
        return bloc;
      },
      seed: () => ChatSupportLoaded(
        currentUserId: 'seller1',
        conversations: [],
      ),
      act: (bloc) => bloc.add(StartOrderDeliveryPartnerChatEvent(
        orderId: 'ord_1',
        riderId: 'rider_1',
        riderName: 'Raj',
      )),
      expect: () => [
        isA<ChatSupportLoaded>().having(
          (s) => s.errorMessage,
          'errorMessage',
          contains('Failed to open delivery partner chat'),
        ),
      ],
    );
  });
}
