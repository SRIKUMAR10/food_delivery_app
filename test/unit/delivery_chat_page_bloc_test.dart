import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:food_delivery_app/core/models/chat_message_model.dart';
import 'package:food_delivery_app/core/repositories/i_chat_repository.dart';
import 'package:food_delivery_app/features/Delivery Partner Bloc Architecture/Delivery_Chat_page/Delivery_Chat_page_bloc.dart';
import 'package:food_delivery_app/features/Delivery Partner Bloc Architecture/Delivery_Chat_page/Delivery_Chat_page_event.dart';
import 'package:food_delivery_app/features/Delivery Partner Bloc Architecture/Delivery_Chat_page/Delivery_Chat_page_state.dart';
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

  const riderId = 'rider_1';
  const riderName = 'Ravi Rider';
  const orderId = 'order_1';
  const customerId = 'customer_1';
  const customerName = 'John Buyer';
  const sellerId = 'seller_1';
  const sellerName = 'Tasty Kitchen';

  setUp(() {
    chatRepository = MockIChatRepository();
    deliveryChatRepository = MockDeliveryChatRepository();
    deliveryChatService = MockDeliveryChatService();

    when(() => deliveryChatRepository.getTypingStatusStream(any()))
        .thenAnswer((_) => const Stream.empty());
  });

  DeliveryChatBloc buildBloc() => DeliveryChatBloc(
        chatRepository: chatRepository,
        deliveryChatRepository: deliveryChatRepository,
        deliveryChatService: deliveryChatService,
      );

  group('DeliveryChatBloc', () {
    blocTest<DeliveryChatBloc, DeliveryChatState>(
      'emits DeliveryChatError when not authenticated',
      setUp: () {
        when(() => deliveryChatService.currentUserId).thenReturn('');
        when(() => deliveryChatService.currentUserName).thenReturn(riderName);
      },
      build: buildBloc,
      act: (bloc) => bloc.add(const InitDeliveryChatEvent(
        orderId: orderId,
        customerId: customerId,
        customerName: customerName,
      )),
      expect: () => [isA<DeliveryChatLoading>(), isA<DeliveryChatError>()],
    );

    test('initializes Customer delivery chat properly', () async {
      when(() => deliveryChatService.currentUserId).thenReturn(riderId);
      when(() => deliveryChatService.currentUserName).thenReturn(riderName);
      when(() => deliveryChatRepository.createOrGetConversation(
            orderId: any(named: 'orderId'),
            customerId: any(named: 'customerId'),
            customerName: any(named: 'customerName'),
            riderId: any(named: 'riderId'),
            riderName: any(named: 'riderName'),
            orderTitle: any(named: 'orderTitle'),
            orderTotal: any(named: 'orderTotal'),
          )).thenAnswer((_) async => 'conv_customer');
      when(() => deliveryChatService.markMessagesRead(any(), any()))
          .thenAnswer((_) async {});
      when(() => chatRepository.getMessagesStream(any()))
          .thenAnswer((_) => const Stream.empty());

      final bloc = buildBloc();
      bloc.add(const InitDeliveryChatEvent(
        orderId: orderId,
        customerId: customerId,
        customerName: customerName,
        recipientRole: 'customer',
      ));
      await Future.delayed(const Duration(milliseconds: 50));

      expect(bloc.state, isA<DeliveryChatLoaded>());
      final loaded = bloc.state as DeliveryChatLoaded;
      expect(loaded.conversationId, 'conv_customer');
      expect(loaded.isSellerChat, false);
      expect(loaded.recipientName, customerName);

      await bloc.close();
    });

    test('initializes Seller/Merchant delivery chat properly', () async {
      when(() => deliveryChatService.currentUserId).thenReturn(riderId);
      when(() => deliveryChatService.currentUserName).thenReturn(riderName);
      when(() => deliveryChatRepository.createOrGetSellerDeliveryConversation(
            orderId: any(named: 'orderId'),
            sellerId: any(named: 'sellerId'),
            sellerName: any(named: 'sellerName'),
            riderId: any(named: 'riderId'),
            riderName: any(named: 'riderName'),
            orderTitle: any(named: 'orderTitle'),
            orderTotal: any(named: 'orderTotal'),
          )).thenAnswer((_) async => 'conv_seller');
      when(() => deliveryChatService.markMessagesRead(any(), any()))
          .thenAnswer((_) async {});
      when(() => chatRepository.getMessagesStream(any()))
          .thenAnswer((_) => const Stream.empty());

      final bloc = buildBloc();
      bloc.add(const InitDeliveryChatEvent(
        orderId: orderId,
        sellerId: sellerId,
        sellerName: sellerName,
        recipientRole: 'seller',
      ));
      await Future.delayed(const Duration(milliseconds: 50));

      expect(bloc.state, isA<DeliveryChatLoaded>());
      final loaded = bloc.state as DeliveryChatLoaded;
      expect(loaded.conversationId, 'conv_seller');
      expect(loaded.isSellerChat, true);
      expect(loaded.recipientName, sellerName);

      await bloc.close();
    });

    test('sends text message with delivery_partner role', () async {
      when(() => deliveryChatService.currentUserId).thenReturn(riderId);
      when(() => deliveryChatService.currentUserName).thenReturn(riderName);
      when(() => deliveryChatRepository.createOrGetConversation(
            orderId: any(named: 'orderId'),
            customerId: any(named: 'customerId'),
            customerName: any(named: 'customerName'),
            riderId: any(named: 'riderId'),
            riderName: any(named: 'riderName'),
            orderTitle: any(named: 'orderTitle'),
            orderTotal: any(named: 'orderTotal'),
          )).thenAnswer((_) async => 'conv_1');
      when(() => deliveryChatService.markMessagesRead(any(), any()))
          .thenAnswer((_) async {});
      when(() => chatRepository.getMessagesStream(any()))
          .thenAnswer((_) => const Stream.empty());
      when(() => chatRepository.sendMessage(
            conversationId: any(named: 'conversationId'),
            text: any(named: 'text'),
            senderId: any(named: 'senderId'),
            senderRole: any(named: 'senderRole'),
            receiverId: any(named: 'receiverId'),
            messageType: any(named: 'messageType'),
          )).thenAnswer((_) async {});

      final bloc = buildBloc();
      bloc.add(const InitDeliveryChatEvent(
        orderId: orderId,
        customerId: customerId,
        customerName: customerName,
      ));
      await Future.delayed(const Duration(milliseconds: 50));

      bloc.add(const SendDeliveryMessageEvent('On my way'));
      await Future.delayed(const Duration(milliseconds: 50));

      verify(() => chatRepository.sendMessage(
            conversationId: 'conv_1',
            text: 'On my way',
            senderId: riderId,
            senderRole: 'delivery_partner',
            receiverId: customerId,
            messageType: 'text',
          )).called(1);

      await bloc.close();
    });

    test('quick reply delegates to send message', () async {
      when(() => deliveryChatService.currentUserId).thenReturn(riderId);
      when(() => deliveryChatService.currentUserName).thenReturn(riderName);
      when(() => deliveryChatRepository.createOrGetConversation(
            orderId: any(named: 'orderId'),
            customerId: any(named: 'customerId'),
            customerName: any(named: 'customerName'),
            riderId: any(named: 'riderId'),
            riderName: any(named: 'riderName'),
            orderTitle: any(named: 'orderTitle'),
            orderTotal: any(named: 'orderTotal'),
          )).thenAnswer((_) async => 'conv_1');
      when(() => deliveryChatService.markMessagesRead(any(), any()))
          .thenAnswer((_) async {});
      when(() => chatRepository.getMessagesStream(any()))
          .thenAnswer((_) => const Stream.empty());
      when(() => chatRepository.sendMessage(
            conversationId: any(named: 'conversationId'),
            text: any(named: 'text'),
            senderId: any(named: 'senderId'),
            senderRole: any(named: 'senderRole'),
            receiverId: any(named: 'receiverId'),
            messageType: any(named: 'messageType'),
          )).thenAnswer((_) async {});

      final bloc = buildBloc();
      bloc.add(const InitDeliveryChatEvent(
        orderId: orderId,
        customerId: customerId,
        customerName: customerName,
      ));
      await Future.delayed(const Duration(milliseconds: 50));

      bloc.add(const SendDeliveryQuickReplyEvent('On my way 🛵'));
      await Future.delayed(const Duration(milliseconds: 50));

      verify(() => chatRepository.sendMessage(
            conversationId: 'conv_1',
            text: 'On my way 🛵',
            senderId: riderId,
            senderRole: 'delivery_partner',
            receiverId: customerId,
            messageType: 'text',
          )).called(1);

      await bloc.close();
    });

    test('sends media message properly', () async {
      when(() => deliveryChatService.currentUserId).thenReturn(riderId);
      when(() => deliveryChatService.currentUserName).thenReturn(riderName);
      when(() => deliveryChatRepository.createOrGetConversation(
            orderId: any(named: 'orderId'),
            customerId: any(named: 'customerId'),
            customerName: any(named: 'customerName'),
            riderId: any(named: 'riderId'),
            riderName: any(named: 'riderName'),
            orderTitle: any(named: 'orderTitle'),
            orderTotal: any(named: 'orderTotal'),
          )).thenAnswer((_) async => 'conv_1');
      when(() => deliveryChatService.markMessagesRead(any(), any()))
          .thenAnswer((_) async {});
      when(() => chatRepository.getMessagesStream(any()))
          .thenAnswer((_) => const Stream.empty());
      when(() => chatRepository.sendMessage(
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

      final bloc = buildBloc();
      bloc.add(const InitDeliveryChatEvent(
        orderId: orderId,
        customerId: customerId,
        customerName: customerName,
      ));
      await Future.delayed(const Duration(milliseconds: 50));

      bloc.add(const SendDeliveryMediaMessageEvent(
        messageType: 'image',
        mediaUrl: 'https://example.com/photo.jpg',
        fileName: 'photo.jpg',
      ));
      await Future.delayed(const Duration(milliseconds: 50));

      verify(() => chatRepository.sendMessage(
            conversationId: 'conv_1',
            text: 'Photo attachment',
            senderId: riderId,
            senderRole: 'delivery_partner',
            receiverId: customerId,
            messageType: 'image',
            mediaUrl: 'https://example.com/photo.jpg',
            fileName: 'photo.jpg',
            fileSize: null,
            duration: null,
          )).called(1);

      await bloc.close();
    });

    test('sets typing status properly', () async {
      when(() => deliveryChatService.currentUserId).thenReturn(riderId);
      when(() => deliveryChatService.currentUserName).thenReturn(riderName);
      when(() => deliveryChatRepository.createOrGetConversation(
            orderId: any(named: 'orderId'),
            customerId: any(named: 'customerId'),
            customerName: any(named: 'customerName'),
            riderId: any(named: 'riderId'),
            riderName: any(named: 'riderName'),
            orderTitle: any(named: 'orderTitle'),
            orderTotal: any(named: 'orderTotal'),
          )).thenAnswer((_) async => 'conv_1');
      when(() => deliveryChatService.markMessagesRead(any(), any()))
          .thenAnswer((_) async {});
      when(() => chatRepository.getMessagesStream(any()))
          .thenAnswer((_) => const Stream.empty());
      when(() => deliveryChatRepository.setTypingStatus(
            conversationId: any(named: 'conversationId'),
            userId: any(named: 'userId'),
            isTyping: any(named: 'isTyping'),
          )).thenAnswer((_) async {});

      final bloc = buildBloc();
      bloc.add(const InitDeliveryChatEvent(
        orderId: orderId,
        customerId: customerId,
        customerName: customerName,
      ));
      await Future.delayed(const Duration(milliseconds: 50));

      bloc.add(const SetDeliveryTypingStatusEvent(true));
      await Future.delayed(const Duration(milliseconds: 50));

      verify(() => deliveryChatRepository.setTypingStatus(
            conversationId: 'conv_1',
            userId: riderId,
            isTyping: true,
          )).called(1);

      await bloc.close();
    });
  });
}
