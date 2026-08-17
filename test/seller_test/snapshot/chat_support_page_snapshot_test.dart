import 'package:flutter_test/flutter_test.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/chat_support_page_/chat_support_page_event.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/chat_support_page_/chat_support_page_state.dart';
import 'package:food_delivery_app/core/models/conversation_model.dart';
import 'package:food_delivery_app/core/models/chat_message_model.dart';

void main() {
  group('ChatSupportPage Snapshot Tests', () {
    test('ConversationModel serializes and deserializes losslessly', () {
      final conversation = ConversationModel(
        id: 'conv_1',
        buyerId: 'buyer_1',
        sellerId: 'seller_1',
        buyerName: 'Aarav',
        sellerName: 'FoodGo',
        orderId: 'ord_1',
        conversationType: 'seller_delivery',
        deliveryPartnerId: 'rider_1',
        deliveryPartnerName: 'Raj',
        participants: const ['buyer_1', 'seller_1', 'rider_1'],
        participantRoles: const {
          'buyer_1': 'buyer',
          'seller_1': 'seller',
          'rider_1': 'delivery_partner',
        },
        createdAt: DateTime(2026, 1, 1),
        updatedAt: DateTime(2026, 1, 1),
      );

      final restored = ConversationModel.fromMap(conversation.toMap(), 'conv_1');

      expect(restored.id, 'conv_1');
      expect(restored.buyerId, 'buyer_1');
      expect(restored.orderId, 'ord_1');
      expect(restored.conversationType, 'seller_delivery');
      expect(restored.deliveryPartnerName, 'Raj');
      expect(restored.participants, contains('rider_1'));
    });

    test('ChatMessageModel serializes and deserializes losslessly', () {
      final message = ChatMessageModel(
        id: 'm_1',
        conversationId: 'conv_1',
        text: 'Hello',
        senderId: 'seller_1',
        senderRole: 'seller',
        timestamp: DateTime(2026, 1, 1, 10, 30),
        isRead: true,
        messageType: 'text',
      );

      final restored = ChatMessageModel.fromMap(message.toMap(), 'm_1');

      expect(restored.text, 'Hello');
      expect(restored.senderRole, 'seller');
      expect(restored.isRead, isTrue);
    });

    test('ChatSupportLoaded copyWith preserves typing, filter and order state', () {
      final state = ChatSupportLoaded(
        currentUserId: 'seller_1',
        conversations: const [],
        selectedConversationId: 'conv_1',
        typingUsers: const {'buyer_1': true},
        activeFilterTab: ChatFilterTab.deliveryPartners,
        initialOrderId: 'ord_1',
      );

      final copied = state.copyWith(activeFilterTab: ChatFilterTab.orders);

      expect(copied.typingUsers, {'buyer_1': true});
      expect(copied.selectedConversationId, 'conv_1');
      expect(copied.initialOrderId, 'ord_1');
      expect(copied.activeFilterTab, ChatFilterTab.orders);
    });
  });
}
