import 'package:equatable/equatable.dart';
import '../../../core/models/chat_message_model.dart';
import '../home_Page/home_page_models.dart';

abstract class BuyerChatEvent extends Equatable {
  const BuyerChatEvent();

  @override
  List<Object?> get props => [];
}

class LoadBuyerConversations extends BuyerChatEvent {
  const LoadBuyerConversations();
}

class SelectBuyerConversation extends BuyerChatEvent {
  final String conversationId;
  const SelectBuyerConversation(this.conversationId);

  @override
  List<Object?> get props => [conversationId];
}

class SendBuyerMessage extends BuyerChatEvent {
  final String conversationId;
  final String text;
  const SendBuyerMessage(this.conversationId, this.text);

  @override
  List<Object?> get props => [conversationId, text];
}

class DeleteBuyerMessage extends BuyerChatEvent {
  final ChatMessageModel message;
  final bool forEveryone;
  const DeleteBuyerMessage(this.message, {required this.forEveryone});

  @override
  List<Object?> get props => [message, forEveryone];
}

class StartBuyerConversation extends BuyerChatEvent {
  final String sellerId;
  final String sellerName;
  final String buyerName;
  final String? shopName;
  final String? sellerImageUrl;
  final String? orderId;
  final String? initialMessage;

  const StartBuyerConversation({
    required this.sellerId,
    required this.sellerName,
    required this.buyerName,
    this.shopName,
    this.sellerImageUrl,
    this.orderId,
    this.initialMessage,
  });

  @override
  List<Object?> get props => [sellerId, sellerName, buyerName, shopName, sellerImageUrl, orderId, initialMessage];
}

class FilterBuyerConversations extends BuyerChatEvent {
  final String query;
  const FilterBuyerConversations(this.query);

  @override
  List<Object?> get props => [query];
}

class SendBuyerMediaMessage extends BuyerChatEvent {
  final String conversationId;
  final dynamic file;
  final String messageType;
  final String fileName;
  final int? duration;

  const SendBuyerMediaMessage({
    required this.conversationId,
    required this.file,
    required this.messageType,
    required this.fileName,
    this.duration,
  });

  @override
  List<Object?> get props => [conversationId, messageType, fileName, duration];
}

class ToggleEmojiPicker extends BuyerChatEvent {
  final bool show;
  const ToggleEmojiPicker(this.show);

  @override
  List<Object?> get props => [show];
}

class StartAudioRecording extends BuyerChatEvent {
  const StartAudioRecording();
}

class StopAudioRecording extends BuyerChatEvent {
  final String conversationId;
  const StopAudioRecording(this.conversationId);

  @override
  List<Object?> get props => [conversationId];
}

class CancelAudioRecording extends BuyerChatEvent {
  const CancelAudioRecording();
}

class SelectProductForSupport extends BuyerChatEvent {
  final FoodItem? product;
  const SelectProductForSupport(this.product);

  @override
  List<Object?> get props => [product];
}

class StartDeliveryPartnerConversation extends BuyerChatEvent {
  final String deliveryPartnerId;
  final String deliveryPartnerName;
  final String buyerName;
  final String? deliveryPartnerPhone;
  final String? deliveryPartnerImageUrl;
  final String? orderId;
  final String? orderTitle;
  final double? orderTotal;
  final String? initialMessage;

  const StartDeliveryPartnerConversation({
    required this.deliveryPartnerId,
    required this.deliveryPartnerName,
    required this.buyerName,
    this.deliveryPartnerPhone,
    this.deliveryPartnerImageUrl,
    this.orderId,
    this.orderTitle,
    this.orderTotal,
    this.initialMessage,
  });

  @override
  List<Object?> get props => [
        deliveryPartnerId,
        deliveryPartnerName,
        buyerName,
        deliveryPartnerPhone,
        deliveryPartnerImageUrl,
        orderId,
        orderTitle,
        orderTotal,
        initialMessage,
      ];
}

class MarkMessagesAsRead extends BuyerChatEvent {
  final String conversationId;
  const MarkMessagesAsRead(this.conversationId);

  @override
  List<Object?> get props => [conversationId];
}

class SendOrderQuickReply extends BuyerChatEvent {
  final String conversationId;
  final String text;
  const SendOrderQuickReply(this.conversationId, this.text);

  @override
  List<Object?> get props => [conversationId, text];
}

class SetBuyerChatFilter extends BuyerChatEvent {
  final String filter; // 'all' | 'seller' | 'delivery'
  const SetBuyerChatFilter(this.filter);

  @override
  List<Object?> get props => [filter];
}
