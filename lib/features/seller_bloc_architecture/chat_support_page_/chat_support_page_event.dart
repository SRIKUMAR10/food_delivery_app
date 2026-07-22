import '../../../core/models/chat_message_model.dart';

abstract class ChatSupportEvent {}

class DeleteSupportMessageEvent extends ChatSupportEvent {
  final ChatMessageModel message;
  final bool forEveryone;
  DeleteSupportMessageEvent(this.message, {required this.forEveryone});
}

class LoadChatSessionsEvent extends ChatSupportEvent {
  final String sellerId;
  LoadChatSessionsEvent(this.sellerId);
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
