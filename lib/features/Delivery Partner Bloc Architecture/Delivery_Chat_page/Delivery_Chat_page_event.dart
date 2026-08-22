import 'package:equatable/equatable.dart';

abstract class DeliveryChatEvent extends Equatable {
  const DeliveryChatEvent();

  @override
  List<Object?> get props => [];
}

class LoadDeliveryConversations extends DeliveryChatEvent {
  const LoadDeliveryConversations();
}

class SelectDeliveryConversation extends DeliveryChatEvent {
  final String conversationId;

  const SelectDeliveryConversation(this.conversationId);

  @override
  List<Object?> get props => [conversationId];
}

class ClearSelectedDeliveryConversation extends DeliveryChatEvent {
  const ClearSelectedDeliveryConversation();
}

class SetDeliveryChatFilter extends DeliveryChatEvent {
  final String activeFilter; // 'all', 'seller', 'customer'

  const SetDeliveryChatFilter(this.activeFilter);

  @override
  List<Object?> get props => [activeFilter];
}

class SearchDeliveryConversations extends DeliveryChatEvent {
  final String query;

  const SearchDeliveryConversations(this.query);

  @override
  List<Object?> get props => [query];
}

class InitDeliveryChatEvent extends DeliveryChatEvent {
  final String orderId;
  final String customerId;
  final String customerName;
  final String? customerPhone;
  final String? sellerId;
  final String? sellerName;
  final String? sellerPhone;
  final String recipientRole; // 'customer' or 'seller' / 'merchant'
  final String? recipientId;
  final String? recipientName;
  final String? recipientPhone;
  final String? orderTitle;
  final double? orderTotal;
  final String? orderImageUrl;

  const InitDeliveryChatEvent({
    required this.orderId,
    this.customerId = '',
    this.customerName = '',
    this.customerPhone,
    this.sellerId,
    this.sellerName,
    this.sellerPhone,
    this.recipientRole = 'customer',
    this.recipientId,
    this.recipientName,
    this.recipientPhone,
    this.orderTitle,
    this.orderTotal,
    this.orderImageUrl,
  });

  String get effectiveRecipientId {
    if (recipientId != null && recipientId!.isNotEmpty) return recipientId!;
    if (isSellerChat) return sellerId ?? '';
    return customerId;
  }

  String get effectiveRecipientName {
    if (recipientName != null && recipientName!.isNotEmpty) return recipientName!;
    if (isSellerChat) return sellerName ?? 'Restaurant / Merchant';
    return customerName.isNotEmpty ? customerName : 'Customer';
  }

  String? get effectiveRecipientPhone {
    if (recipientPhone != null && recipientPhone!.isNotEmpty) return recipientPhone;
    if (isSellerChat) return sellerPhone;
    return customerPhone;
  }

  bool get isSellerChat {
    final r = recipientRole.toLowerCase();
    return r == 'seller' || r == 'merchant' || r == 'restaurant';
  }

  @override
  List<Object?> get props => [
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
      ];
}

class SendDeliveryMessageEvent extends DeliveryChatEvent {
  final String text;

  const SendDeliveryMessageEvent(this.text);

  @override
  List<Object?> get props => [text];
}

class SendDeliveryMediaMessageEvent extends DeliveryChatEvent {
  final String messageType; // 'image', 'audio', 'document'
  final String mediaUrl;
  final String? text;
  final String? fileName;
  final int? fileSize;
  final int? duration;

  const SendDeliveryMediaMessageEvent({
    required this.messageType,
    required this.mediaUrl,
    this.text,
    this.fileName,
    this.fileSize,
    this.duration,
  });

  @override
  List<Object?> get props => [messageType, mediaUrl, text, fileName, fileSize, duration];
}

class SendDeliveryQuickReplyEvent extends DeliveryChatEvent {
  final String text;

  const SendDeliveryQuickReplyEvent(this.text);

  @override
  List<Object?> get props => [text];
}

class PickDeliveryAttachmentEvent extends DeliveryChatEvent {
  final bool fromCamera;

  const PickDeliveryAttachmentEvent({this.fromCamera = false});

  @override
  List<Object?> get props => [fromCamera];
}

class SendAudioVoiceNoteEvent extends DeliveryChatEvent {
  final dynamic audioFile; // File or byte data
  final int durationSeconds;

  const SendAudioVoiceNoteEvent({
    required this.audioFile,
    required this.durationSeconds,
  });

  @override
  List<Object?> get props => [audioFile, durationSeconds];
}

class SetDeliveryTypingStatusEvent extends DeliveryChatEvent {
  final bool isTyping;

  const SetDeliveryTypingStatusEvent(this.isTyping);

  @override
  List<Object?> get props => [isTyping];
}

class MarkDeliveryChatReadEvent extends DeliveryChatEvent {
  const MarkDeliveryChatReadEvent();
}

class ToggleDeliveryEmojiPicker extends DeliveryChatEvent {
  const ToggleDeliveryEmojiPicker();
}

class StartDeliveryAudioRecording extends DeliveryChatEvent {
  const StartDeliveryAudioRecording();
}

class StopDeliveryAudioRecording extends DeliveryChatEvent {
  const StopDeliveryAudioRecording();
}

class CancelDeliveryAudioRecording extends DeliveryChatEvent {
  const CancelDeliveryAudioRecording();
}

class UpdateDeliveryAudioRecordingDuration extends DeliveryChatEvent {
  final Duration duration;
  const UpdateDeliveryAudioRecordingDuration(this.duration);

  @override
  List<Object?> get props => [duration];
}

class DeleteDeliveryMessage extends DeliveryChatEvent {
  final String messageId;
  const DeleteDeliveryMessage(this.messageId);

  @override
  List<Object?> get props => [messageId];
}
