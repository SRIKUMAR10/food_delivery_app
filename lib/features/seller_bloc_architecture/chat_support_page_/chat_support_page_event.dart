import '../../../core/models/chat_message_model.dart';

abstract class ChatSupportEvent {
  const ChatSupportEvent();
}

class DeleteSupportMessageEvent extends ChatSupportEvent {
  final ChatMessageModel message;
  final bool forEveryone;
  DeleteSupportMessageEvent(this.message, {required this.forEveryone});
}

class LoadChatSessionsEvent extends ChatSupportEvent {
  final String sellerId;
  final String? initialConversationId;
  final String? initialOrderId;
  final String? targetRole;
  final String? partnerId;
  final String? partnerName;
  final String? partnerPhone;
  final String? partnerImageUrl;
  final String? orderTitle;
  final double? orderTotal;
  LoadChatSessionsEvent(
    this.sellerId, {
    this.initialConversationId,
    this.initialOrderId,
    this.targetRole,
    this.partnerId,
    this.partnerName,
    this.partnerPhone,
    this.partnerImageUrl,
    this.orderTitle,
    this.orderTotal,
  });
}

class SelectChatSessionEvent extends ChatSupportEvent {
  final String conversationId;
  SelectChatSessionEvent(this.conversationId);
}

class SendMessageEvent extends ChatSupportEvent {
  final String conversationId;
  final String text;
  SendMessageEvent(this.conversationId, this.text);
}

class FilterChatSessions extends ChatSupportEvent {
  final String query;
  FilterChatSessions(this.query);
}

class SendSupportMediaMessage extends ChatSupportEvent {
  final String conversationId;
  final dynamic file;
  final String messageType;
  final String fileName;
  final int? duration;

  SendSupportMediaMessage({
    required this.conversationId,
    required this.file,
    required this.messageType,
    required this.fileName,
    this.duration,
  });
}

class ToggleSupportEmojiPicker extends ChatSupportEvent {
  final bool show;
  ToggleSupportEmojiPicker(this.show);
}

class StartSupportAudioRecording extends ChatSupportEvent {
  const StartSupportAudioRecording();
}

class StopSupportAudioRecording extends ChatSupportEvent {
  final String conversationId;
  const StopSupportAudioRecording(this.conversationId);
}

class CancelSupportAudioRecording extends ChatSupportEvent {
  const CancelSupportAudioRecording();
}

class SetTypingStatusEvent extends ChatSupportEvent {
  final bool isTyping;
  final String? conversationId;
  const SetTypingStatusEvent(this.isTyping, {this.conversationId});
}

enum ChatFilterTab { all, customers, deliveryPartners, orders }

class SetChatFilterTabEvent extends ChatSupportEvent {
  final ChatFilterTab tab;
  const SetChatFilterTabEvent(this.tab);
}

class StartOrderDeliveryPartnerChatEvent extends ChatSupportEvent {
  final String orderId;
  final String riderId;
  final String riderName;
  final String? riderPhone;
  final String? riderImageUrl;
  final String? orderTitle;
  final double? orderTotal;
  const StartOrderDeliveryPartnerChatEvent({
    required this.orderId,
    required this.riderId,
    required this.riderName,
    this.riderPhone,
    this.riderImageUrl,
    this.orderTitle,
    this.orderTotal,
  });
}

class AutoOpenOrderConversationEvent extends ChatSupportEvent {
  final String orderId;
  final String? targetRole;
  const AutoOpenOrderConversationEvent({required this.orderId, this.targetRole});
}

