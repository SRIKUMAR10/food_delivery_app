import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mocktail/mocktail.dart';
import 'package:bloc_test/bloc_test.dart';
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
  String id = 'conv_1',
  String buyerId = 'buyer_1',
  String sellerId = 'seller_1',
  String buyerName = 'Aarav Patel',
  String sellerName = 'FoodGo',
  String? orderId,
  String conversationType = 'buyer_seller',
  String? deliveryPartnerId,
  String? deliveryPartnerName,
  String? lastMessage,
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
    lastMessage: lastMessage,
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

Widget wrapWithProviders({
  required ChatSupportBloc bloc,
  required MockIChatRepository chatRepo,
  required MockIOrderRepository orderRepo,
}) {
  return MultiRepositoryProvider(
    providers: [
      RepositoryProvider<IChatRepository>.value(value: chatRepo),
      RepositoryProvider<IOrderRepository>.value(value: orderRepo),
    ],
    child: BlocProvider<ChatSupportBloc>.value(
      value: bloc,
      child: const MaterialApp(home: ChatSupportView()),
    ),
  );
}

void main() {
  group('ChatSupportPage UI Tests', () {
    late MockIChatRepository mockChatRepo;
    late MockIOrderRepository mockOrderRepo;

    setUp(() {
      mockChatRepo = MockIChatRepository();
      mockOrderRepo = MockIOrderRepository();
      when(() => mockOrderRepo.getOrderById(any())).thenAnswer((_) async => null);
      when(() => mockOrderRepo.streamOrderById(any()))
          .thenAnswer((_) => const Stream.empty());
      when(() => mockChatRepo.getMessagesStream(any()))
          .thenAnswer((_) => const Stream.empty());
      when(() => mockChatRepo.getTypingStatusStream(any()))
          .thenAnswer((_) => const Stream.empty());
      when(() => mockChatRepo.markConversationRead(any(), any(), any()))
          .thenAnswer((_) async {});
    });

    testWidgets('renders filter tabs and conversation tiles', (tester) async {
      when(() => mockChatRepo.getConversationsForUser(any(), isSeller: true))
          .thenAnswer((_) => Stream.value([
                makeConversation(id: 'c1', lastMessage: 'Hello'),
                makeConversation(
                  id: 'c2',
                  conversationType: 'seller_delivery',
                  deliveryPartnerId: 'rider_1',
                  deliveryPartnerName: 'Raj',
                  lastMessage: 'Order ready',
                ),
              ]));

      final bloc = ChatSupportBloc(repository: mockChatRepo)
        ..add(LoadChatSessionsEvent('seller1'));
      addTearDown(bloc.close);

      await tester.pumpWidget(wrapWithProviders(
        bloc: bloc,
        chatRepo: mockChatRepo,
        orderRepo: mockOrderRepo,
      ));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));

      expect(find.text('All'), findsOneWidget);
      expect(find.text('Customers'), findsOneWidget);

      final tabBar = find.byKey(const ValueKey('filterTabs'));
      await tester.dragUntilVisible(
        find.text('Active Orders'),
        tabBar,
        const Offset(-80, 0),
      );
      expect(find.text('Active Orders'), findsOneWidget);
      expect(find.text('Aarav Patel'), findsWidgets);
      expect(find.text('Raj'), findsWidgets);
    });

    testWidgets('switching filter tab filters the list', (tester) async {
      when(() => mockChatRepo.getConversationsForUser(any(), isSeller: true))
          .thenAnswer((_) => Stream.value([
                makeConversation(id: 'c1', buyerName: 'Aarav Patel'),
                makeConversation(
                  id: 'c2',
                  conversationType: 'seller_delivery',
                  deliveryPartnerId: 'rider_1',
                  deliveryPartnerName: 'Raj',
                ),
              ]));

      final bloc = ChatSupportBloc(repository: mockChatRepo)
        ..add(LoadChatSessionsEvent('seller1'));
      addTearDown(bloc.close);

      await tester.pumpWidget(wrapWithProviders(
        bloc: bloc,
        chatRepo: mockChatRepo,
        orderRepo: mockOrderRepo,
      ));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));

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

    testWidgets('selecting a conversation shows composer and quick actions',
        (tester) async {
      when(() => mockChatRepo.getConversationsForUser(any(), isSeller: true))
          .thenAnswer((_) => Stream.value([makeConversation(id: 'c1')]));

      final bloc = ChatSupportBloc(repository: mockChatRepo)
        ..add(LoadChatSessionsEvent('seller1'));
      addTearDown(bloc.close);

      await tester.pumpWidget(wrapWithProviders(
        bloc: bloc,
        chatRepo: mockChatRepo,
        orderRepo: mockOrderRepo,
      ));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));

      await tester.tap(find.text('Aarav Patel').first);
      await tester.pumpAndSettle();

      expect(find.text('Type customer response...'), findsOneWidget);
      expect(find.textContaining('Order preparing'), findsWidgets);
    });

    testWidgets('shows typing indicator when other participant is typing',
        (tester) async {
      final mockBloc = MockChatSupportBloc();
      when(() => mockBloc.stream).thenAnswer((_) => const Stream.empty());
      when(() => mockBloc.close()).thenAnswer((_) async {});
      when(() => mockBloc.state).thenReturn(ChatSupportLoaded(
            currentUserId: 'seller1',
            conversations: [
              makeConversation(id: 'conv_1', buyerId: 'buyer_1', buyerName: 'Aarav'),
            ],
            selectedConversationId: 'conv_1',
            typingUsers: const {'buyer_1': true},
          ));

      await tester.pumpWidget(MultiRepositoryProvider(
        providers: [
          RepositoryProvider<IChatRepository>.value(value: mockChatRepo),
          RepositoryProvider<IOrderRepository>.value(value: mockOrderRepo),
        ],
        child: BlocProvider<ChatSupportBloc>.value(
          value: mockBloc,
          child: const MaterialApp(home: ChatSupportView()),
        ),
      ));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.textContaining('typing'), findsWidgets);
    });

    testWidgets('pops route when back button is tapped in direct chat mode',
        (tester) async {
      final mockBloc = MockChatSupportBloc();
      when(() => mockBloc.stream).thenAnswer((_) => const Stream.empty());
      when(() => mockBloc.close()).thenAnswer((_) async {});
      when(() => mockBloc.state).thenReturn(ChatSupportLoaded(
            currentUserId: 'seller1',
            conversations: [
              makeConversation(id: 'conv_1', buyerId: 'buyer_1', buyerName: 'Aarav'),
            ],
            selectedConversationId: 'conv_1',
          ));

      bool didPop = false;

      await tester.pumpWidget(MaterialApp(
        home: Builder(
          builder: (context) => ElevatedButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => MultiRepositoryProvider(
                    providers: [
                      RepositoryProvider<IChatRepository>.value(value: mockChatRepo),
                      RepositoryProvider<IOrderRepository>.value(value: mockOrderRepo),
                    ],
                    child: BlocProvider<ChatSupportBloc>.value(
                      value: mockBloc,
                      child: const ChatSupportView(isDirectChat: true),
                    ),
                  ),
                ),
              ).then((_) => didPop = true);
            },
            child: const Text('Open Direct Chat'),
          ),
        ),
      ));

      await tester.tap(find.text('Open Direct Chat'));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.arrow_back_rounded), findsOneWidget);

      await tester.tap(find.byIcon(Icons.arrow_back_rounded));
      await tester.pumpAndSettle();

      expect(didPop, isTrue);
    });
  });
}
