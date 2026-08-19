import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:food_delivery_app/core/models/chat_message_model.dart';
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
    testWidgets('renders Customer chat with order context bar and quick replies',
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
          orderTitle: 'Pizza Feast x2',
          orderTotal: 499.0,
          recipientRole: 'customer',
        ),
      ));

      await tester.pumpAndSettle();

      expect(find.text('Karthik Raja'), findsOneWidget);
      expect(find.text('Pizza Feast x2'), findsOneWidget);
      expect(find.text('₹499.00'), findsOneWidget);
      expect(find.text('I am on my way!'), findsOneWidget);
      expect(find.text('On my way 🛵'), findsOneWidget);
      expect(find.byIcon(Icons.call_rounded), findsOneWidget);
      expect(find.byIcon(Icons.add_photo_alternate_rounded), findsOneWidget);
    });

    testWidgets('renders Merchant chat with merchant quick replies',
        (tester) async {
      when(() => deliveryChatRepository.createOrGetSellerDeliveryConversation(
            orderId: any(named: 'orderId'),
            sellerId: any(named: 'sellerId'),
            sellerName: any(named: 'sellerName'),
            riderId: any(named: 'riderId'),
            riderName: any(named: 'riderName'),
            orderTitle: any(named: 'orderTitle'),
            orderTotal: any(named: 'orderTotal'),
          )).thenAnswer((_) async => 'conv_2');

      when(() => chatRepository.getMessagesStream('conv_2'))
          .thenAnswer((_) => Stream.value([]));

      await tester.pumpWidget(createWidgetUnderTest(
        child: const DeliveryChatPage(
          orderId: 'ORD-789012',
          sellerId: 'seller_1',
          sellerName: 'Spice Biryani House',
          sellerPhone: '+91 9876543211',
          orderTitle: 'Chicken Biryani x1',
          orderTotal: 250.0,
          recipientRole: 'seller',
          recipientName: 'Spice Biryani House',
        ),
      ));

      await tester.pumpAndSettle();

      expect(find.text('Spice Biryani House'), findsOneWidget);
      expect(find.text('Chicken Biryani x1'), findsOneWidget);
      expect(find.text('₹250.00'), findsOneWidget);
      expect(find.text('Pickup instructions 📦'), findsOneWidget);
      expect(find.text('Order clarification 🧾'), findsOneWidget);
    });
  });
}
