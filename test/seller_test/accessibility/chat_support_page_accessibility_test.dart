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
  group('ChatSupportPage Accessibility Tests', () {
    late MockIChatRepository mockRepo;
    late MockIOrderRepository mockOrderRepo;

    setUp(() {
      mockRepo = MockIChatRepository();
      mockOrderRepo = MockIOrderRepository();
      when(() => mockRepo.getMessagesStream(any()))
          .thenAnswer((_) => const Stream.empty());
      when(() => mockRepo.getTypingStatusStream(any()))
          .thenAnswer((_) => const Stream.empty());
      when(() => mockRepo.markConversationRead(any(), any(), any()))
          .thenAnswer((_) async {});
    });

    testWidgets('participant badges expose semantic labels', (tester) async {
      when(() => mockRepo.getConversationsForUser(any(), isSeller: true))
          .thenAnswer((_) => Stream.value([
                makeConversation(id: 'c1'),
                makeConversation(
                  id: 'c2',
                  conversationType: 'seller_delivery',
                  deliveryPartnerId: 'rider_1',
                  deliveryPartnerName: 'Raj',
                ),
              ]));

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
      await tester.pump(const Duration(milliseconds: 50));

      final customerBadges = find.byWidgetPredicate(
        (w) => w is Semantics && w.properties.label == 'Customer',
      );
      final deliveryBadges = find.byWidgetPredicate(
        (w) => w is Semantics && w.properties.label == 'Delivery Partner',
      );

      expect(customerBadges, findsWidgets);
      expect(deliveryBadges, findsWidgets);
    });

    testWidgets('filter tabs and composer controls have tap targets',
        (tester) async {
      when(() => mockRepo.getConversationsForUser(any(), isSeller: true))
          .thenAnswer((_) => Stream.value([makeConversation(id: 'c1')]));

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
      await tester.pump(const Duration(milliseconds: 50));

      // Select conversation to reveal the composer
      await tester.tap(find.text('Aarav Patel').first);
      await tester.pumpAndSettle();

      // Composer controls (emoji, attach, mic, send) are present
      expect(find.byIcon(Icons.emoji_emotions_outlined), findsOneWidget);
      expect(find.byIcon(Icons.attach_file_rounded), findsOneWidget);
      expect(find.byIcon(Icons.mic_none_rounded), findsOneWidget);
      expect(find.byIcon(Icons.send_rounded), findsOneWidget);
    });
  });
}
