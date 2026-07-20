abstract class BuyerChatEvent {}

class LoadBuyerConversations extends BuyerChatEvent {}

class SelectBuyerConversation extends BuyerChatEvent {
  final String conversationId;
  SelectBuyerConversation(this.conversationId);
}

class SendBuyerMessage extends BuyerChatEvent {
  final String conversationId;
  final String text;
  SendBuyerMessage(this.conversationId, this.text);
}

class StartBuyerConversation extends BuyerChatEvent {
  final String sellerId;
  final String sellerName;
  final String buyerName;
  final String? shopName;
  final String? sellerImageUrl;
  final String? orderId;
  final String? initialMessage;

  StartBuyerConversation({
    required this.sellerId,
    required this.sellerName,
    required this.buyerName,
    this.shopName,
    this.sellerImageUrl,
    this.orderId,
    this.initialMessage,
  });
}

class FilterBuyerConversations extends BuyerChatEvent {
  final String query;
  FilterBuyerConversations(this.query);
}

class SendBuyerMediaMessage extends BuyerChatEvent {
  final String conversationId;
  final dynamic file; // File or byte array
  final String messageType; // 'image', 'audio', 'document'
  final String fileName;
  final int? duration;

  SendBuyerMediaMessage({
    required this.conversationId,
    required this.file,
    required this.messageType,
    required this.fileName,
    this.duration,
  });
}

class ToggleEmojiPicker extends BuyerChatEvent {
  final bool show;
  ToggleEmojiPicker(this.show);
}

class StartAudioRecording extends BuyerChatEvent {}

class StopAudioRecording extends BuyerChatEvent {
  final String conversationId;
  StopAudioRecording(this.conversationId);
}

class CancelAudioRecording extends BuyerChatEvent {}
