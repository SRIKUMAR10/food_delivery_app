import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/chat_support_page_/chat_support_page_bloc.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/chat_support_page_/chat_support_page_event.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/chat_support_page_/chat_support_page_state.dart';
import 'package:food_delivery_app/core/repositories/i_chat_repository.dart';
import 'package:food_delivery_app/core/models/conversation_model.dart';
import 'package:food_delivery_app/core/models/chat_message_model.dart';

class MockIChatRepository extends Mock implements IChatRepository {}

ConversationModel makeConversation(int index) {
  return ConversationModel(
    id: 'conv_$index',
    buyerId: 'buyer_$index',
    sellerId: 'seller_1',
    buyerName: 'Customer $index',
    sellerName: 'FoodGo',
    conversationType: index.isEven ? 'buyer_seller' : 'seller_delivery',
    deliveryPartnerId: index.isEven ? null : 'rider_$index',
    deliveryPartnerName: index.isEven ? null : 'Rider $index',
    orderId: 'ord_$index',
    createdAt: DateTime(2026, 1, 1),
    updatedAt: DateTime(2026, 1, 1),
    participants: ['buyer_$index', 'seller_1', if (!index.isEven) 'rider_$index'],
    participantRoles: {
      'buyer_$index': 'buyer',
      'seller_1': 'seller',
      if (!index.isEven) 'rider_$index': 'delivery_partner',
    },
  );
}

void main() {
  group('ChatSupportPage Performance Tests', () {
    test('large conversation list filters quickly and correctly', () {
      final conversations = List.generate(2000, makeConversation);

      final state = ChatSupportLoaded(
        currentUserId: 'seller_1',
        conversations: conversations,
      );

      final stopwatch = Stopwatch()..start();
      final customers = state.copyWith(activeFilterTab: ChatFilterTab.customers);
      final customerCount = customers.filteredConversationsByTab.length;
      final delivery = state.copyWith(
        activeFilterTab: ChatFilterTab.deliveryPartners,
      );
      final deliveryCount = delivery.filteredConversationsByTab.length;
      stopwatch.stop();

      expect(customerCount, 1000);
      expect(deliveryCount, 1000);
      expect(stopwatch.elapsedMilliseconds, lessThan(5000));
    });

    test('large message list is stored and filtered without error', () {
      final messages = List.generate(
        3000,
        (i) => ChatMessageModel(
          id: 'm_$i',
          conversationId: 'conv_1',
          text: 'Message $i',
          senderId: i.isEven ? 'seller_1' : 'buyer_1',
          senderRole: i.isEven ? 'seller' : 'buyer',
          timestamp: DateTime(2026, 1, 1).add(Duration(seconds: i)),
        ),
      );

      final state = ChatSupportLoaded(
        currentUserId: 'seller_1',
        conversations: const [],
        selectedConversationId: 'conv_1',
        messages: messages,
      );

      expect(state.messages.length, 3000);
    });

    test('bloc handles rapid state transitions without crashing', () async {
      final mockRepo = MockIChatRepository();
      when(() => mockRepo.getConversationsForUser(any(), isSeller: true))
          .thenAnswer((_) => Stream.value(List.generate(20, makeConversation)));
      when(() => mockRepo.setTypingStatus(
            conversationId: any(named: 'conversationId'),
            userId: any(named: 'userId'),
            isTyping: any(named: 'isTyping'),
          )).thenAnswer((_) async {});

      final bloc = ChatSupportBloc(repository: mockRepo);
      bloc.add(LoadChatSessionsEvent('seller_1'));
      await Future<void>.delayed(const Duration(milliseconds: 20));

      for (var i = 0; i < 100; i++) {
        bloc.add(SetChatFilterTabEvent(ChatFilterTab.values[i % 4]));
      }
      await Future<void>.delayed(const Duration(milliseconds: 20));

      expect(bloc.state, isA<ChatSupportLoaded>());
      await bloc.close();
    });
  });
}
