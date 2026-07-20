import '../../../core/models/conversation_model.dart';
import '../../../core/models/chat_message_model.dart';

abstract class BuyerChatState {}

class BuyerChatInitial extends BuyerChatState {}

class BuyerChatLoading extends BuyerChatState {}

class BuyerChatLoaded extends BuyerChatState {
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

  BuyerChatLoaded({
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
    if (searchQuery.isEmpty) return conversations;
    final q = searchQuery.toLowerCase();
    return conversations.where((c) {
      final shopMatch = c.shopName?.toLowerCase().contains(q) ?? false;
      final orderMatch = c.orderId?.toLowerCase().contains(q) ?? false;
      final nameMatch = c.sellerName.toLowerCase().contains(q) ||
          c.buyerName.toLowerCase().contains(q);
      return shopMatch || orderMatch || nameMatch;
    }).toList();
  }

  BuyerChatLoaded copyWith({
    String? currentUserId,
    List<ConversationModel>? conversations,
    String? selectedConversationId,
    bool clearSelectedConversationId = false,
    List<ChatMessageModel>? messages,
    bool? isSendingMessage,
    String? errorMessage,
    bool clearError = false,
    String? searchQuery,
    bool? showEmojiPicker,
    bool? isRecording,
    Duration? recordingDuration,
  }) {
    return BuyerChatLoaded(
      currentUserId: currentUserId ?? this.currentUserId,
      conversations: conversations ?? this.conversations,
      selectedConversationId: clearSelectedConversationId 
          ? null 
          : (selectedConversationId ?? this.selectedConversationId),
      messages: messages ?? this.messages,
      isSendingMessage: isSendingMessage ?? this.isSendingMessage,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      searchQuery: searchQuery ?? this.searchQuery,
      showEmojiPicker: showEmojiPicker ?? this.showEmojiPicker,
      isRecording: isRecording ?? this.isRecording,
      recordingDuration: recordingDuration ?? this.recordingDuration,
    );
  }
}

class BuyerChatError extends BuyerChatState {
  final String message;
  BuyerChatError(this.message);
}
