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

  setUp(() {
    chatRepository = MockIChatRepository();
    deliveryChatRepository = MockDeliveryChatRepository();
    deliveryChatService = MockDeliveryChatService();
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

    test('sends message with delivery_partner role', () async {
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
          )).thenAnswer((_) async {});

      final bloc = buildBloc();
      bloc.add(const InitDeliveryChatEvent(
        orderId: orderId,
        customerId: customerId,
        customerName: customerName,
      ));
      await Future.delayed(const Duration(milliseconds: 50));

      bloc.add(const SendDeliveryQuickReplyEvent('On my way'));
      await Future.delayed(const Duration(milliseconds: 50));

      verify(() => chatRepository.sendMessage(
            conversationId: 'conv_1',
            text: 'On my way',
            senderId: riderId,
            senderRole: 'delivery_partner',
          )).called(1);

      await bloc.close();
    });
  });
}
