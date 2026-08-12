// Real-Time Firestore Stream Provider Standardized
// DEPRECATED: Replaced by core/repositories/i_chat_repository.dart and repositories/firebase_chat_repository.dart.
// Kept as rollback backup until Phase 4 migration is fully verified.
import 'chat_support_page_model.dart';
import 'chat_support_page_service.dart';

class ChatSupportRepository {
  final ChatSupportService service;

  ChatSupportRepository({required this.service});

  Stream<List<ChatSessionModel>> streamActiveSessions(String sellerId) {
    return service.streamChatSessions(sellerId);
  }

  Future<List<ChatSessionModel>> getActiveSessions(String sellerId) {
    return service.fetchChatSessions(sellerId);
  }

  Future<ChatMessageModel> sendMessage(String sellerId, String sessionId, String text) {
    return service.sendMessage(sellerId, sessionId, text);
  }
}
