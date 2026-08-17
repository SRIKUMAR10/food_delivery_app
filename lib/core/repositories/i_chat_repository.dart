import '../models/conversation_model.dart';
import '../models/chat_message_model.dart';

abstract interface class IChatRepository {
  /// Streams conversations for a user.
  ///
  /// [isSeller] is kept for backward compatibility. When [role] is provided it
  /// takes precedence. Supported roles: 'buyer', 'seller', 'delivery_partner'.
  Stream<List<ConversationModel>> getConversationsForUser(
    String userId, {
    bool isSeller = false,
    String? role,
  });

  Stream<List<ChatMessageModel>> getMessagesStream(String conversationId);

  Future<void> sendMessage({
    required String conversationId,
    required String text,
    required String senderId,
    required String senderRole,
    String? receiverId,
    String? messageType,
    String? mediaUrl,
    String? fileName,
    int? fileSize,
    int? duration,
  });

  Future<void> deleteMessage({
    required String conversationId,
    required String messageId,
    required String messageType,
    required bool forEveryone,
    required String userId,
  });

  Future<String> uploadChatAttachment(
    dynamic file, // Can be File or byte array depending on platform
    String conversationId,
    String fileName,
  );

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
    String? deliveryPartnerId,
    String? deliveryPartnerName,
    String? deliveryPartnerPhone,
    String? deliveryPartnerImageUrl,
    String? conversationType,
    List<String>? participants,
    Map<String, String>? participantRoles,
  });

  /// Marks the unread counter of [userId] to zero (legacy helper) and marks
  /// all messages sent by the other party as read.
  Future<void> markConversationRead(
    String conversationId,
    String userId,
    bool isSeller,
  );

  /// Marks all messages sent to [readerId] (i.e. sent by anyone other than
  /// [readerId]) in the conversation as read with a read receipt timestamp.
  Future<void> markMessagesAsRead({
    required String conversationId,
    required String readerId,
  });

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

  /// Finds a conversation between two participants, optionally scoped to an
  /// order and/or conversation type. Supports legacy `buyerId`/`sellerId`
  /// fields as well as the `participants` array.
  Future<ConversationModel?> getConversationBetween({
    required String user1Id,
    required String user2Id,
    String? orderId,
    String? type,
  });

  Future<ConversationModel?> getConversationByOrderId(String orderId, {String? userId, bool isSeller = false});

  /// Sets the typing status for [userId] in [conversationId]. When [isTyping]
  /// is false the typing document is removed to avoid stale entries.
  Future<void> setTypingStatus({
    required String conversationId,
    required String userId,
    required bool isTyping,
  });

  /// Streams a live map of `userId -> isTyping` for a conversation. Entries
  /// with a stale server timestamp (older than the auto-reset window) are
  /// reported as `false`.
  Stream<Map<String, bool>> getTypingStatusStream(String conversationId);
}
