import 'package:equatable/equatable.dart';
import '../../../core/models/chat_message_model.dart';

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
  final String currentUserId;
  final List<ChatMessageModel> messages;
  final bool isSendingMessage;
  final bool isUploadingAttachment;
  final bool isRecordingAudio;
  final Map<String, bool> typingUsers;
  final String? errorMessage;
  final String? infoMessage;

  const DeliveryChatLoaded({
    required this.conversationId,
    required this.orderId,
    this.customerId = '',
    this.customerName = '',
    this.customerPhone,
    this.sellerId,
    this.sellerName,
    this.sellerPhone,
    this.recipientRole = 'customer',
    required this.recipientId,
    required this.recipientName,
    this.recipientPhone,
    this.orderTitle,
    this.orderTotal,
    required this.currentUserId,
    this.messages = const [],
    this.isSendingMessage = false,
    this.isUploadingAttachment = false,
    this.isRecordingAudio = false,
    this.typingUsers = const {},
    this.errorMessage,
    this.infoMessage,
  });

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
    String? currentUserId,
    List<ChatMessageModel>? messages,
    bool? isSendingMessage,
    bool? isUploadingAttachment,
    bool? isRecordingAudio,
    Map<String, bool>? typingUsers,
    String? errorMessage,
    bool clearError = false,
    String? infoMessage,
    bool clearInfo = false,
  }) {
    return DeliveryChatLoaded(
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
      currentUserId: currentUserId ?? this.currentUserId,
      messages: messages ?? this.messages,
      isSendingMessage: isSendingMessage ?? this.isSendingMessage,
      isUploadingAttachment: isUploadingAttachment ?? this.isUploadingAttachment,
      isRecordingAudio: isRecordingAudio ?? this.isRecordingAudio,
      typingUsers: typingUsers ?? this.typingUsers,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      infoMessage: clearInfo ? null : (infoMessage ?? this.infoMessage),
    );
  }

  @override
  List<Object?> get props => [
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
        currentUserId,
        messages,
        isSendingMessage,
        isUploadingAttachment,
        isRecordingAudio,
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
