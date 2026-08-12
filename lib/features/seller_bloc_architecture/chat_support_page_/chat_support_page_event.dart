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

