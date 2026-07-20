import 'dart:async';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:food_delivery_app/core/models/conversation_model.dart';
import 'package:food_delivery_app/core/repositories/i_chat_repository.dart';
import 'package:food_delivery_app/core/services/i_auth_service.dart';
import 'package:food_delivery_app/features/buyer_bloc_architecture/Chat_Page/buyer_chat_bloc.dart';
import 'package:food_delivery_app/features/buyer_bloc_architecture/Chat_Page/buyer_chat_event.dart';
import 'package:food_delivery_app/features/buyer_bloc_architecture/Chat_Page/buyer_chat_state.dart';

class MockIChatRepository extends Mock implements IChatRepository {}
class MockIAuthService extends Mock implements IAuthService {}

void main() {
  late MockIChatRepository mockRepository;
  late MockIAuthService mockAuthService;
  final now = DateTime(2026, 7, 20, 10, 30);

  const testUserId = 'buyer_1';
  const testConversationId = 'conv_1';

  final testConversation = ConversationModel(
    id: testConversationId,
    buyerId: testUserId,
    sellerId: 'seller_1',
    buyerName: 'John',
    sellerName: 'Sarah',
    shopName: 'Pizza Palace',
    lastMessage: 'Hello',
    lastMessageTimestamp: now,
    createdAt: now,
    updatedAt: now,
  );

  setUp(() {
    mockRepository = MockIChatRepository();
    mockAuthService = MockIAuthService();
    when(() => mockAuthService.authStateChanges)
        .thenAnswer((_) => const Stream.empty());
  });

  group('initial state', () {
    blocTest<BuyerChatBloc, BuyerChatState>(
      'is BuyerChatInitial',
      build: () => BuyerChatBloc(
        repository: mockRepository,
        authService: mockAuthService,
      ),
      verify: (bloc) {
        expect(bloc.state, isA<BuyerChatInitial>());
      },
    );
  });

  group('LoadBuyerConversations', () {
    blocTest<BuyerChatBloc, BuyerChatState>(
      'emits BuyerChatError when user is not logged in',
      setUp: () {
        when(() => mockAuthService.currentUserId).thenReturn(null);
        when(() => mockRepository.getConversationsForUser(any(),
                isSeller: any(named: 'isSeller')))
            .thenAnswer((_) => const Stream.empty());
      },
      build: () => BuyerChatBloc(
        repository: mockRepository,
        authService: mockAuthService,
      ),
      act: (bloc) => bloc.add(LoadBuyerConversations()),
      expect: () => [
        isA<BuyerChatError>(),
      ],
    );

    test('subscribes to conversations stream for the current user', () async {
      when(() => mockAuthService.currentUserId).thenReturn(testUserId);
      final conversationsCtrl = StreamController<List<ConversationModel>>();

      when(() => mockRepository.getConversationsForUser(testUserId,
              isSeller: false))
          .thenAnswer((_) => conversationsCtrl.stream);

      final bloc = BuyerChatBloc(
        repository: mockRepository,
        authService: mockAuthService,
      );

      bloc.add(LoadBuyerConversations());
      await Future.delayed(const Duration(milliseconds: 50));

      conversationsCtrl.add([testConversation]);
      await Future.delayed(const Duration(milliseconds: 50));

      final state = bloc.state;
      expect(state, isA<BuyerChatLoaded>());
      expect((state as BuyerChatLoaded).conversations.length, 1);
      expect(state.conversations.first.id, testConversationId);

      await conversationsCtrl.close();
      bloc.close();
    });
  });

  group('LoadBuyerConversations error handling', () {
    test('handles stream error and emits BuyerChatError', () async {
      when(() => mockAuthService.currentUserId).thenReturn(testUserId);
      final conversationsCtrl = StreamController<List<ConversationModel>>();

      when(() => mockRepository.getConversationsForUser(
          testUserId, isSeller: false))
          .thenAnswer((_) => conversationsCtrl.stream);

      final bloc = BuyerChatBloc(
        repository: mockRepository,
        authService: mockAuthService,
      );

      bloc.add(LoadBuyerConversations());
      await Future.delayed(const Duration(milliseconds: 50));

      conversationsCtrl.addError('Firestore permission denied');
      await Future.delayed(const Duration(milliseconds: 50));

      expect(bloc.state, isA<BuyerChatError>());

      await conversationsCtrl.close();
      bloc.close();
    });
  });

  group('SendBuyerMessage', () {
    blocTest<BuyerChatBloc, BuyerChatState>(
      'sends message through repository with buyer role',
      setUp: () {
        when(() => mockAuthService.currentUserId).thenReturn(testUserId);
        when(() => mockRepository.getConversationsForUser(any(),
                isSeller: any(named: 'isSeller')))
            .thenAnswer((_) => const Stream.empty());
        when(() => mockRepository.sendMessage(
              conversationId: any(named: 'conversationId'),
              text: any(named: 'text'),
              senderId: any(named: 'senderId'),
              senderRole: any(named: 'senderRole'),
            )).thenAnswer((_) async {});
      },
      build: () => BuyerChatBloc(
        repository: mockRepository,
        authService: mockAuthService,
      ),
      seed: () => BuyerChatLoaded(
        currentUserId: testUserId,
        conversations: [testConversation],
        selectedConversationId: testConversationId,
      ),
      act: (bloc) => bloc.add(SendBuyerMessage(testConversationId, 'Hello')),
      expect: () => [
        isA<BuyerChatLoaded>().having(
            (s) => s.isSendingMessage, 'isSendingMessage', true),
        isA<BuyerChatLoaded>().having(
            (s) => s.isSendingMessage, 'isSendingMessage', false),
      ],
      verify: (_) {
        verify(() => mockRepository.sendMessage(
              conversationId: testConversationId,
              text: 'Hello',
              senderId: testUserId,
              senderRole: 'buyer',
            )).called(1);
      },
    );

    blocTest<BuyerChatBloc, BuyerChatState>(
      'does not send empty message',
      setUp: () {
        when(() => mockAuthService.currentUserId).thenReturn(testUserId);
      },
      build: () => BuyerChatBloc(
        repository: mockRepository,
        authService: mockAuthService,
      ),
      seed: () => BuyerChatLoaded(
        currentUserId: testUserId,
        conversations: [testConversation],
        selectedConversationId: testConversationId,
      ),
      act: (bloc) => bloc.add(SendBuyerMessage(testConversationId, '  ')),
      verify: (_) {
        verifyNever(() => mockRepository.sendMessage(
              conversationId: any(named: 'conversationId'),
              text: any(named: 'text'),
              senderId: any(named: 'senderId'),
              senderRole: any(named: 'senderRole'),
            ));
      },
    );
  });
}
