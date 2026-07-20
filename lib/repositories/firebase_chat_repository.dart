import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import '../core/models/conversation_model.dart';
import '../core/models/chat_message_model.dart';
import '../core/repositories/i_chat_repository.dart';

class FirebaseChatRepository implements IChatRepository {
  final FirebaseFirestore _firestore;
  final _uuid = const Uuid();

  FirebaseChatRepository({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Stream<List<ConversationModel>> getConversationsForUser(
    String userId, {
    required bool isSeller,
  }) {
    if (userId.isEmpty) {
      return Stream.value([]);
    }

    final field = isSeller ? 'sellerId' : 'buyerId';

    return _firestore
        .collection('conversations')
        .where(field, isEqualTo: userId)
        .snapshots()
        .map((snapshot) {
          final conversations = snapshot.docs
              .map((doc) => ConversationModel.fromMap(doc.data(), doc.id))
              .toList();
          
          conversations.sort((a, b) {
            final aTime = a.lastMessageTimestamp ?? a.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
            final bTime = b.lastMessageTimestamp ?? b.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
            return bTime.compareTo(aTime); // descending
          });
          
          return conversations;
        });
  }

  @override
  Stream<List<ChatMessageModel>> getMessagesStream(String conversationId) {
    if (conversationId.isEmpty) {
      return Stream.value([]);
    }

    return _firestore
        .collection('conversations')
        .doc(conversationId)
        .collection('messages')
        .orderBy('timestamp', descending: false)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map(
                (doc) => ChatMessageModel.fromMap(
                  doc.data(),
                  doc.id,
                  conversationId: conversationId,
                ),
              )
              .toList();
        });
  }

  @override
  Future<void> sendMessage({
    required String conversationId,
    required String text,
    required String senderId,
    required String senderRole,
  }) async {
    final messageId = _uuid.v4();
    final timestamp = DateTime.now();

    final batch = _firestore.batch();

    final messageRef = _firestore
        .collection('conversations')
        .doc(conversationId)
        .collection('messages')
        .doc(messageId);

    batch.set(messageRef, {
      'conversationId': conversationId,
      'text': text,
      'senderId': senderId,
      'senderRole': senderRole,
      'timestamp': Timestamp.fromDate(timestamp),
      'isRead': false,
      'messageType': 'text',
    });

    final conversationRef = _firestore
        .collection('conversations')
        .doc(conversationId);

    final unreadField = senderRole == 'buyer'
        ? 'sellerUnreadCount'
        : 'buyerUnreadCount';

    batch.update(conversationRef, {
      'lastMessage': text,
      'lastMessageSenderId': senderId,
      'lastMessageTimestamp': Timestamp.fromDate(timestamp),
      'updatedAt': Timestamp.fromDate(timestamp),
      unreadField: FieldValue.increment(1),
    });

    await batch.commit();
  }

  @override
  Future<String> createConversation({
    required String buyerId,
    required String buyerName,
    required String sellerId,
    required String sellerName,
    String? shopName,
    String? sellerImageUrl,
    String? productId,
    String? orderId,
    String? orderImageUrl,
    String? orderTitle,
    double? orderTotal,
    String? initialMessage,
  }) async {
    final existing = await getConversationByParticipants(buyerId, sellerId);
    if (existing != null) {
      if (initialMessage != null && initialMessage.isNotEmpty) {
        await sendMessage(
          conversationId: existing.id,
          text: initialMessage,
          senderId: buyerId,
          senderRole: 'buyer',
        );
      }
      return existing.id;
    }

    final conversationId = _uuid.v4();
    final now = DateTime.now();

    await _firestore.collection('conversations').doc(conversationId).set({
      'buyerId': buyerId,
      'sellerId': sellerId,
      'buyerName': buyerName,
      'sellerName': sellerName,
      'shopName': shopName,
      'sellerImageUrl': sellerImageUrl,
      'productId': productId,
      'orderId': orderId,
      'orderImageUrl': orderImageUrl,
      'orderTitle': orderTitle,
      'orderTotal': orderTotal,
      'lastMessage': initialMessage,
      'lastMessageSenderId': initialMessage != null ? buyerId : null,
      'lastMessageTimestamp': initialMessage != null
          ? Timestamp.fromDate(now)
          : null,
      'buyerUnreadCount': 0,
      'sellerUnreadCount': initialMessage != null ? 1 : 0,
      'createdAt': Timestamp.fromDate(now),
      'updatedAt': Timestamp.fromDate(now),
    });

    if (initialMessage != null && initialMessage.isNotEmpty) {
      await sendMessage(
        conversationId: conversationId,
        text: initialMessage,
        senderId: buyerId,
        senderRole: 'buyer',
      );
    }

    return conversationId;
  }

  @override
  Future<void> updateConversationOrderDetails(
    String conversationId, {
    String? orderImageUrl,
    String? orderTitle,
    double? orderTotal,
  }) async {
    final data = <String, dynamic>{};
    if (orderImageUrl != null) data['orderImageUrl'] = orderImageUrl;
    if (orderTitle != null) data['orderTitle'] = orderTitle;
    if (orderTotal != null) data['orderTotal'] = orderTotal;
    
    if (data.isNotEmpty) {
      await _firestore
          .collection('conversations')
          .doc(conversationId)
          .update(data);
    }
  }

  @override
  Future<void> markConversationRead(
    String conversationId,
    String userId,
    bool isSeller,
  ) async {
    final field = isSeller ? 'sellerUnreadCount' : 'buyerUnreadCount';

    await _firestore.collection('conversations').doc(conversationId).update({
      field: 0,
    });
  }

  @override
  Future<ConversationModel?> getConversationByOrderId(String orderId, {String? userId, bool isSeller = false}) async {
    if (orderId.isEmpty) return null;

    var query = _firestore.collection('conversations').where('orderId', isEqualTo: orderId);
    
    if (userId != null) {
      query = query.where(isSeller ? 'sellerId' : 'buyerId', isEqualTo: userId);
    }

    final snapshot = await query.limit(1).get();

    if (snapshot.docs.isEmpty) return null;

    final doc = snapshot.docs.first;
    return ConversationModel.fromMap(doc.data(), doc.id);
  }

  @override
  Future<ConversationModel?> getConversationByParticipants(
    String buyerId,
    String sellerId,
  ) async {
    if (buyerId.isEmpty || sellerId.isEmpty) return null;

    final snapshot = await _firestore
        .collection('conversations')
        .where('buyerId', isEqualTo: buyerId)
        .where('sellerId', isEqualTo: sellerId)
        .limit(1)
        .get();

    if (snapshot.docs.isEmpty) return null;

    final doc = snapshot.docs.first;
    return ConversationModel.fromMap(doc.data(), doc.id);
  }
}
