import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../core/repositories/i_chat_repository.dart';
import '../../../core/models/conversation_model.dart';

abstract class DeliveryChatRepositoryBase {
  Stream<List<ConversationModel>> getDeliveryConversations(String riderId);
  Future<ConversationModel?> getConversationByOrderId(String orderId, String riderId);
  Future<String> createOrGetConversation({
    required String orderId,
    required String customerId,
    required String customerName,
    required String riderId,
    required String riderName,
    String? orderTitle,
    double? orderTotal,
  });
  Future<String> createOrGetSellerDeliveryConversation({
    required String orderId,
    required String sellerId,
    required String sellerName,
    required String riderId,
    required String riderName,
    String? orderTitle,
    double? orderTotal,
  });
  Future<String> uploadAttachment(
    dynamic file,
    String conversationId,
    String fileName,
  );
  Future<void> setTypingStatus({
    required String conversationId,
    required String userId,
    required bool isTyping,
  });
  Stream<Map<String, bool>> getTypingStatusStream(String conversationId);
}

class DeliveryChatRepository implements DeliveryChatRepositoryBase {
  final IChatRepository chatRepository;
  final FirebaseFirestore firestore;
  final FirebaseAuth auth;

  DeliveryChatRepository({
    required this.chatRepository,
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  })  : firestore = firestore ?? FirebaseFirestore.instance,
        auth = auth ?? FirebaseAuth.instance;

  @override
  Stream<List<ConversationModel>> getDeliveryConversations(String riderId) {
    return chatRepository.getConversationsForUser(
      riderId,
      role: 'delivery_partner',
    );
  }

  @override
  Future<ConversationModel?> getConversationByOrderId(
      String orderId, String riderId) async {
    return chatRepository.getConversationByOrderId(
      orderId,
      userId: riderId,
      isSeller: true,
    );
  }

  @override
  Future<String> createOrGetConversation({
    required String orderId,
    required String customerId,
    required String customerName,
    required String riderId,
    required String riderName,
    String? orderTitle,
    double? orderTotal,
  }) async {
    final existing = await chatRepository.getConversationBetween(
      user1Id: customerId,
      user2Id: riderId,
      orderId: orderId.isNotEmpty ? orderId : null,
      type: 'buyer_delivery',
    );

    if (existing != null) {
      if (orderId != existing.orderId && orderId.isNotEmpty) {
        await firestore.collection('conversations').doc(existing.id).update({
          'orderId': orderId,
          if (orderTitle != null) 'orderTitle': orderTitle,
          if (orderTotal != null) 'orderTotal': orderTotal,
        });
      }
      return existing.id;
    }

    return chatRepository.createConversation(
      buyerId: customerId,
      buyerName: customerName,
      sellerId: '',
      sellerName: '',
      deliveryPartnerId: riderId,
      deliveryPartnerName: riderName,
      conversationType: 'buyer_delivery',
      orderId: orderId,
      orderTitle: orderTitle,
      orderTotal: orderTotal,
    );
  }

  @override
  Future<String> createOrGetSellerDeliveryConversation({
    required String orderId,
    required String sellerId,
    required String sellerName,
    required String riderId,
    required String riderName,
    String? orderTitle,
    double? orderTotal,
  }) async {
    final existing = await chatRepository.getConversationBetween(
      user1Id: sellerId,
      user2Id: riderId,
      orderId: orderId.isNotEmpty ? orderId : null,
      type: 'seller_delivery',
    );

    if (existing != null) {
      if (orderId != existing.orderId && orderId.isNotEmpty) {
        await firestore.collection('conversations').doc(existing.id).update({
          'orderId': orderId,
          if (orderTitle != null) 'orderTitle': orderTitle,
          if (orderTotal != null) 'orderTotal': orderTotal,
        });
      }
      return existing.id;
    }

    return chatRepository.createConversation(
      buyerId: '',
      buyerName: '',
      sellerId: sellerId,
      sellerName: sellerName,
      deliveryPartnerId: riderId,
      deliveryPartnerName: riderName,
      conversationType: 'seller_delivery',
      orderId: orderId,
      orderTitle: orderTitle,
      orderTotal: orderTotal,
    );
  }

  @override
  Future<String> uploadAttachment(
    dynamic file,
    String conversationId,
    String fileName,
  ) {
    return chatRepository.uploadChatAttachment(file, conversationId, fileName);
  }

  @override
  Future<void> setTypingStatus({
    required String conversationId,
    required String userId,
    required bool isTyping,
  }) {
    return chatRepository.setTypingStatus(
      conversationId: conversationId,
      userId: userId,
      isTyping: isTyping,
    );
  }

  @override
  Stream<Map<String, bool>> getTypingStatusStream(String conversationId) {
    return chatRepository.getTypingStatusStream(conversationId);
  }
}
