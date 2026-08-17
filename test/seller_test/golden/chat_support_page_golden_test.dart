import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mocktail/mocktail.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/services.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/chat_support_page_/chat_support_page_bloc.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/chat_support_page_/chat_support_page_event.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/chat_support_page_/chat_support_page_state.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/chat_support_page_/chat_support_page_ui.dart';
import 'package:food_delivery_app/core/models/conversation_model.dart';
import 'package:food_delivery_app/core/models/chat_message_model.dart';

import '../../font_loader_helper.dart';

class MockChatSupportBloc extends MockBloc<ChatSupportEvent, ChatSupportState>
    implements ChatSupportBloc {}

ConversationModel makeConversation({String id = 'conv_1'}) {
  return ConversationModel(
    id: id,
    buyerId: 'buyer_1',
    sellerId: 'seller_1',
    buyerName: 'Aarav Patel',
    sellerName: 'FoodGo',
    lastMessage: 'Hello, is my order ready?',
    createdAt: DateTime(2026, 1, 1),
    updatedAt: DateTime(2026, 1, 1),
    participants: const ['buyer_1', 'seller_1'],
    participantRoles: const {'buyer_1': 'buyer', 'seller_1': 'seller'},
  );
}

void main() {
  setUpAll(() {
    overrideFontAssetLoading();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          const MethodChannel('plugins.flutter.io/path_provider'),
          (MethodCall methodCall) async => '.',
        );
  });

  group('ChatSupportPage Golden Tests', () {
    late MockChatSupportBloc mockBloc;

    setUp(() {
      mockBloc = MockChatSupportBloc();
      when(() => mockBloc.stream).thenAnswer((_) => const Stream.empty());
      when(() => mockBloc.close()).thenAnswer((_) async {});
    });

    testWidgets('Golden - conversation list view', (tester) async {
      tester.view.physicalSize = const Size(400, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      when(() => mockBloc.state).thenReturn(ChatSupportLoaded(
            currentUserId: 'seller1',
            conversations: [
              makeConversation(id: 'conv_1'),
              ConversationModel(
                id: 'conv_2',
                buyerId: 'buyer_2',
                sellerId: 'seller_1',
                buyerName: 'Priya',
                sellerName: 'FoodGo',
                conversationType: 'seller_delivery',
                deliveryPartnerId: 'rider_1',
                deliveryPartnerName: 'Raj',
                lastMessage: 'Ready in 2 mins',
                createdAt: DateTime(2026, 1, 1),
                updatedAt: DateTime(2026, 1, 1),
                participants: const ['seller_1', 'rider_1'],
                participantRoles: const {
                  'seller_1': 'seller',
                  'rider_1': 'delivery_partner',
                },
              ),
            ],
          ));

      await tester.pumpWidget(
        BlocProvider<ChatSupportBloc>.value(
          value: mockBloc,
          child: const MaterialApp(home: ChatSupportView()),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      await expectLater(
        find.byType(ChatSupportView),
        matchesGoldenFile('goldens/chat_support_list.png'),
      );
    });

    testWidgets('Golden - chat details view', (tester) async {
      tester.view.physicalSize = const Size(400, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      when(() => mockBloc.state).thenReturn(ChatSupportLoaded(
            currentUserId: 'seller1',
            conversations: [makeConversation(id: 'conv_1')],
            selectedConversationId: 'conv_1',
            messages: [
              ChatMessageModel(
                id: 'm1',
                conversationId: 'conv_1',
                text: 'Hello, is my order ready?',
                senderId: 'buyer_1',
                senderRole: 'buyer',
                timestamp: DateTime(2026, 1, 1, 10, 30),
              ),
              ChatMessageModel(
                id: 'm2',
                conversationId: 'conv_1',
                text: 'Yes, it is out for delivery!',
                senderId: 'seller1',
                senderRole: 'seller',
                timestamp: DateTime(2026, 1, 1, 10, 31),
                isRead: true,
              ),
            ],
          ));

      await tester.pumpWidget(
        BlocProvider<ChatSupportBloc>.value(
          value: mockBloc,
          child: const MaterialApp(home: ChatSupportView()),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      await expectLater(
        find.byType(ChatSupportView),
        matchesGoldenFile('goldens/chat_support_details.png'),
      );
    });
  });
}
