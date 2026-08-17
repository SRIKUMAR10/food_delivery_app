import 'package:flutter_test/flutter_test.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:food_delivery_app/core/models/conversation_model.dart';

void main() {
  group('ConversationModel', () {
    const testId = 'conv_1';
    const buyerId = 'buyer_1';
    const sellerId = 'seller_1';
    const buyerName = 'John Buyer';
    const sellerName = 'Sarah Seller';
    const shopName = 'Pizza Palace';
    final testTimestamp = DateTime(2026, 7, 20, 10, 30);

    test('constructor sets all fields correctly', () {
      final model = ConversationModel(
        id: testId,
        buyerId: buyerId,
        sellerId: sellerId,
        buyerName: buyerName,
        sellerName: sellerName,
        shopName: shopName,
        createdAt: testTimestamp,
        updatedAt: testTimestamp,
      );

      expect(model.id, testId);
      expect(model.buyerId, buyerId);
      expect(model.sellerId, sellerId);
      expect(model.buyerName, buyerName);
      expect(model.sellerName, sellerName);
      expect(model.shopName, shopName);
      expect(model.productId, isNull);
      expect(model.orderId, isNull);
      expect(model.lastMessage, isNull);
      expect(model.buyerUnreadCount, 0);
      expect(model.sellerUnreadCount, 0);
    });

    test('fromMap parses Firestore map correctly', () {
      final map = {
        'buyerId': buyerId,
        'sellerId': sellerId,
        'buyerName': buyerName,
        'sellerName': sellerName,
        'shopName': shopName,
        'productId': 'prod_1',
        'orderId': 'ord_1',
        'lastMessage': 'Hello',
        'lastMessageSenderId': buyerId,
        'lastMessageTimestamp': Timestamp.fromDate(testTimestamp),
        'buyerUnreadCount': 0,
        'sellerUnreadCount': 1,
        'createdAt': Timestamp.fromDate(testTimestamp),
        'updatedAt': Timestamp.fromDate(testTimestamp),
      };

      final model = ConversationModel.fromMap(map, testId);

      expect(model.id, testId);
      expect(model.buyerId, buyerId);
      expect(model.sellerId, sellerId);
      expect(model.shopName, shopName);
      expect(model.productId, 'prod_1');
      expect(model.orderId, 'ord_1');
      expect(model.lastMessage, 'Hello');
      expect(model.lastMessageSenderId, buyerId);
      expect(model.buyerUnreadCount, 0);
      expect(model.sellerUnreadCount, 1);
    });

    test('fromMap handles null values with defaults', () {
      final map = <String, dynamic>{};
      final model = ConversationModel.fromMap(map, testId);

      expect(model.id, testId);
      expect(model.buyerId, '');
      expect(model.sellerId, '');
      expect(model.buyerName, 'Buyer');
      expect(model.sellerName, 'Seller');
      expect(model.buyerUnreadCount, 0);
      expect(model.sellerUnreadCount, 0);
    });

    test('toMap produces correct map', () {
      final model = ConversationModel(
        id: testId,
        buyerId: buyerId,
        sellerId: sellerId,
        buyerName: buyerName,
        sellerName: sellerName,
        shopName: shopName,
        orderId: 'ord_1',
        lastMessage: 'Hi',
        lastMessageSenderId: buyerId,
        lastMessageTimestamp: testTimestamp,
        buyerUnreadCount: 1,
        sellerUnreadCount: 2,
        createdAt: testTimestamp,
        updatedAt: testTimestamp,
      );

      final map = model.toMap();

      expect(map['buyerId'], buyerId);
      expect(map['sellerId'], sellerId);
      expect(map['shopName'], shopName);
      expect(map['orderId'], 'ord_1');
      expect(map['lastMessage'], 'Hi');
      expect(map['buyerUnreadCount'], 1);
      expect(map['sellerUnreadCount'], 2);
      expect(map['createdAt'], isA<Timestamp>());
      expect(map['updatedAt'], isA<Timestamp>());
    });

    test('copyWith updates only specified fields', () {
      final model = ConversationModel(
        id: testId,
        buyerId: buyerId,
        sellerId: sellerId,
        buyerName: buyerName,
        sellerName: sellerName,
        createdAt: testTimestamp,
        updatedAt: testTimestamp,
      );

      final updated = model.copyWith(
        shopName: 'New Shop',
        buyerUnreadCount: 3,
      );

      expect(updated.id, testId);
      expect(updated.shopName, 'New Shop');
      expect(updated.buyerUnreadCount, 3);
      expect(updated.sellerUnreadCount, 0);
      expect(updated.buyerName, buyerName);
    });

    test('unreadCountForUser returns buyerUnreadCount for buyer', () {
      final model = ConversationModel(
        id: testId,
        buyerId: buyerId,
        sellerId: sellerId,
        buyerName: buyerName,
        sellerName: sellerName,
        buyerUnreadCount: 5,
        sellerUnreadCount: 3,
        createdAt: testTimestamp,
        updatedAt: testTimestamp,
      );

      expect(model.unreadCountForUser(buyerId), 5);
      expect(model.unreadCountForUser(sellerId), 3);
    });

    test('unreadCountForUser returns 0 for unknown user', () {
      final model = ConversationModel(
        id: testId,
        buyerId: buyerId,
        sellerId: sellerId,
        buyerName: buyerName,
        sellerName: sellerName,
        createdAt: testTimestamp,
        updatedAt: testTimestamp,
      );

      expect(model.unreadCountForUser('unknown'), 0);
    });

    test('otherParticipantName returns correct name', () {
      final model = ConversationModel(
        id: testId,
        buyerId: buyerId,
        sellerId: sellerId,
        buyerName: buyerName,
        sellerName: sellerName,
        createdAt: testTimestamp,
        updatedAt: testTimestamp,
      );

      expect(model.otherParticipantName(buyerId), sellerName);
      expect(model.otherParticipantName(sellerId), buyerName);
    });

    test('otherParticipantName returns empty string for unknown user', () {
      final model = ConversationModel(
        id: testId,
        buyerId: buyerId,
        sellerId: sellerId,
        buyerName: buyerName,
        sellerName: sellerName,
        createdAt: testTimestamp,
        updatedAt: testTimestamp,
      );

      expect(model.otherParticipantName('unknown'), '');
    });

    test('Equatable equality works correctly', () {
      final a = ConversationModel(
        id: testId,
        buyerId: buyerId,
        sellerId: sellerId,
        buyerName: buyerName,
        sellerName: sellerName,
        createdAt: testTimestamp,
        updatedAt: testTimestamp,
      );

      final b = ConversationModel(
        id: testId,
        buyerId: buyerId,
        sellerId: sellerId,
        buyerName: buyerName,
        sellerName: sellerName,
        createdAt: testTimestamp,
        updatedAt: testTimestamp,
      );

      expect(a, b);

      final c = ConversationModel(
        id: 'different',
        buyerId: buyerId,
        sellerId: sellerId,
        buyerName: buyerName,
        sellerName: sellerName,
        createdAt: testTimestamp,
        updatedAt: testTimestamp,
      );

      expect(a, isNot(c));
    });

    group('multi-party fields', () {
      test('isDeliveryChat true when conversationType is buyer_delivery', () {
        final model = ConversationModel(
          id: testId,
          buyerId: buyerId,
          sellerId: '',
          buyerName: buyerName,
          sellerName: '',
          deliveryPartnerId: 'rider_1',
          deliveryPartnerName: 'Ravi Rider',
          conversationType: 'buyer_delivery',
          createdAt: testTimestamp,
          updatedAt: testTimestamp,
        );

        expect(model.isDeliveryChat, isTrue);
      });

      test('isDeliveryChat true when deliveryPartnerId is set', () {
        final model = ConversationModel(
          id: testId,
          buyerId: buyerId,
          sellerId: sellerId,
          buyerName: buyerName,
          sellerName: sellerName,
          deliveryPartnerId: 'rider_1',
          createdAt: testTimestamp,
          updatedAt: testTimestamp,
        );

        expect(model.isDeliveryChat, isTrue);
      });

      test('isDeliveryChat false for buyer_seller chat', () {
        final model = ConversationModel(
          id: testId,
          buyerId: buyerId,
          sellerId: sellerId,
          buyerName: buyerName,
          sellerName: sellerName,
          createdAt: testTimestamp,
          updatedAt: testTimestamp,
        );

        expect(model.isDeliveryChat, isFalse);
      });

      test('unreadCountForUser returns deliveryUnreadCount for rider', () {
        final model = ConversationModel(
          id: testId,
          buyerId: buyerId,
          sellerId: '',
          buyerName: buyerName,
          sellerName: '',
          deliveryPartnerId: 'rider_1',
          deliveryUnreadCount: 4,
          conversationType: 'buyer_delivery',
          createdAt: testTimestamp,
          updatedAt: testTimestamp,
        );

        expect(model.unreadCountForUser('rider_1'), 4);
        expect(model.unreadCountForUser(buyerId), 0);
      });

      test('otherParticipantName returns rider name for buyer in delivery chat', () {
        final model = ConversationModel(
          id: testId,
          buyerId: buyerId,
          sellerId: '',
          buyerName: buyerName,
          sellerName: '',
          deliveryPartnerId: 'rider_1',
          deliveryPartnerName: 'Ravi Rider',
          conversationType: 'buyer_delivery',
          createdAt: testTimestamp,
          updatedAt: testTimestamp,
        );

        expect(model.otherParticipantName(buyerId), 'Ravi Rider');
        expect(model.otherParticipantName('rider_1'), buyerName);
      });

      test('otherParticipantRole returns delivery_partner for buyer', () {
        final model = ConversationModel(
          id: testId,
          buyerId: buyerId,
          sellerId: '',
          buyerName: buyerName,
          sellerName: '',
          deliveryPartnerId: 'rider_1',
          conversationType: 'buyer_delivery',
          createdAt: testTimestamp,
          updatedAt: testTimestamp,
        );

        expect(model.otherParticipantRole(buyerId), 'delivery_partner');
        expect(model.otherParticipantRole('rider_1'), 'buyer');
      });

      test('fromMap derives participants when not present', () {
        final map = {
          'buyerId': buyerId,
          'sellerId': '',
          'deliveryPartnerId': 'rider_1',
          'conversationType': 'buyer_delivery',
        };

        final model = ConversationModel.fromMap(map, testId);

        expect(model.participants, containsAll(['buyer_1', 'rider_1']));
        expect(model.conversationType, 'buyer_delivery');
      });

      test('fromMap parses explicit participants and participantRoles', () {
        final map = {
          'buyerId': buyerId,
          'sellerId': '',
          'deliveryPartnerId': 'rider_1',
          'conversationType': 'buyer_delivery',
          'participants': ['buyer_1', 'rider_1'],
          'participantRoles': {'buyer_1': 'buyer', 'rider_1': 'delivery_partner'},
        };

        final model = ConversationModel.fromMap(map, testId);

        expect(model.participants, ['buyer_1', 'rider_1']);
        expect(model.participantRoles['rider_1'], 'delivery_partner');
      });

      test('toMap includes multi-party fields', () {
        final model = ConversationModel(
          id: testId,
          buyerId: buyerId,
          sellerId: '',
          buyerName: buyerName,
          sellerName: '',
          deliveryPartnerId: 'rider_1',
          deliveryPartnerName: 'Ravi Rider',
          deliveryPartnerPhone: '9876543210',
          conversationType: 'buyer_delivery',
          createdAt: testTimestamp,
          updatedAt: testTimestamp,
        );

        final map = model.toMap();

        expect(map['deliveryPartnerId'], 'rider_1');
        expect(map['deliveryPartnerName'], 'Ravi Rider');
        expect(map['deliveryPartnerPhone'], '9876543210');
        expect(map['conversationType'], 'buyer_delivery');
      });
    });
  });
}
