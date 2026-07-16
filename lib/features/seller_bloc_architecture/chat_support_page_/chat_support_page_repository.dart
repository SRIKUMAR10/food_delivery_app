import 'chat_support_page_model.dart';
import 'chat_support_page_service.dart';

class ChatSupportRepository {
  final ChatSupportService service;

  ChatSupportRepository({required this.service});

  Future<List<ChatSessionModel>> getActiveSessions(String sellerId) {
    return service.fetchChatSessions(sellerId);
  }

  Future<ChatMessageModel> sendMessage(String sellerId, String sessionId, String text) {
    return service.sendMessage(sellerId, sessionId, text);
  }
}
