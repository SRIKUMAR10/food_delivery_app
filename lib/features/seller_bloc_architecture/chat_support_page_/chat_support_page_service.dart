// DEPRECATED: Replaced by repositories/firebase_chat_repository.dart (uses conversations collection).
// Kept as rollback backup until Phase 4 migration is fully verified.
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import 'chat_support_page_model.dart';

class ChatSupportService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final _uuid = const Uuid();

  Future<List<ChatSessionModel>> fetchChatSessions(String sellerId) async {
    try {
      final snapshot = await _firestore
          .collection('sellers')
          .doc(sellerId)
          .collection('chats')
          .get();

      List<ChatSessionModel> sessions = [];

      for (var doc in snapshot.docs) {
        final data = doc.data();
        
        // Fetch recent messages for this chat session
        final messagesSnapshot = await _firestore
            .collection('sellers')
            .doc(sellerId)
            .collection('chats')
            .doc(doc.id)
            .collection('messages')
            .orderBy('timestamp', descending: false)
            .get();

        final messages = messagesSnapshot.docs.map((mDoc) {
          final mData = mDoc.data();
          return ChatMessageModel(
            id: mDoc.id,
            text: mData['text'] ?? '',
            senderId: mData['senderId'] ?? '',
            timestamp: (mData['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
            isRead: mData['isRead'] ?? false,
          );
        }).toList();

        sessions.add(ChatSessionModel(
          sessionId: doc.id,
          customerName: data['customerName'] ?? 'Unknown',
          orderId: data['orderId'] ?? '',
          unreadCount: data['unreadCount'] ?? 0,
          messages: messages,
        ));
      }

      return sessions;
    } catch (e) {
      throw Exception('Failed to fetch chat sessions: $e');
    }
  }

  Future<ChatMessageModel> sendMessage(String sellerId, String sessionId, String text) async {
    try {
      final messageId = _uuid.v4();
      final newMessage = ChatMessageModel(
        id: messageId,
        text: text,
        senderId: 'seller', // Can be specific sellerId
        timestamp: DateTime.now(),
        isRead: false,
      );

      await _firestore
          .collection('sellers')
          .doc(sellerId)
          .collection('chats')
          .doc(sessionId)
          .collection('messages')
          .doc(messageId)
          .set({
        'text': newMessage.text,
        'senderId': newMessage.senderId,
        'timestamp': Timestamp.fromDate(newMessage.timestamp),
        'isRead': newMessage.isRead,
      });

      return newMessage;
    } catch (e) {
      throw Exception('Failed to send message: $e');
    }
  }
}
