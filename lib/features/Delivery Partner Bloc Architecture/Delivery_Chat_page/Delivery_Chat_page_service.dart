import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/repositories/i_chat_repository.dart';
import 'Delivery_Chat_page_repository.dart';

abstract class DeliveryChatServiceBase {
  String get currentUserId;
  String get currentUserName;
  Future<void> markMessagesRead(String conversationId, String riderId);
  Future<Map<String, dynamic>?> fetchCustomerDetails(String customerId);
  Future<Map<String, dynamic>?> fetchSellerDetails(String sellerId);
}

class DeliveryChatService implements DeliveryChatServiceBase {
  final IChatRepository chatRepository;
  final DeliveryChatRepositoryBase deliveryChatRepository;
  final FirebaseAuth auth;
  final FirebaseFirestore firestore;

  DeliveryChatService({
    required this.chatRepository,
    required this.deliveryChatRepository,
    FirebaseAuth? auth,
    FirebaseFirestore? firestore,
  })  : auth = auth ?? FirebaseAuth.instance,
        firestore = firestore ?? FirebaseFirestore.instance;

  @override
  String get currentUserId => auth.currentUser?.uid ?? '';

  @override
  String get currentUserName => auth.currentUser?.displayName ?? 'Delivery Partner';

  @override
  Future<Map<String, dynamic>?> fetchCustomerDetails(String customerId) async {
    try {
      if (customerId.isEmpty) return null;
      final doc = await firestore.collection('buyer_user').doc(customerId).get();
      if (doc.exists) {
        return doc.data();
      }
    } catch (_) {}
    return null;
  }

  @override
  Future<Map<String, dynamic>?> fetchSellerDetails(String sellerId) async {
    try {
      if (sellerId.isEmpty) return null;
      final doc = await firestore.collection('sellers').doc(sellerId).get();
      if (doc.exists) {
        return doc.data();
      }
    } catch (_) {}
    return null;
  }

  @override
  Future<void> markMessagesRead(String conversationId, String riderId) async {
    await chatRepository.markMessagesAsRead(
      conversationId: conversationId,
      readerId: riderId,
    );
  }
}
