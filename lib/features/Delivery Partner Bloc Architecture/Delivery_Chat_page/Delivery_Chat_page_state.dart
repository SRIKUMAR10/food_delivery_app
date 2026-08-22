import 'package:equatable/equatable.dart';
import '../../../core/models/chat_message_model.dart';
import '../../../core/models/conversation_model.dart';

abstract class DeliveryChatState extends Equatable {
  const DeliveryChatState();

  @override
  List<Object?> get props => [];
}

class DeliveryChatInitial extends DeliveryChatState {
  const DeliveryChatInitial();
}

class DeliveryChatLoading extends DeliveryChatState {
  const DeliveryChatLoading();
}

class DeliveryChatLoaded extends DeliveryChatState {
  final String currentUserId;
  final List<ConversationModel> conversations;
  final String? selectedConversationId;
  final String conversationId;
  final String orderId;
  final String customerId;
  final String customerName;
  final String? customerPhone;
  final String? sellerId;
  final String? sellerName;
  final String? sellerPhone;
  final String recipientRole; // 'customer' or 'seller' / 'merchant'
  final String recipientId;
  final String recipientName;
  final String? recipientPhone;
  final String? orderTitle;
  final double? orderTotal;
  final String? orderImageUrl;
  final String? orderStatus;
  final List<ChatMessageModel> messages;
  final bool isSendingMessage;
  final bool isUploadingAttachment;
  final bool isRecordingAudio;
  final Duration recordingDuration;
  final bool showEmojiPicker;
  final String searchQuery;
  final String activeFilter; // 'all', 'seller', 'customer'
  final Map<String, bool> typingUsers;
  final String? errorMessage;
  final String? infoMessage;

  const DeliveryChatLoaded({
    required this.currentUserId,
    this.conversations = const [],
    this.selectedConversationId,
    this.conversationId = '',
    this.orderId = '',
    this.customerId = '',
    this.customerName = '',
    this.customerPhone,
    this.sellerId,
    this.sellerName,
    this.sellerPhone,
    this.recipientRole = 'customer',
    this.recipientId = '',
    this.recipientName = '',
    this.recipientPhone,
    this.orderTitle,
    this.orderTotal,
    this.orderImageUrl,
    this.orderStatus,
    this.messages = const [],
    this.isSendingMessage = false,
    this.isUploadingAttachment = false,
    this.isRecordingAudio = false,
    this.recordingDuration = Duration.zero,
    this.showEmojiPicker = false,
    this.searchQuery = '',
    this.activeFilter = 'all',
    this.typingUsers = const {},
    this.errorMessage,
    this.infoMessage,
  });

  ConversationModel? get selectedConversation {
    if (selectedConversationId == null || selectedConversationId!.isEmpty) {
      if (conversationId.isNotEmpty) {
        try {
          return conversations.firstWhere((c) => c.id == conversationId);
        } catch (_) {}
      }
      return null;
    }
    try {
      return conversations.firstWhere((c) => c.id == selectedConversationId);
    } catch (_) {
      return null;
    }
  }

  List<ConversationModel> get filteredConversations {
    final q = searchQuery.trim().toLowerCase();
    return conversations.where((c) {
      final isSeller = c.conversationType == 'seller_delivery' ||
          c.conversationType == 'seller_support' ||
          c.conversationType == 'seller';
      final isCustomer = !isSeller;

      final matchesFilter = switch (activeFilter) {
        'seller' => isSeller,
        'customer' => isCustomer,
        _ => true,
      };
      if (!matchesFilter) return false;

      if (q.isEmpty) return true;
      final shopMatch = c.shopName?.toLowerCase().contains(q) ?? false;
      final orderMatch = c.orderId?.toLowerCase().contains(q) ?? false;
      final sellerMatch = c.sellerName.toLowerCase().contains(q);
      final buyerMatch = c.buyerName.toLowerCase().contains(q);
      final lastMsgMatch = c.lastMessage?.toLowerCase().contains(q) ?? false;
      return shopMatch || orderMatch || sellerMatch || buyerMatch || lastMsgMatch;
    }).toList();
  }

  bool get isSellerChat {
    final r = recipientRole.toLowerCase();
    return r == 'seller' || r == 'merchant' || r == 'restaurant';
  }

  bool get isOtherPartyTyping {
    if (typingUsers.isEmpty) return false;
    for (final entry in typingUsers.entries) {
      if (entry.key != currentUserId && entry.value == true) {
        return true;
      }
    }
    return false;
  }

  DeliveryChatLoaded copyWith({
    String? currentUserId,
    List<ConversationModel>? conversations,
    String? selectedConversationId,
    bool clearSelectedConversationId = false,
    String? conversationId,
    String? orderId,
    String? customerId,
    String? customerName,
    String? customerPhone,
    String? sellerId,
    String? sellerName,
    String? sellerPhone,
    String? recipientRole,
    String? recipientId,
    String? recipientName,
    String? recipientPhone,
    String? orderTitle,
    double? orderTotal,
    String? orderImageUrl,
    String? orderStatus,
    List<ChatMessageModel>? messages,
    bool? isSendingMessage,
    bool? isUploadingAttachment,
    bool? isRecordingAudio,
    Duration? recordingDuration,
    bool? showEmojiPicker,
    String? searchQuery,
    String? activeFilter,
    Map<String, bool>? typingUsers,
    String? errorMessage,
    bool clearError = false,
    String? infoMessage,
    bool clearInfo = false,
  }) {
    return DeliveryChatLoaded(
      currentUserId: currentUserId ?? this.currentUserId,
      conversations: conversations ?? this.conversations,
      selectedConversationId: clearSelectedConversationId
          ? null
          : (selectedConversationId ?? this.selectedConversationId),
      conversationId: conversationId ?? this.conversationId,
      orderId: orderId ?? this.orderId,
      customerId: customerId ?? this.customerId,
      customerName: customerName ?? this.customerName,
      customerPhone: customerPhone ?? this.customerPhone,
      sellerId: sellerId ?? this.sellerId,
      sellerName: sellerName ?? this.sellerName,
      sellerPhone: sellerPhone ?? this.sellerPhone,
      recipientRole: recipientRole ?? this.recipientRole,
      recipientId: recipientId ?? this.recipientId,
      recipientName: recipientName ?? this.recipientName,
      recipientPhone: recipientPhone ?? this.recipientPhone,
      orderTitle: orderTitle ?? this.orderTitle,
      orderTotal: orderTotal ?? this.orderTotal,
      orderImageUrl: orderImageUrl ?? this.orderImageUrl,
      orderStatus: orderStatus ?? this.orderStatus,
      messages: messages ?? this.messages,
      isSendingMessage: isSendingMessage ?? this.isSendingMessage,
      isUploadingAttachment: isUploadingAttachment ?? this.isUploadingAttachment,
      isRecordingAudio: isRecordingAudio ?? this.isRecordingAudio,
      recordingDuration: recordingDuration ?? this.recordingDuration,
      showEmojiPicker: showEmojiPicker ?? this.showEmojiPicker,
      searchQuery: searchQuery ?? this.searchQuery,
      activeFilter: activeFilter ?? this.activeFilter,
      typingUsers: typingUsers ?? this.typingUsers,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      infoMessage: clearInfo ? null : (infoMessage ?? this.infoMessage),
    );
  }

  @override
  List<Object?> get props => [
        currentUserId,
        conversations,
        selectedConversationId,
        conversationId,
        orderId,
        customerId,
        customerName,
        customerPhone,
        sellerId,
        sellerName,
        sellerPhone,
        recipientRole,
        recipientId,
        recipientName,
        recipientPhone,
        orderTitle,
        orderTotal,
        orderImageUrl,
        orderStatus,
        messages,
        isSendingMessage,
        isUploadingAttachment,
        isRecordingAudio,
        recordingDuration,
        showEmojiPicker,
        searchQuery,
        activeFilter,
        typingUsers,
        errorMessage,
        infoMessage,
      ];
}

class DeliveryChatError extends DeliveryChatState {
  final String message;

  const DeliveryChatError(this.message);

  @override
  List<Object?> get props => [message];
}
