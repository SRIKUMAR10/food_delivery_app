import 'dart:async';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:food_delivery_app/core/models/conversation_model.dart';
import 'package:food_delivery_app/core/repositories/i_chat_repository.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/chat_support_page_/chat_support_page_bloc.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/chat_support_page_/chat_support_page_event.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/chat_support_page_/chat_support_page_state.dart';

class MockIChatRepository extends Mock implements IChatRepository {}

void main() {
  late MockIChatRepository mockRepository;
  final now = DateTime(2026, 7, 20, 10, 30);

  const testSellerId = 'seller_1';
  const testConversationId = 'conv_1';

  final testConversation = ConversationModel(
    id: testConversationId,
    buyerId: 'buyer_1',
    sellerId: testSellerId,
    buyerName: 'John Buyer',
    sellerName: 'Sarah Seller',
    shopName: 'Pizza Palace',
    lastMessage: 'Hello',
    lastMessageTimestamp: now,
    createdAt: now,
    updatedAt: now,
  );

  setUp(() {
    mockRepository = MockIChatRepository();
  });

  group('initial state', () {
    blocTest<ChatSupportBloc, ChatSupportState>(
      'is ChatSupportInitial',
      build: () => ChatSupportBloc(repository: mockRepository),
      verify: (bloc) {
        expect(bloc.state, isA<ChatSupportInitial>());
      },
    );
  });

  group('LoadChatSessionsEvent', () {
    test('subscribes to conversations stream for seller', () async {
      final conversationsCtrl = StreamController<List<ConversationModel>>();
      when(() => mockRepository.getConversationsForUser(testSellerId,
              isSeller: true))
          .thenAnswer((_) => conversationsCtrl.stream);

      final bloc = ChatSupportBloc(repository: mockRepository);
      bloc.add(LoadChatSessionsEvent(testSellerId));
      await Future.delayed(const Duration(milliseconds: 50));

      conversationsCtrl.add([testConversation]);
      await Future.delayed(const Duration(milliseconds: 50));

      final state = bloc.state;
      expect(state, isA<ChatSupportLoaded>());
      expect((state as ChatSupportLoaded).conversations.length, 1);
      expect(state.conversations.first.id, testConversationId);

      await conversationsCtrl.close();
      bloc.close();
    });
  });

  group('LoadChatSessionsEvent error handling', () {
    test('handles stream error and emits ChatSupportError', () async {
      final conversationsCtrl = StreamController<List<ConversationModel>>();
      when(() => mockRepository.getConversationsForUser(
          testSellerId, isSeller: true))
          .thenAnswer((_) => conversationsCtrl.stream);

      final bloc = ChatSupportBloc(repository: mockRepository);
      bloc.add(LoadChatSessionsEvent(testSellerId));
      await Future.delayed(const Duration(milliseconds: 50));

      conversationsCtrl.addError('Missing index');
      await Future.delayed(const Duration(milliseconds: 50));

      expect(bloc.state, isA<ChatSupportError>());

      await conversationsCtrl.close();
      bloc.close();
    });
  });

  group('SendMessageEvent', () {
    blocTest<ChatSupportBloc, ChatSupportState>(
      'sends message through repository with seller role',
      setUp: () {
        when(() => mockRepository.sendMessage(
              conversationId: any(named: 'conversationId'),
              text: any(named: 'text'),
              senderId: any(named: 'senderId'),
              senderRole: any(named: 'senderRole'),
            )).thenAnswer((_) async {});
      },
      build: () => ChatSupportBloc(repository: mockRepository),
      seed: () => ChatSupportLoaded(
        currentUserId: testSellerId,
        conversations: [testConversation],
        selectedConversationId: testConversationId,
      ),
      act: (bloc) =>
          bloc.add(SendMessageEvent(testConversationId, 'Reply message')),
      expect: () => [
        isA<ChatSupportLoaded>().having(
            (s) => s.isSendingMessage, 'isSendingMessage', true),
        isA<ChatSupportLoaded>().having(
            (s) => s.isSendingMessage, 'isSendingMessage', false),
      ],
      verify: (_) {
        verify(() => mockRepository.sendMessage(
              conversationId: testConversationId,
              text: 'Reply message',
              senderId: testSellerId,
              senderRole: 'seller',
            )).called(1);
      },
    );

    blocTest<ChatSupportBloc, ChatSupportState>(
      'does not send empty message',
      build: () => ChatSupportBloc(repository: mockRepository),
      seed: () => ChatSupportLoaded(
        currentUserId: testSellerId,
        conversations: [testConversation],
        selectedConversationId: testConversationId,
      ),
      act: (bloc) =>
          bloc.add(SendMessageEvent(testConversationId, '  ')),
      verify: (_) {
        verifyNever(() => mockRepository.sendMessage(
              conversationId: any(named: 'conversationId'),
              text: any(named: 'text'),
              senderId: any(named: 'senderId'),
              senderRole: any(named: 'senderRole'),
            ));
      },
    );

    blocTest<ChatSupportBloc, ChatSupportState>(
      'handles send failure and emits error state',
      setUp: () {
        when(() => mockRepository.sendMessage(
              conversationId: any(named: 'conversationId'),
              text: any(named: 'text'),
              senderId: any(named: 'senderId'),
              senderRole: any(named: 'senderRole'),
            )).thenThrow(Exception('Network error'));
      },
      build: () => ChatSupportBloc(repository: mockRepository),
      seed: () => ChatSupportLoaded(
        currentUserId: testSellerId,
        conversations: [testConversation],
        selectedConversationId: testConversationId,
      ),
      act: (bloc) =>
          bloc.add(SendMessageEvent(testConversationId, 'Hi')),
      expect: () => [
        isA<ChatSupportLoaded>().having(
            (s) => s.isSendingMessage, 'isSendingMessage', true),
        isA<ChatSupportLoaded>().having(
            (s) => s.isSendingMessage, 'isSendingMessage', false),
      ],
      verify: (bloc) {
        final state = bloc.state as ChatSupportLoaded;
        expect(state.errorMessage, isNotNull);
      },
    );
  });
}
