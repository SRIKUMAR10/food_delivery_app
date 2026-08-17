import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/chat_support_page_/chat_support_page_bloc.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/chat_support_page_/chat_support_page_event.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/chat_support_page_/chat_support_page_state.dart';
import 'package:food_delivery_app/core/repositories/i_chat_repository.dart';
import 'package:food_delivery_app/core/models/conversation_model.dart';

class MockIChatRepository extends Mock implements IChatRepository {}

ConversationModel makeConversation({String id = 'conv_1', String? orderId}) {
  return ConversationModel(
    id: id,
    buyerId: 'buyer_1',
    sellerId: 'seller_1',
    buyerName: 'Aarav',
    sellerName: 'FoodGo',
    orderId: orderId,
    createdAt: DateTime(2026, 1, 1),
    updatedAt: DateTime(2026, 1, 1),
    participants: const ['buyer_1', 'seller_1'],
    participantRoles: const {'buyer_1': 'buyer', 'seller_1': 'seller'},
  );
}

void main() {
  group('ChatSupportPage State Restoration Tests', () {
    late MockIChatRepository mockRepository;

    setUp(() {
      mockRepository = MockIChatRepository();
    });

    blocTest<ChatSupportBloc, ChatSupportState>(
      'restores the active conversation via initialConversationId',
      build: () {
        when(() => mockRepository.getConversationsForUser(any(), isSeller: true))
            .thenAnswer((_) => Stream.value([makeConversation(id: 'conv_1')]));
        when(() => mockRepository.getMessagesStream(any()))
            .thenAnswer((_) => const Stream.empty());
        when(() => mockRepository.getTypingStatusStream(any()))
            .thenAnswer((_) => const Stream.empty());
        when(() => mockRepository.markConversationRead(any(), any(), any()))
            .thenAnswer((_) async {});
        return ChatSupportBloc(repository: mockRepository);
      },
      act: (bloc) => bloc.add(LoadChatSessionsEvent(
        'seller_1',
        initialConversationId: 'conv_1',
      )),
      expect: () => [
        isA<ChatSupportLoading>(),
        isA<ChatSupportLoaded>(),
        isA<ChatSupportLoaded>().having(
          (s) => s.selectedConversationId,
          'selectedConversationId',
          'conv_1',
        ),
      ],
    );

    blocTest<ChatSupportBloc, ChatSupportState>(
      'restores an order-linked conversation via initialOrderId',
      build: () {
        when(() => mockRepository.getConversationsForUser(any(), isSeller: true))
            .thenAnswer((_) => Stream.value([
                  makeConversation(id: 'conv_order', orderId: 'ord_1'),
                ]));
        when(() => mockRepository.getMessagesStream(any()))
            .thenAnswer((_) => const Stream.empty());
        when(() => mockRepository.getTypingStatusStream(any()))
            .thenAnswer((_) => const Stream.empty());
        when(() => mockRepository.markConversationRead(any(), any(), any()))
            .thenAnswer((_) async {});
        return ChatSupportBloc(repository: mockRepository);
      },
      act: (bloc) => bloc.add(LoadChatSessionsEvent(
        'seller_1',
        initialOrderId: 'ord_1',
      )),
      expect: () => [
        isA<ChatSupportLoading>(),
        isA<ChatSupportLoaded>(),
        isA<ChatSupportLoaded>().having(
          (s) => s.selectedConversationId,
          'selectedConversationId',
          'conv_order',
        ),
      ],
    );
  });
}
