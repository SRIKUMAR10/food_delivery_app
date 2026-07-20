abstract class ChatSupportEvent {}

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
