import 'chat_support_page_model.dart';

abstract class ChatSupportState {}

class ChatSupportInitial extends ChatSupportState {}

class ChatSupportLoading extends ChatSupportState {}

class ChatSupportLoaded extends ChatSupportState {
  final List<ChatSessionModel> activeSessions;
  final String? selectedSessionId;
  final bool isSendingMessage;
  final String? errorMessage;

  ChatSupportLoaded({
    required this.activeSessions,
    this.selectedSessionId,
    this.isSendingMessage = false,
    this.errorMessage,
  });

  ChatSessionModel? get selectedSession {
    if (selectedSessionId == null) return null;
    try {
      return activeSessions.firstWhere((s) => s.sessionId == selectedSessionId);
    } catch (e) {
      return null;
    }
  }

  ChatSupportLoaded copyWith({
    List<ChatSessionModel>? activeSessions,
    String? selectedSessionId,
    bool? isSendingMessage,
    String? errorMessage,
    bool clearError = false,
  }) {
    return ChatSupportLoaded(
      activeSessions: activeSessions ?? this.activeSessions,
      selectedSessionId: selectedSessionId ?? this.selectedSessionId,
      isSendingMessage: isSendingMessage ?? this.isSendingMessage,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

class ChatSupportError extends ChatSupportState {
  final String message;
  ChatSupportError(this.message);
}
