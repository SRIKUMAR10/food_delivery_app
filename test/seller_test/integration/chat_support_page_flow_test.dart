import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mocktail/mocktail.dart';
import 'package:food_delivery_app/core/repositories/i_chat_repository.dart';
import 'package:food_delivery_app/core/repositories/i_order_repository.dart';
import 'package:food_delivery_app/core/models/conversation_model.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/chat_support_page_/chat_support_page_bloc.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/chat_support_page_/chat_support_page_event.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/chat_support_page_/chat_support_page_ui.dart';

class MockIChatRepository extends Mock implements IChatRepository {}
class MockIOrderRepository extends Mock implements IOrderRepository {}

ConversationModel makeConversation({
  String id = 'conv_1',
  String buyerName = 'Aarav Patel',
  String conversationType = 'buyer_seller',
  String? deliveryPartnerId,
  String? deliveryPartnerName,
}) {
  return ConversationModel(
    id: id,
    buyerId: 'buyer_1',
    sellerId: 'seller_1',
    buyerName: buyerName,
    sellerName: 'FoodGo',
    lastMessage: 'Hello',
    conversationType: conversationType,
    deliveryPartnerId: deliveryPartnerId,
    deliveryPartnerName: deliveryPartnerName,
    createdAt: DateTime(2026, 1, 1),
    updatedAt: DateTime(2026, 1, 1),
    participants: [
      'buyer_1',
      'seller_1',
      if (deliveryPartnerId != null) deliveryPartnerId,
    ],
    participantRoles: {
      'buyer_1': 'buyer',
      'seller_1': 'seller',
      if (deliveryPartnerId != null) deliveryPartnerId: 'delivery_partner',
    },
  );
}

void main() {
  group('ChatSupportPage Integration Flow', () {
    late MockIChatRepository mockRepo;
    late MockIOrderRepository mockOrderRepo;

    setUp(() {
      mockRepo = MockIChatRepository();
      mockOrderRepo = MockIOrderRepository();
      when(() => mockOrderRepo.getOrderById(any())).thenAnswer((_) async => null);
      when(() => mockOrderRepo.streamOrderById(any()))
          .thenAnswer((_) => const Stream.empty());
      when(() => mockRepo.getMessagesStream(any()))
          .thenAnswer((_) => const Stream.empty());
      when(() => mockRepo.getTypingStatusStream(any()))
          .thenAnswer((_) => const Stream.empty());
      when(() => mockRepo.markConversationRead(any(), any(), any()))
          .thenAnswer((_) async {});
      when(() => mockRepo.setTypingStatus(
            conversationId: any(named: 'conversationId'),
            userId: any(named: 'userId'),
            isTyping: any(named: 'isTyping'),
          )).thenAnswer((_) async {});
    });

    testWidgets('seller selects conversation, sends message, filters tabs',
        (tester) async {
      tester.view.physicalSize = const Size(400, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      when(() => mockRepo.getConversationsForUser(any(), isSeller: true))
          .thenAnswer((_) => Stream.value([
                makeConversation(id: 'conv_1', buyerName: 'Aarav Patel'),
                makeConversation(
                  id: 'conv_2',
                  conversationType: 'seller_delivery',
                  deliveryPartnerId: 'rider_1',
                  deliveryPartnerName: 'Raj',
                ),
              ]));
      when(() => mockRepo.sendMessage(
            conversationId: any(named: 'conversationId'),
            text: any(named: 'text'),
            senderId: any(named: 'senderId'),
            senderRole: any(named: 'senderRole'),
          )).thenAnswer((_) async {});

      final bloc = ChatSupportBloc(repository: mockRepo)
        ..add(LoadChatSessionsEvent('seller_1'));
      addTearDown(bloc.close);

      await tester.pumpWidget(MultiRepositoryProvider(
        providers: [
          RepositoryProvider<IChatRepository>.value(value: mockRepo),
          RepositoryProvider<IOrderRepository>.value(value: mockOrderRepo),
        ],
        child: BlocProvider<ChatSupportBloc>.value(
          value: bloc,
          child: const MaterialApp(home: ChatSupportView()),
        ),
      ));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Select buyer conversation
      await tester.tap(find.text('Aarav Patel').first);
      await tester.pumpAndSettle();

      // Type and send a message
      await tester.enterText(find.byType(TextField), 'Your order is ready');
      await tester.pump();
      await tester.tap(find.byIcon(Icons.send_rounded));
      await tester.pumpAndSettle();

      verify(() => mockRepo.sendMessage(
            conversationId: 'conv_1',
            text: 'Your order is ready',
            senderId: 'seller_1',
            senderRole: 'seller',
          )).called(1);

      // Navigate back to the list
      await tester.tap(find.byIcon(Icons.arrow_back_rounded));
      await tester.pumpAndSettle();

      // Filter to delivery partners
      final tabBar = find.byKey(const ValueKey('filterTabs'));
      await tester.dragUntilVisible(
        find.text('Delivery Partners'),
        tabBar,
        const Offset(-80, 0),
      );
      await tester.ensureVisible(find.text('Delivery Partners'));
      await tester.pump();
      await tester.tap(find.text('Delivery Partners'));
      await tester.pumpAndSettle();

      expect(find.text('Raj'), findsWidgets);
      expect(find.text('Aarav Patel'), findsNothing);
    });
  });
}
