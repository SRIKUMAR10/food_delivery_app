abstract class ChatSupportEvent {}

class LoadChatSessionsEvent extends ChatSupportEvent {
  final String sellerId;
  LoadChatSessionsEvent(this.sellerId);
}

class SelectChatSessionEvent extends ChatSupportEvent {
  final String sessionId;
  SelectChatSessionEvent(this.sessionId);
}

class SendMessageEvent extends ChatSupportEvent {
  final String sessionId;
  final String text;
  SendMessageEvent(this.sessionId, this.text);
}
