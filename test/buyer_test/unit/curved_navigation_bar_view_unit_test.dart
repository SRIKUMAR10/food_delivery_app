import 'package:flutter_test/flutter_test.dart';
import 'package:food_delivery_app/core/models/conversation_model.dart';
import 'package:food_delivery_app/core/models/order_status.dart';

void main() {
  group('Order badge counting logic', () {
    test('isTerminal only flags delivered/rejected/cancelled as terminal', () {
      for (final status in OrderStatus.values) {
        final expected = status == OrderStatus.delivered ||
            status == OrderStatus.rejected ||
            status == OrderStatus.cancelled;
        expect(
          status.isTerminal,
          expected,
          reason: '${status.value} should be terminal: $expected',
        );
      }
    });

    test('active order count is derived by excluding terminal orders', () {
      final activeStatuses = OrderStatus.values
          .where((status) => !status.isTerminal)
          .toList();

      expect(activeStatuses, isNotEmpty);
      expect(
        activeStatuses,
        containsAll([
          OrderStatus.newOrder,
          OrderStatus.accepted,
          OrderStatus.preparing,
          OrderStatus.ready,
          OrderStatus.pickedUp,
          OrderStatus.outForDelivery,
        ]),
      );
    });
  });

  group('Support unread badge counting logic', () {
    test('unreadCountForUser returns the buyer unread count for the buyer', () {
      final conversation = ConversationModel(
        id: 'c1',
        buyerId: 'buyer_1',
        sellerId: 'seller_1',
        buyerName: 'Buyer',
        sellerName: 'Seller',
        buyerUnreadCount: 4,
        sellerUnreadCount: 1,
        createdAt: DateTime(2026, 1, 1),
        updatedAt: DateTime(2026, 1, 1),
      );

      expect(conversation.unreadCountForUser('buyer_1'), 4);
      expect(conversation.unreadCountForUser('seller_1'), 1);
      expect(conversation.unreadCountForUser('unknown_user'), 0);
    });

    test('delivery chat unread is exposed through the role-aware lookup', () {
      final conversation = ConversationModel(
        id: 'c2',
        buyerId: 'buyer_1',
        sellerId: '',
        buyerName: 'Buyer',
        sellerName: 'Delivery Partner',
        buyerUnreadCount: 0,
        sellerUnreadCount: 0,
        deliveryUnreadCount: 2,
        conversationType: 'buyer_delivery',
        deliveryPartnerId: 'driver_1',
        deliveryPartnerName: 'Driver',
        createdAt: DateTime(2026, 1, 1),
        updatedAt: DateTime(2026, 1, 1),
      );

      expect(conversation.unreadCountForUser('buyer_1'), 0);
      expect(conversation.unreadCountForUser('driver_1'), 2);
    });

    test('total unread is the sum of unread across all conversations', () {
      final conversations = [
        ConversationModel(
          id: 'c1',
          buyerId: 'buyer_1',
          sellerId: 'seller_1',
          buyerName: 'Buyer',
          sellerName: 'Seller',
          buyerUnreadCount: 3,
          createdAt: DateTime(2026, 1, 1),
          updatedAt: DateTime(2026, 1, 1),
        ),
        ConversationModel(
          id: 'c2',
          buyerId: 'buyer_1',
          sellerId: 'seller_2',
          buyerName: 'Buyer',
          sellerName: 'Seller 2',
          buyerUnreadCount: 0,
          createdAt: DateTime(2026, 1, 1),
          updatedAt: DateTime(2026, 1, 1),
        ),
      ];

      var total = 0;
      for (final conversation in conversations) {
        total += conversation.unreadCountForUser('buyer_1');
      }
      expect(total, 3);
    });
  });

  group('Curved Navigation Bar View unit Tests', () {
    test('Placeholder for unit testing', () {
      expect(true, isTrue);
    });
  });
}
