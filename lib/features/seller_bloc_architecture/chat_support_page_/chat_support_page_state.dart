import '../../../core/models/conversation_model.dart';
import '../../../core/models/chat_message_model.dart';
import 'chat_support_page_event.dart';

abstract class ChatSupportState {}

class ChatSupportInitial extends ChatSupportState {}

class ChatSupportLoading extends ChatSupportState {}

class ChatSupportLoaded extends ChatSupportState {
  final String currentUserId;
  final List<ConversationModel> conversations;
  final String? selectedConversationId;
  final List<ChatMessageModel> messages;
  final bool isSendingMessage;
  final String? errorMessage;
  final String searchQuery;
  final bool showEmojiPicker;
  final bool isRecording;
  final Duration recordingDuration;
  final ChatFilterTab activeFilterTab;
  final Map<String, bool> typingUsers;
  final String? initialOrderId;

  ChatSupportLoaded({
    required this.currentUserId,
    required this.conversations,
    this.selectedConversationId,
    this.messages = const [],
    this.isSendingMessage = false,
    this.errorMessage,
    this.searchQuery = '',
    this.showEmojiPicker = false,
    this.isRecording = false,
    this.recordingDuration = Duration.zero,
    this.activeFilterTab = ChatFilterTab.all,
    this.typingUsers = const {},
    this.initialOrderId,
  });

  ConversationModel? get selectedConversation {
    if (selectedConversationId == null) return null;
    try {
      return conversations.firstWhere((c) => c.id == selectedConversationId);
    } catch (e) {
      return null;
    }
  }

  List<ConversationModel> get filteredConversations {
    final conversationsForTab = filteredConversationsByTab;
    if (searchQuery.isEmpty) return conversationsForTab;
    final q = searchQuery.toLowerCase();
    return conversationsForTab.where((c) {
      final orderMatch = c.orderId?.toLowerCase().contains(q) ?? false;
      final nameMatch = c.buyerName.toLowerCase().contains(q) ||
          c.sellerName.toLowerCase().contains(q) ||
          (c.deliveryPartnerName?.toLowerCase().contains(q) ?? false);
      final shopMatch = c.shopName?.toLowerCase().contains(q) ?? false;
      return orderMatch || nameMatch || shopMatch;
    }).toList();
  }

  /// Conversations filtered by the active category tab only (search applied
  /// separately through [filteredConversations]).
  List<ConversationModel> get filteredConversationsByTab {
    switch (activeFilterTab) {
      case ChatFilterTab.all:
        return conversations;
      case ChatFilterTab.customers:
        return conversations
            .where((c) =>
                c.conversationType == 'buyer_seller' &&
                c.deliveryPartnerId == null)
            .toList();
      case ChatFilterTab.deliveryPartners:
        return conversations
            .where((c) =>
                c.conversationType == 'seller_delivery' ||
                c.conversationType == 'buyer_delivery' ||
                (c.deliveryPartnerId != null && c.deliveryPartnerId!.isNotEmpty))
            .toList();
      case ChatFilterTab.orders:
        return conversations
            .where((c) => c.orderId != null && c.orderId!.isNotEmpty)
            .toList();
    }
  }

  /// Whether the other participant (buyer or delivery partner) is currently
  /// typing in the selected conversation.
  bool get isOtherUserTyping {
    final conversation = selectedConversation;
    if (conversation == null) return false;
    return typingUsers.entries.any((entry) =>
        entry.key != currentUserId && entry.value);
  }

  /// Resolves the display name of the participant who is currently typing.
  String? get otherUserTypingName {
    final conversation = selectedConversation;
    if (conversation == null) return null;
    for (final entry in typingUsers.entries) {
      if (entry.key == currentUserId || !entry.value) continue;
      if (entry.key == conversation.deliveryPartnerId) {
        return conversation.deliveryPartnerName ?? 'Delivery Partner';
      }
      if (entry.key == conversation.buyerId) {
        return conversation.buyerName.isNotEmpty
            ? conversation.buyerName
            : 'Buyer';
      }
      if (entry.key == conversation.sellerId) {
        return conversation.sellerName;
      }
    }
    return null;
  }

  ChatSupportLoaded copyWith({
    String? currentUserId,
    List<ConversationModel>? conversations,
    String? selectedConversationId,
    List<ChatMessageModel>? messages,
    bool? isSendingMessage,
    String? errorMessage,
    bool clearError = false,
    String? searchQuery,
    bool? showEmojiPicker,
    bool? isRecording,
    Duration? recordingDuration,
    ChatFilterTab? activeFilterTab,
    Map<String, bool>? typingUsers,
    String? initialOrderId,
  }) {
    return ChatSupportLoaded(
      currentUserId: currentUserId ?? this.currentUserId,
      conversations: conversations ?? this.conversations,
      selectedConversationId:
          selectedConversationId ?? this.selectedConversationId,
      messages: messages ?? this.messages,
      isSendingMessage: isSendingMessage ?? this.isSendingMessage,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      searchQuery: searchQuery ?? this.searchQuery,
      showEmojiPicker: showEmojiPicker ?? this.showEmojiPicker,
      isRecording: isRecording ?? this.isRecording,
      recordingDuration: recordingDuration ?? this.recordingDuration,
      activeFilterTab: activeFilterTab ?? this.activeFilterTab,
      typingUsers: typingUsers ?? this.typingUsers,
      initialOrderId: initialOrderId ?? this.initialOrderId,
    );
  }
}

class ChatSupportError extends ChatSupportState {
  final String message;
  ChatSupportError(this.message);
}
