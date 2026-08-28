import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:food_delivery_app/core/models/chat_message_model.dart';
import 'package:food_delivery_app/core/models/conversation_model.dart';
import 'package:food_delivery_app/core/repositories/i_chat_repository.dart';
import 'package:food_delivery_app/core/services/i_auth_service.dart';
import 'package:food_delivery_app/features/buyer_bloc_architecture/Chat_Page/buyer_chat_bloc.dart';
import 'package:food_delivery_app/features/buyer_bloc_architecture/Chat_Page/buyer_chat_event.dart';
import 'package:food_delivery_app/features/buyer_bloc_architecture/Chat_Page/buyer_chat_state.dart';

class MockChatRepository extends Mock implements IChatRepository {}
class MockAuthService extends Mock implements IAuthService {}

void main() {
  late MockChatRepository mockChatRepo;
  late MockAuthService mockAuthService;
  late BuyerChatBloc buyerChatBloc;
  late StreamController<List<ConversationModel>> conversationsStreamController;
  late StreamController<List<ChatMessageModel>> messagesStreamController;
  late StreamController<Map<String, bool>> typingStatusStreamController;

  final sampleConversation = ConversationModel(
    id: 'conv_101',
    buyerId: 'buyer_123',
    buyerName: 'Karthik',
    sellerId: 'seller_456',
    sellerName: 'Spice Kitchen',
    deliveryPartnerId: 'rider_789',
    deliveryPartnerName: 'Ravi Kumar',
    deliveryPartnerPhone: '9876543210',
    buyerUnreadCount: 2,
    sellerUnreadCount: 0,
    deliveryUnreadCount: 1,
    lastMessage: 'Your order is picked up!',
    lastMessageTimestamp: DateTime.now(),
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
    conversationType: 'buyer_delivery',
  );

  final sampleMessage = ChatMessageModel(
    id: 'msg_1',
    conversationId: 'conv_101',
    text: 'I am at the gate',
    senderId: 'buyer_123',
    senderRole: 'buyer',
    timestamp: DateTime.now(),
    isRead: false,
  );

  setUp(() {
    mockChatRepo = MockChatRepository();
    mockAuthService = MockAuthService();
    conversationsStreamController = StreamController<List<ConversationModel>>.broadcast();
    messagesStreamController = StreamController<List<ChatMessageModel>>.broadcast();
    typingStatusStreamController = StreamController<Map<String, bool>>.broadcast();

    when(() => mockAuthService.authStateChanges).thenAnswer((_) => const Stream.empty());
    when(() => mockAuthService.currentUserId).thenReturn('buyer_123');

    when(() => mockChatRepo.getConversationsForUser(any(), role: any(named: 'role'), isSeller: any(named: 'isSeller')))
        .thenAnswer((_) => conversationsStreamController.stream);
    when(() => mockChatRepo.getMessagesStream(any()))
        .thenAnswer((_) => messagesStreamController.stream);
    when(() => mockChatRepo.getTypingStatusStream(any()))
        .thenAnswer((_) => typingStatusStreamController.stream);
    when(() => mockChatRepo.markConversationRead(any(), any(), any()))
        .thenAnswer((_) async {});
    when(() => mockChatRepo.markMessagesAsRead(conversationId: any(named: 'conversationId'), readerId: any(named: 'readerId')))
        .thenAnswer((_) async {});
    when(() => mockChatRepo.sendMessage(
          conversationId: any(named: 'conversationId'),
          text: any(named: 'text'),
          senderId: any(named: 'senderId'),
          senderRole: any(named: 'senderRole'),
          receiverId: any(named: 'receiverId'),
          messageType: any(named: 'messageType'),
          mediaUrl: any(named: 'mediaUrl'),
          fileName: any(named: 'fileName'),
          fileSize: any(named: 'fileSize'),
          duration: any(named: 'duration'),
        )).thenAnswer((_) async {});

    buyerChatBloc = BuyerChatBloc(
      repository: mockChatRepo,
      authService: mockAuthService,
    );
  });

  tearDown(() {
    conversationsStreamController.close();
    messagesStreamController.close();
    typingStatusStreamController.close();
    buyerChatBloc.close();
  });

  group('Real-Time In-App Chat & Communication Tests', () {
    test('Unread count calculation for user matches unreadCounts map', () {
      expect(sampleConversation.unreadCountForUser('buyer_123'), equals(2));
      expect(sampleConversation.unreadCountForUser('seller_456'), equals(0));
      expect(sampleConversation.unreadCountForUser('rider_789'), equals(1));
    });

    test('Loads conversations stream and emits BuyerChatLoaded state with active threads', () async {
      final expectation = expectLater(
        buyerChatBloc.stream,
        emitsInOrder([
          isA<BuyerChatLoading>(),
          predicate<BuyerChatState>((state) {
            if (state is! BuyerChatLoaded) return false;
            return state.conversations.length == 1 &&
                state.conversations.first.id == 'conv_101';
          }),
        ]),
      );

      buyerChatBloc.add(const LoadBuyerConversations());
      await Future.delayed(const Duration(milliseconds: 50));
      conversationsStreamController.add([sampleConversation]);

      await expectation;
    });

    test('Selecting conversation marks it read and listens to live messages stream', () async {
      buyerChatBloc.add(const LoadBuyerConversations());
      await Future.delayed(const Duration(milliseconds: 50));
      conversationsStreamController.add([sampleConversation]);
      await buyerChatBloc.stream.firstWhere((s) => s is BuyerChatLoaded);

      buyerChatBloc.add(const SelectBuyerConversation('conv_101'));
      await Future.delayed(const Duration(milliseconds: 50));
      messagesStreamController.add([sampleMessage]);

      await expectLater(
        buyerChatBloc.stream,
        emits(predicate<BuyerChatState>((state) {
          if (state is! BuyerChatLoaded) return false;
          return state.selectedConversationId == 'conv_101' &&
              state.messages.length == 1 &&
              state.messages.first.text == 'I am at the gate';
        })),
      );

      verify(() => mockChatRepo.markMessagesAsRead(conversationId: 'conv_101', readerId: 'buyer_123')).called(1);
    });

    test('SendOrderQuickReply dispatches message to repository in real time', () async {
      buyerChatBloc.add(const LoadBuyerConversations());
      await Future.delayed(const Duration(milliseconds: 50));
      conversationsStreamController.add([sampleConversation]);
      await buyerChatBloc.stream.firstWhere((s) => s is BuyerChatLoaded);

      buyerChatBloc.add(const SelectBuyerConversation('conv_101'));
      await Future.delayed(const Duration(milliseconds: 50));
      messagesStreamController.add([sampleMessage]);
      await buyerChatBloc.stream.firstWhere((s) => s is BuyerChatLoaded && s.selectedConversationId == 'conv_101');

      buyerChatBloc.add(const SendOrderQuickReply('conv_101', 'Please leave at the door 🚪'));

      await Future.delayed(const Duration(milliseconds: 100));

      verify(() => mockChatRepo.sendMessage(
            conversationId: 'conv_101',
            text: 'Please leave at the door 🚪',
            senderId: 'buyer_123',
            senderRole: 'buyer',
            receiverId: any(named: 'receiverId'),
            messageType: any(named: 'messageType'),
          )).called(1);
    });
  });
}
