import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/chat_support_page_/chat_support_page_bloc.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/chat_support_page_/chat_support_page_event.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/chat_support_page_/chat_support_page_state.dart';
import 'package:food_delivery_app/core/repositories/i_chat_repository.dart';
import 'package:food_delivery_app/core/models/conversation_model.dart';

class MockIChatRepository extends Mock implements IChatRepository {}

ConversationModel makeConversation({
  String id = 'conv_1',
  String buyerId = 'buyer_1',
  String sellerId = 'seller_1',
  String buyerName = 'Aarav Patel',
  String sellerName = 'FoodGo',
  String? orderId,
  String conversationType = 'buyer_seller',
  String? deliveryPartnerId,
  String? deliveryPartnerName,
}) {
  return ConversationModel(
    id: id,
    buyerId: buyerId,
    sellerId: sellerId,
    buyerName: buyerName,
    sellerName: sellerName,
    orderId: orderId,
    conversationType: conversationType,
    deliveryPartnerId: deliveryPartnerId,
    deliveryPartnerName: deliveryPartnerName,
    createdAt: DateTime(2026, 1, 1),
    updatedAt: DateTime(2026, 1, 1),
    participants: [
      buyerId,
      sellerId,
      if (deliveryPartnerId != null) deliveryPartnerId,
    ],
    participantRoles: {
      buyerId: 'buyer',
      sellerId: 'seller',
      if (deliveryPartnerId != null) deliveryPartnerId: 'delivery_partner',
    },
  );
}

void main() {
  group('ChatSupportBloc', () {
    late ChatSupportBloc bloc;
    late MockIChatRepository mockRepository;

    setUp(() {
      mockRepository = MockIChatRepository();
      bloc = ChatSupportBloc(repository: mockRepository);
    });

    tearDown(() {
      bloc.close();
    });

    test('initial state is ChatSupportInitial', () {
      expect(bloc.state, isA<ChatSupportInitial>());
    });

    blocTest<ChatSupportBloc, ChatSupportState>(
      'emits [Loading, Loaded] when LoadChatSessionsEvent is added',
      build: () {
        when(() => mockRepository.getConversationsForUser(any(), isSeller: true))
            .thenAnswer((_) => Stream.value([]));
        return bloc;
      },
      act: (bloc) => bloc.add(LoadChatSessionsEvent('seller1')),
      expect: () => [
        isA<ChatSupportLoading>(),
        isA<ChatSupportLoaded>(),
      ],
    );

    blocTest<ChatSupportBloc, ChatSupportState>(
      'selecting a session marks it read and loads messages + typing stream',
      build: () {
        when(() => mockRepository.getMessagesStream(any()))
            .thenAnswer((_) => const Stream.empty());
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
        isA<ChatSupportLoaded>().having(
          (s) => s.selectedConversationId,
          'selectedConversationId',
          'conv_1',
        ),
      ],
      verify: (_) {
        verify(() => mockRepository.markConversationRead('conv_1', 'seller1', true))
            .called(1);
      },
    );

    blocTest<ChatSupportBloc, ChatSupportState>(
      'deselecting a session clears typing and selection',
      build: () => bloc,
      seed: () => ChatSupportLoaded(
        currentUserId: 'seller1',
        conversations: [makeConversation()],
        selectedConversationId: 'conv_1',
        typingUsers: const {'buyer_1': true},
      ),
      act: (bloc) => bloc.add(SelectChatSessionEvent('')),
      expect: () => [
        isA<ChatSupportLoaded>()
            .having((s) => s.selectedConversationId, 'selected', isNull)
            .having((s) => s.typingUsers, 'typingUsers', isEmpty),
      ],
    );

    blocTest<ChatSupportBloc, ChatSupportState>(
      'SetTypingStatusEvent(true) marks typing through repository',
      build: () {
        when(() => mockRepository.setTypingStatus(
              conversationId: any(named: 'conversationId'),
              userId: any(named: 'userId'),
              isTyping: any(named: 'isTyping'),
            )).thenAnswer((_) async {});
        return bloc;
      },
      seed: () => ChatSupportLoaded(
        currentUserId: 'seller1',
        conversations: [makeConversation()],
        selectedConversationId: 'conv_1',
      ),
      act: (bloc) => bloc.add(SetTypingStatusEvent(true)),
      verify: (_) {
        verify(() => mockRepository.setTypingStatus(
              conversationId: 'conv_1',
              userId: 'seller1',
              isTyping: true,
            )).called(1);
      },
    );

    blocTest<ChatSupportBloc, ChatSupportState>(
      'SetTypingStatusEvent(false) clears typing through repository',
      build: () {
        when(() => mockRepository.setTypingStatus(
              conversationId: any(named: 'conversationId'),
              userId: any(named: 'userId'),
              isTyping: any(named: 'isTyping'),
            )).thenAnswer((_) async {});
        return bloc;
      },
      seed: () => ChatSupportLoaded(
        currentUserId: 'seller1',
        conversations: [makeConversation()],
        selectedConversationId: 'conv_1',
      ),
      act: (bloc) => bloc.add(SetTypingStatusEvent(false)),
      verify: (_) {
        verify(() => mockRepository.setTypingStatus(
              conversationId: 'conv_1',
              userId: 'seller1',
              isTyping: false,
            )).called(1);
      },
    );

    blocTest<ChatSupportBloc, ChatSupportState>(
      'SetChatFilterTabEvent filters by delivery partners',
      build: () => bloc,
      seed: () => ChatSupportLoaded(
        currentUserId: 'seller1',
        conversations: [
          makeConversation(id: 'c1'),
          makeConversation(
            id: 'c2',
            conversationType: 'seller_delivery',
            deliveryPartnerId: 'rider_1',
            deliveryPartnerName: 'Raj',
          ),
        ],
      ),
      act: (bloc) => bloc.add(const SetChatFilterTabEvent(ChatFilterTab.deliveryPartners)),
      expect: () => [
        isA<ChatSupportLoaded>()
            .having((s) => s.activeFilterTab, 'tab', ChatFilterTab.deliveryPartners)
            .having(
              (s) => s.filteredConversationsByTab.length,
              'deliveryCount',
              1,
            ),
      ],
    );

    blocTest<ChatSupportBloc, ChatSupportState>(
      'StartOrderDeliveryPartnerChatEvent creates and opens seller_delivery chat',
      build: () {
        when(() => mockRepository.getConversationBetween(
              user1Id: any(named: 'user1Id'),
              user2Id: any(named: 'user2Id'),
              orderId: any(named: 'orderId'),
              type: any(named: 'type'),
            )).thenAnswer((_) async => null);
        when(() => mockRepository.createConversation(
              buyerId: any(named: 'buyerId'),
              buyerName: any(named: 'buyerName'),
              sellerId: any(named: 'sellerId'),
              sellerName: any(named: 'sellerName'),
              orderId: any(named: 'orderId'),
              orderTitle: any(named: 'orderTitle'),
              orderTotal: any(named: 'orderTotal'),
              deliveryPartnerId: any(named: 'deliveryPartnerId'),
              deliveryPartnerName: any(named: 'deliveryPartnerName'),
              deliveryPartnerPhone: any(named: 'deliveryPartnerPhone'),
              deliveryPartnerImageUrl: any(named: 'deliveryPartnerImageUrl'),
              conversationType: any(named: 'conversationType'),
              participants: any(named: 'participants'),
              participantRoles: any(named: 'participantRoles'),
            )).thenAnswer((_) async => 'conv_delivery');
        when(() => mockRepository.getMessagesStream(any()))
            .thenAnswer((_) => const Stream.empty());
        when(() => mockRepository.getTypingStatusStream(any()))
            .thenAnswer((_) => const Stream.empty());
        when(() => mockRepository.markConversationRead(any(), any(), any()))
            .thenAnswer((_) async {});
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
          (s) => s.selectedConversationId,
          'selectedConversationId',
          'conv_delivery',
        ),
      ],
      verify: (_) {
        verify(() => mockRepository.createConversation(
              buyerId: any(named: 'buyerId'),
              buyerName: any(named: 'buyerName'),
              sellerId: 'seller1',
              sellerName: any(named: 'sellerName'),
              orderId: 'ord_1',
              orderTitle: any(named: 'orderTitle'),
              orderTotal: any(named: 'orderTotal'),
              deliveryPartnerId: 'rider_1',
              deliveryPartnerName: 'Raj',
              deliveryPartnerPhone: any(named: 'deliveryPartnerPhone'),
              deliveryPartnerImageUrl: any(named: 'deliveryPartnerImageUrl'),
              conversationType: 'seller_delivery',
              participants: any(named: 'participants'),
              participantRoles: any(named: 'participantRoles'),
            )).called(1);
      },
    );

    blocTest<ChatSupportBloc, ChatSupportState>(
      'SendMessageEvent fails gracefully with error message',
      build: () {
        when(() => mockRepository.sendMessage(
              conversationId: any(named: 'conversationId'),
              text: any(named: 'text'),
              senderId: any(named: 'senderId'),
              senderRole: any(named: 'senderRole'),
            )).thenThrow(Exception('NetworkError'));
        return bloc;
      },
      seed: () => ChatSupportLoaded(
        currentUserId: 'seller1',
        conversations: [makeConversation()],
        selectedConversationId: 'conv_1',
      ),
      act: (bloc) => bloc.add(SendMessageEvent('conv_1', 'Hello')),
      expect: () => [
        isA<ChatSupportLoaded>()
            .having((s) => s.isSendingMessage, 'isSending', true),
        isA<ChatSupportLoaded>()
            .having((s) => s.isSendingMessage, 'isSending', false)
            .having((s) => s.errorMessage, 'error', contains('Failed to send message')),
      ],
    );
  });

  group('ChatSupportLoaded state helpers', () {
    test('filteredConversationsByTab returns correct buckets', () {
      final conversations = [
        makeConversation(id: 'buyer_chat'),
        makeConversation(
          id: 'delivery_chat',
          conversationType: 'seller_delivery',
          deliveryPartnerId: 'rider_1',
          deliveryPartnerName: 'Raj',
        ),
        makeConversation(id: 'order_chat', orderId: 'ord_1'),
      ];

      final all = ChatSupportLoaded(
        currentUserId: 'seller1',
        conversations: conversations,
      );
      expect(all.filteredConversationsByTab.length, 3);

      final customers = all.copyWith(activeFilterTab: ChatFilterTab.customers);
      expect(customers.filteredConversationsByTab.length, 2);

      final delivery =
          all.copyWith(activeFilterTab: ChatFilterTab.deliveryPartners);
      expect(delivery.filteredConversationsByTab.length, 1);
      expect(delivery.filteredConversationsByTab.first.id, 'delivery_chat');

      final orders = all.copyWith(activeFilterTab: ChatFilterTab.orders);
      expect(orders.filteredConversationsByTab.length, 1);
      expect(orders.filteredConversationsByTab.first.id, 'order_chat');
    });

    test('isOtherUserTyping / otherUserTypingName resolve correctly', () {
      final state = ChatSupportLoaded(
        currentUserId: 'seller1',
        conversations: [
          makeConversation(id: 'conv_1', buyerId: 'buyer_1', buyerName: 'Aarav'),
        ],
        selectedConversationId: 'conv_1',
        typingUsers: const {'buyer_1': true},
      );

      expect(state.isOtherUserTyping, isTrue);
      expect(state.otherUserTypingName, 'Aarav');

      final selfTyping = state.copyWith(typingUsers: const {'seller1': true});
      expect(selfTyping.isOtherUserTyping, isFalse);
    });
  });
}
