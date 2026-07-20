import '../models/conversation_model.dart';
import '../models/chat_message_model.dart';

abstract interface class IChatRepository {
  Stream<List<ConversationModel>> getConversationsForUser(
    String userId, {
    required bool isSeller,
  });
  Stream<List<ChatMessageModel>> getMessagesStream(String conversationId);
  Future<void> sendMessage({
    required String conversationId,
    required String text,
    required String senderId,
    required String senderRole,
  });
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
  });
  Future<void> markConversationRead(
    String conversationId,
    String userId,
    bool isSeller,
  );
  Future<void> updateConversationOrderDetails(
    String conversationId, {
    String? orderImageUrl,
    String? orderTitle,
    double? orderTotal,
  });
  Future<ConversationModel?> getConversationByParticipants(
    String buyerId,
    String sellerId,
  );
  Future<ConversationModel?> getConversationByOrderId(String orderId, {String? userId, bool isSeller = false});
}
