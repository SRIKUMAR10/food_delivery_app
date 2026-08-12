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
  final String? orderTitle;
  final double? orderTotal;
  final String currentUserId;
  final List<ChatMessageModel> messages;
  final bool isSendingMessage;
  final String? errorMessage;
  final String? infoMessage;

  const DeliveryChatLoaded({
    required this.conversationId,
    required this.orderId,
    required this.customerId,
    required this.customerName,
    this.customerPhone,
    this.orderTitle,
    this.orderTotal,
    required this.currentUserId,
    this.messages = const [],
    this.isSendingMessage = false,
    this.errorMessage,
    this.infoMessage,
  });

  DeliveryChatLoaded copyWith({
    String? conversationId,
    String? orderId,
    String? customerId,
    String? customerName,
    String? customerPhone,
    String? orderTitle,
    double? orderTotal,
    String? currentUserId,
    List<ChatMessageModel>? messages,
    bool? isSendingMessage,
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
      orderTitle: orderTitle ?? this.orderTitle,
      orderTotal: orderTotal ?? this.orderTotal,
      currentUserId: currentUserId ?? this.currentUserId,
      messages: messages ?? this.messages,
      isSendingMessage: isSendingMessage ?? this.isSendingMessage,
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
        orderTitle,
        orderTotal,
        currentUserId,
        messages,
        isSendingMessage,
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
