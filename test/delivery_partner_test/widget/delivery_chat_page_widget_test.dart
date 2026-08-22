import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:food_delivery_app/core/models/chat_message_model.dart';
import 'package:food_delivery_app/core/models/conversation_model.dart';
import 'package:food_delivery_app/core/repositories/i_chat_repository.dart';
import 'package:food_delivery_app/features/Delivery Partner Bloc Architecture/Delivery_Chat_page/Delivery_Chat_page_bloc.dart';
import 'package:food_delivery_app/features/Delivery Partner Bloc Architecture/Delivery_Chat_page/Delivery_Chat_page_event.dart';
import 'package:food_delivery_app/features/Delivery Partner Bloc Architecture/Delivery_Chat_page/Delivery_Chat_page_state.dart';
import 'package:food_delivery_app/features/Delivery Partner Bloc Architecture/Delivery_Chat_page/Delivery_Chat_page_ui.dart';
import 'package:food_delivery_app/features/Delivery Partner Bloc Architecture/Delivery_Chat_page/Delivery_Chat_page_repository.dart';
import 'package:food_delivery_app/features/Delivery Partner Bloc Architecture/Delivery_Chat_page/Delivery_Chat_page_service.dart';

class MockIChatRepository extends Mock implements IChatRepository {}

class MockDeliveryChatRepository extends Mock
    implements DeliveryChatRepositoryBase {}

class MockDeliveryChatService extends Mock implements DeliveryChatServiceBase {}

void main() {
  late MockIChatRepository chatRepository;
  late MockDeliveryChatRepository deliveryChatRepository;
  late MockDeliveryChatService deliveryChatService;

  setUp(() {
    chatRepository = MockIChatRepository();
    deliveryChatRepository = MockDeliveryChatRepository();
    deliveryChatService = MockDeliveryChatService();

    when(() => deliveryChatService.currentUserId).thenReturn('rider_101');
    when(() => deliveryChatService.currentUserName).thenReturn('Rider Mani');
    when(() => deliveryChatRepository.getTypingStatusStream(any()))
        .thenAnswer((_) => const Stream.empty());
    when(() => deliveryChatRepository.getDeliveryConversations(any()))
        .thenAnswer((_) => const Stream.empty());
    when(() => deliveryChatService.markMessagesRead(any(), any()))
        .thenAnswer((_) async {});
  });

  Widget createWidgetUnderTest({required Widget child}) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<IChatRepository>.value(value: chatRepository),
        RepositoryProvider<DeliveryChatRepositoryBase>.value(
            value: deliveryChatRepository),
        RepositoryProvider<DeliveryChatServiceBase>.value(
            value: deliveryChatService),
      ],
      child: MaterialApp(
        home: child,
      ),
    );
  }

  group('DeliveryChatPage Widget Tests', () {
    testWidgets('renders Customer chat with order card, total amount, and quick replies',
        (tester) async {
      when(() => deliveryChatRepository.createOrGetConversation(
            orderId: any(named: 'orderId'),
            customerId: any(named: 'customerId'),
            customerName: any(named: 'customerName'),
            riderId: any(named: 'riderId'),
            riderName: any(named: 'riderName'),
            orderTitle: any(named: 'orderTitle'),
            orderTotal: any(named: 'orderTotal'),
          )).thenAnswer((_) async => 'conv_1');

      when(() => chatRepository.getMessagesStream('conv_1'))
          .thenAnswer((_) => Stream.value([
                ChatMessageModel(
                  id: 'msg_1',
                  conversationId: 'conv_1',
                  text: 'I am on my way!',
                  senderId: 'rider_101',
                  senderRole: 'delivery_partner',
                  timestamp: DateTime(2026, 8, 17, 12, 0),
                  isRead: true,
                ),
              ]));

      await tester.pumpWidget(createWidgetUnderTest(
        child: const DeliveryChatPage(
          orderId: 'ORD-123456',
          customerId: 'cust_1',
          customerName: 'Karthik Raja',
          customerPhone: '+91 9876543210',
          orderTitle: 'Maharaja Burger',
          orderTotal: 785.0,
          recipientRole: 'customer',
        ),
      ));

      await tester.pumpAndSettle();

      expect(find.text('Karthik Raja'), findsWidgets);
      expect(find.text('Maharaja Burger'), findsOneWidget);
      expect(find.text('₹785'), findsWidgets);
      expect(find.text('Total Amount'), findsOneWidget);
      expect(find.text('I am on my way!'), findsOneWidget);
      expect(find.text('Call Customer'), findsOneWidget);
      expect(find.text('Where are you?'), findsOneWidget);
      expect(find.text('I am at the gate'), findsOneWidget);
      expect(find.text('On my way 🛵'), findsOneWidget);
    });

    testWidgets('renders master Support Chat list with search and filter tabs including Anu',
        (tester) async {
      final sampleList = [
        ConversationModel(
          id: 'conv_1',
          buyerId: 'buyer_anu',
          sellerId: '',
          buyerName: 'Anu',
          sellerName: '',
          orderId: 'ORD-ANU-99',
          lastMessage: 'Where is my order?',
          conversationType: 'buyer_delivery',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
        ConversationModel(
          id: 'conv_2',
          buyerId: '',
          sellerId: 'seller_1',
          buyerName: '',
          sellerName: 'Ahbi food restaurants',
          shopName: 'Ahbi food restaurants',
          orderId: 'k62caP5N',
          lastMessage: 'Order is ready for pickup',
          conversationType: 'seller_delivery',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      ];

      when(() => deliveryChatRepository.getDeliveryConversations('rider_101'))
          .thenAnswer((_) => Stream.value(sampleList));

      await tester.pumpWidget(createWidgetUnderTest(
        child: const DeliveryChatPage(),
      ));

      await tester.pumpAndSettle();

      expect(find.text('Support Chat'), findsOneWidget);
      expect(find.text('2 conversations'), findsOneWidget);
      expect(find.text('All'), findsOneWidget);
      expect(find.text('Store Support'), findsOneWidget);
      expect(find.text('Customer'), findsNWidgets(2));
      expect(find.text('Anu'), findsOneWidget);
      expect(find.text('Ahbi food restaurants'), findsOneWidget);
      expect(find.text('#ORD-ANU-'), findsOneWidget);
      expect(find.text('#k62caP5N'), findsOneWidget);

      // Tap Store Support tab
      await tester.tap(find.text('Store Support'));
      await tester.pumpAndSettle();
      expect(find.text('Ahbi food restaurants'), findsOneWidget);
      expect(find.text('Anu'), findsNothing);

      // Tap Customer tab
      await tester.tap(find.text('Customer').first);
      await tester.pumpAndSettle();
      expect(find.text('Anu'), findsOneWidget);
      expect(find.text('Ahbi food restaurants'), findsNothing);
    });
  });
}
