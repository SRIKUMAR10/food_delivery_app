import 'package:flutter_test/flutter_test.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:food_delivery_app/core/models/conversation_model.dart';
import 'package:food_delivery_app/core/models/chat_message_model.dart';
import 'package:food_delivery_app/repositories/firebase_chat_repository.dart';

void main() {
  group('FirebaseChatRepository', () {
    late FakeFirebaseFirestore fakeFirestore;
    late FirebaseChatRepository repository;

    const buyerId = 'buyer_1';
    const sellerId = 'seller_1';
    const buyerName = 'John Buyer';
    const sellerName = 'Sarah Seller';
    const shopName = 'Pizza Palace';

    setUp(() {
      fakeFirestore = FakeFirebaseFirestore();
      repository = FirebaseChatRepository(firestore: fakeFirestore);
    });

    group('createConversation', () {
      test('creates conversation document with correct fields', () async {
        final conversationId = await repository.createConversation(
          buyerId: buyerId,
          buyerName: buyerName,
          sellerId: sellerId,
          sellerName: sellerName,
          shopName: shopName,
        );

        final doc =
            await fakeFirestore.collection('conversations').doc(conversationId).get();
        expect(doc.exists, isTrue);

        final data = doc.data()!;
        expect(data['buyerId'], buyerId);
        expect(data['sellerId'], sellerId);
        expect(data['buyerName'], buyerName);
        expect(data['sellerName'], sellerName);
        expect(data['shopName'], shopName);
        expect(data['buyerUnreadCount'], 0);
        expect(data['sellerUnreadCount'], 0);
      });

      test('returns existing conversation ID if already exists', () async {
        final id1 = await repository.createConversation(
          buyerId: buyerId,
          buyerName: buyerName,
          sellerId: sellerId,
          sellerName: sellerName,
        );

        final id2 = await repository.createConversation(
          buyerId: buyerId,
          buyerName: buyerName,
          sellerId: sellerId,
          sellerName: sellerName,
        );

        expect(id1, id2);
      });

      test('sends initial message when provided', () async {
        final conversationId = await repository.createConversation(
          buyerId: buyerId,
          buyerName: buyerName,
          sellerId: sellerId,
          sellerName: sellerName,
          initialMessage: 'Hello there',
        );

        final messagesSnapshot = await fakeFirestore
            .collection('conversations')
            .doc(conversationId)
            .collection('messages')
            .get();

        expect(messagesSnapshot.docs.length, 1);
        expect(messagesSnapshot.docs.first.data()['text'], 'Hello there');
      });
    });

    group('getConversationsForUser (buyer)', () {
      test('returns conversations where buyerId matches', () async {
        await repository.createConversation(
          buyerId: buyerId,
          buyerName: buyerName,
          sellerId: sellerId,
          sellerName: sellerName,
          shopName: shopName,
        );

        final conversations = await repository
            .getConversationsForUser(buyerId, isSeller: false)
            .first;

        expect(conversations.length, 1);
        expect(conversations.first.buyerId, buyerId);
        expect(conversations.first.sellerId, sellerId);
        expect(conversations.first.shopName, shopName);
      });

      test('returns empty list for user with no conversations', () async {
        final conversations = await repository
            .getConversationsForUser('unknown_user', isSeller: false)
            .first;

        expect(conversations, isEmpty);
      });

      test('returns empty stream for empty userId', () async {
        final conversations = await repository
            .getConversationsForUser('', isSeller: false)
            .first;

        expect(conversations, isEmpty);
      });
    });

    group('getConversationsForUser (seller)', () {
      test('returns conversations where sellerId matches', () async {
        await repository.createConversation(
          buyerId: buyerId,
          buyerName: buyerName,
          sellerId: sellerId,
          sellerName: sellerName,
        );

        final conversations = await repository
            .getConversationsForUser(sellerId, isSeller: true)
            .first;

        expect(conversations.length, 1);
        expect(conversations.first.sellerId, sellerId);
      });
    });

    group('sendMessage', () {
      test('adds message document to messages subcollection', () async {
        final conversationId = await repository.createConversation(
          buyerId: buyerId,
          buyerName: buyerName,
          sellerId: sellerId,
          sellerName: sellerName,
        );

        await repository.sendMessage(
          conversationId: conversationId,
          text: 'Test message',
          senderId: buyerId,
          senderRole: 'buyer',
        );

        final messagesSnapshot = await fakeFirestore
            .collection('conversations')
            .doc(conversationId)
            .collection('messages')
            .get();

        expect(messagesSnapshot.docs.length, 1);

        final msgData = messagesSnapshot.docs.first.data();
        expect(msgData['text'], 'Test message');
        expect(msgData['senderId'], buyerId);
        expect(msgData['senderRole'], 'buyer');
        expect(msgData['isRead'], false);
      });

      test('updates conversation metadata and unread count', () async {
        final conversationId = await repository.createConversation(
          buyerId: buyerId,
          buyerName: buyerName,
          sellerId: sellerId,
          sellerName: sellerName,
        );

        await repository.sendMessage(
          conversationId: conversationId,
          text: 'Buyer message',
          senderId: buyerId,
          senderRole: 'buyer',
        );

        final convDoc = await fakeFirestore
            .collection('conversations')
            .doc(conversationId)
            .get();
        final convData = convDoc.data()!;

        expect(convData['lastMessage'], 'Buyer message');
        expect(convData['lastMessageSenderId'], buyerId);
        expect(convData['lastMessageTimestamp'], isNotNull);
        expect(convData['sellerUnreadCount'], 1);
        expect(convData['buyerUnreadCount'], 0);
      });

      test('increments correct unread count for seller messages', () async {
        final conversationId = await repository.createConversation(
          buyerId: buyerId,
          buyerName: buyerName,
          sellerId: sellerId,
          sellerName: sellerName,
        );

        await repository.sendMessage(
          conversationId: conversationId,
          text: 'Seller reply',
          senderId: sellerId,
          senderRole: 'seller',
        );

        final convDoc = await fakeFirestore
            .collection('conversations')
            .doc(conversationId)
            .get();
        final convData = convDoc.data()!;

        expect(convData['buyerUnreadCount'], 1);
        expect(convData['sellerUnreadCount'], 0);
      });
    });

    group('getMessagesStream', () {
      test('returns messages in chronological order', () async {
        final conversationId = await repository.createConversation(
          buyerId: buyerId,
          buyerName: buyerName,
          sellerId: sellerId,
          sellerName: sellerName,
        );

        await repository.sendMessage(
          conversationId: conversationId,
          text: 'First',
          senderId: buyerId,
          senderRole: 'buyer',
        );

        await Future.delayed(const Duration(milliseconds: 10));

        await repository.sendMessage(
          conversationId: conversationId,
          text: 'Second',
          senderId: sellerId,
          senderRole: 'seller',
        );

        final messages = await repository.getMessagesStream(conversationId).first;

        expect(messages.length, 2);
        expect(messages[0].text, 'First');
        expect(messages[1].text, 'Second');
      });

      test('returns empty stream for non-existent conversation', () async {
        final messages =
            await repository.getMessagesStream('nonexistent').first;
        expect(messages, isEmpty);
      });

      test('returns empty stream for empty conversationId', () async {
        final messages = await repository.getMessagesStream('').first;
        expect(messages, isEmpty);
      });
    });

    group('markConversationRead', () {
      test('resets buyer unread count', () async {
        final conversationId = await repository.createConversation(
          buyerId: buyerId,
          buyerName: buyerName,
          sellerId: sellerId,
          sellerName: sellerName,
        );

        await repository.sendMessage(
          conversationId: conversationId,
          text: 'Test',
          senderId: sellerId,
          senderRole: 'seller',
        );

        await repository.markConversationRead(conversationId, buyerId, false);

        final convDoc = await fakeFirestore
            .collection('conversations')
            .doc(conversationId)
            .get();
        final convData = convDoc.data()!;

        expect(convData['buyerUnreadCount'], 0);
      });

      test('resets seller unread count', () async {
        final conversationId = await repository.createConversation(
          buyerId: buyerId,
          buyerName: buyerName,
          sellerId: sellerId,
          sellerName: sellerName,
        );

        await repository.sendMessage(
          conversationId: conversationId,
          text: 'Test',
          senderId: buyerId,
          senderRole: 'buyer',
        );

        await repository.markConversationRead(conversationId, sellerId, true);

        final convDoc = await fakeFirestore
            .collection('conversations')
            .doc(conversationId)
            .get();
        final convData = convDoc.data()!;

        expect(convData['sellerUnreadCount'], 0);
      });
    });

    group('getConversationByParticipants', () {
      test('returns existing conversation', () async {
        await repository.createConversation(
          buyerId: buyerId,
          buyerName: buyerName,
          sellerId: sellerId,
          sellerName: sellerName,
        );

        final result =
            await repository.getConversationByParticipants(buyerId, sellerId);

        expect(result, isNotNull);
        expect(result!.buyerId, buyerId);
        expect(result.sellerId, sellerId);
      });

      test('returns null for non-existent participants', () async {
        final result =
            await repository.getConversationByParticipants('a', 'b');
        expect(result, isNull);
      });

      test('returns null when buyerId or sellerId is empty', () async {
        final result1 = await repository.getConversationByParticipants('', sellerId);
        expect(result1, isNull);

        final result2 = await repository.getConversationByParticipants(buyerId, '');
        expect(result2, isNull);
      });
    });

    group('unread count consistency across multiple messages', () {
      test('multiple messages increment unread count correctly', () async {
        final conversationId = await repository.createConversation(
          buyerId: buyerId,
          buyerName: buyerName,
          sellerId: sellerId,
          sellerName: sellerName,
        );

        await repository.sendMessage(
          conversationId: conversationId,
          text: 'Msg 1',
          senderId: sellerId,
          senderRole: 'seller',
        );
        await repository.sendMessage(
          conversationId: conversationId,
          text: 'Msg 2',
          senderId: sellerId,
          senderRole: 'seller',
        );
        await repository.sendMessage(
          conversationId: conversationId,
          text: 'Msg 3',
          senderId: sellerId,
          senderRole: 'seller',
        );

        final convDoc = await fakeFirestore
            .collection('conversations')
            .doc(conversationId)
            .get();
        final convData = convDoc.data()!;

        expect(convData['buyerUnreadCount'], 3);
        expect(convData['sellerUnreadCount'], 0);
      });
    });

    group('multi-party delivery conversations', () {
      test('createConversation writes delivery fields and participants', () async {
        final conversationId = await repository.createConversation(
          buyerId: buyerId,
          buyerName: buyerName,
          sellerId: '',
          sellerName: '',
          deliveryPartnerId: 'rider_1',
          deliveryPartnerName: 'Ravi Rider',
          conversationType: 'buyer_delivery',
        );

        final doc = await fakeFirestore
            .collection('conversations')
            .doc(conversationId)
            .get();
        final data = doc.data()!;

        expect(data['deliveryPartnerId'], 'rider_1');
        expect(data['conversationType'], 'buyer_delivery');
        expect(data['participants'], containsAll([buyerId, 'rider_1']));
      });

      test('getConversationsForUser with role delivery_partner returns chat including customer Anu', () async {
        await repository.createConversation(
          buyerId: 'buyer_anu',
          buyerName: 'Anu',
          sellerId: '',
          sellerName: '',
          deliveryPartnerId: 'rider_1',
          deliveryPartnerName: 'Ravi Rider',
          conversationType: 'buyer_delivery',
        );

        final conversations = await repository
            .getConversationsForUser('rider_1', role: 'delivery_partner')
            .first;

        expect(conversations.length, 1);
        expect(conversations.first.deliveryPartnerId, 'rider_1');
        expect(conversations.first.buyerName, 'Anu');
      });

      test('getConversationBetween finds delivery chat by participants', () async {
        await repository.createConversation(
          buyerId: buyerId,
          buyerName: buyerName,
          sellerId: '',
          sellerName: '',
          deliveryPartnerId: 'rider_1',
          deliveryPartnerName: 'Ravi Rider',
          conversationType: 'buyer_delivery',
        );

        final result = await repository.getConversationBetween(
          user1Id: buyerId,
          user2Id: 'rider_1',
          type: 'buyer_delivery',
        );

        expect(result, isNotNull);
        expect(result!.conversationType, 'buyer_delivery');
      });

      test('sendMessage sets receiverId and increments delivery unread count', () async {
        final conversationId = await repository.createConversation(
          buyerId: buyerId,
          buyerName: buyerName,
          sellerId: '',
          sellerName: '',
          deliveryPartnerId: 'rider_1',
          deliveryPartnerName: 'Ravi Rider',
          conversationType: 'buyer_delivery',
        );

        await repository.sendMessage(
          conversationId: conversationId,
          text: 'Where are you?',
          senderId: buyerId,
          senderRole: 'buyer',
        );

        final messages = await fakeFirestore
            .collection('conversations')
            .doc(conversationId)
            .collection('messages')
            .get();
        expect(messages.docs.single.data()['receiverId'], 'rider_1');

        final convDoc = await fakeFirestore
            .collection('conversations')
            .doc(conversationId)
            .get();
        expect(convDoc.data()!['deliveryUnreadCount'], 1);
      });
    });

    group('markMessagesAsRead', () {
      test('marks incoming messages read and resets counter', () async {
        final conversationId = await repository.createConversation(
          buyerId: buyerId,
          buyerName: buyerName,
          sellerId: sellerId,
          sellerName: sellerName,
        );

        await repository.sendMessage(
          conversationId: conversationId,
          text: 'Hello buyer',
          senderId: sellerId,
          senderRole: 'seller',
        );

        await repository.markMessagesAsRead(
          conversationId: conversationId,
          readerId: buyerId,
        );

        final messages = await fakeFirestore
            .collection('conversations')
            .doc(conversationId)
            .collection('messages')
            .get();
        expect(messages.docs.single.data()['isRead'], isTrue);

        final convDoc = await fakeFirestore
            .collection('conversations')
            .doc(conversationId)
            .get();
        expect(convDoc.data()!['buyerUnreadCount'], 0);
      });
    });
  });
}
