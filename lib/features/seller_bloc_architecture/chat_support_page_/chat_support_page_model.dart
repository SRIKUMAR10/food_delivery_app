// DEPRECATED: Replaced by core/models/chat_message_model.dart and core/models/conversation_model.dart.
// Kept as rollback backup until Phase 4 migration is fully verified.
class ChatMessageModel {
  final String id;
  final String text;
  final String senderId; // 'seller' or 'customer' or 'support'
  final DateTime timestamp;
  final bool isRead;

  ChatMessageModel({
    required this.id,
    required this.text,
    required this.senderId,
    required this.timestamp,
    this.isRead = false,
  });

  ChatMessageModel copyWith({
    String? id,
    String? text,
    String? senderId,
    DateTime? timestamp,
    bool? isRead,
  }) {
    return ChatMessageModel(
      id: id ?? this.id,
      text: text ?? this.text,
      senderId: senderId ?? this.senderId,
      timestamp: timestamp ?? this.timestamp,
      isRead: isRead ?? this.isRead,
    );
  }
}

class ChatSessionModel {
  final String sessionId;
  final String customerName;
  final String orderId;
  final List<ChatMessageModel> messages;
  final int unreadCount;

  ChatSessionModel({
    required this.sessionId,
    required this.customerName,
    required this.orderId,
    required this.messages,
    this.unreadCount = 0,
  });

  ChatSessionModel copyWith({
    String? sessionId,
    String? customerName,
    String? orderId,
    List<ChatMessageModel>? messages,
    int? unreadCount,
  }) {
    return ChatSessionModel(
      sessionId: sessionId ?? this.sessionId,
      customerName: customerName ?? this.customerName,
      orderId: orderId ?? this.orderId,
      messages: messages ?? this.messages,
      unreadCount: unreadCount ?? this.unreadCount,
    );
  }
}
