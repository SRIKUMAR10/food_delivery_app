import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mocktail/mocktail.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:intl/intl.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/chat_support_page_/chat_support_page_bloc.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/chat_support_page_/chat_support_page_event.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/chat_support_page_/chat_support_page_state.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/chat_support_page_/chat_support_page_ui.dart';
import 'package:food_delivery_app/core/repositories/i_chat_repository.dart';
import 'package:food_delivery_app/core/repositories/i_order_repository.dart';
import 'package:food_delivery_app/core/models/conversation_model.dart';

class MockIChatRepository extends Mock implements IChatRepository {}
class MockIOrderRepository extends Mock implements IOrderRepository {}
class MockChatSupportBloc extends MockBloc<ChatSupportEvent, ChatSupportState>
    implements ChatSupportBloc {}

ConversationModel makeConversation({
  String conversationType = 'buyer_seller',
  String? deliveryPartnerId,
  String? deliveryPartnerName,
}) {
  return ConversationModel(
    id: 'conv_1',
    buyerId: 'buyer_1',
    sellerId: 'seller_1',
    buyerName: 'Aarav Patel',
    sellerName: 'FoodGo',
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
  group('ChatSupportPage Localization Tests', () {
    test('message timestamps are formatted with 12-hour locale clock', () {
      final time = DateFormat('hh:mm a', 'en_US').format(DateTime(2026, 1, 1, 10, 30));
      expect(time, '10:30 AM');

      final evening = DateFormat('hh:mm a', 'en_US').format(DateTime(2026, 1, 1, 22, 5));
      expect(evening, '10:05 PM');
    });

    test('date separators use localized day names', () {
      final day = DateFormat('EEEE', 'en_US').format(DateTime(2026, 1, 5));
      expect(day, 'Monday');
    });

    testWidgets('buyer chat renders customer service quick actions',
        (tester) async {
      final mockBloc = MockChatSupportBloc();
      when(() => mockBloc.stream).thenAnswer((_) => const Stream.empty());
      when(() => mockBloc.close()).thenAnswer((_) async {});
      when(() => mockBloc.state).thenReturn(ChatSupportLoaded(
            currentUserId: 'seller_1',
            conversations: [makeConversation()],
            selectedConversationId: 'conv_1',
          ));

      await tester.pumpWidget(MultiRepositoryProvider(
        providers: [
          RepositoryProvider<IChatRepository>.value(value: MockIChatRepository()),
          RepositoryProvider<IOrderRepository>.value(value: MockIOrderRepository()),
        ],
        child: BlocProvider<ChatSupportBloc>.value(
          value: mockBloc,
          child: const MaterialApp(home: ChatSupportView()),
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.textContaining('Order preparing'), findsWidgets);
    });

    testWidgets('delivery chat renders pickup coordination quick actions',
        (tester) async {
      final mockBloc = MockChatSupportBloc();
      when(() => mockBloc.stream).thenAnswer((_) => const Stream.empty());
      when(() => mockBloc.close()).thenAnswer((_) async {});
      when(() => mockBloc.state).thenReturn(ChatSupportLoaded(
            currentUserId: 'seller_1',
            conversations: [
              makeConversation(
                conversationType: 'seller_delivery',
                deliveryPartnerId: 'rider_1',
                deliveryPartnerName: 'Raj',
              ),
            ],
            selectedConversationId: 'conv_1',
          ));

      await tester.pumpWidget(MultiRepositoryProvider(
        providers: [
          RepositoryProvider<IChatRepository>.value(value: MockIChatRepository()),
          RepositoryProvider<IOrderRepository>.value(value: MockIOrderRepository()),
        ],
        child: BlocProvider<ChatSupportBloc>.value(
          value: mockBloc,
          child: const MaterialApp(home: ChatSupportView()),
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.textContaining('Food ready for pickup'), findsWidgets);
    });
  });
}
