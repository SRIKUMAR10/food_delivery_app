import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../core/repositories/i_chat_repository.dart';
import '../../../core/models/conversation_model.dart';

abstract class DeliveryChatRepositoryBase {
  Stream<List<ConversationModel>> getDeliveryConversations(String riderId);
  Future<ConversationModel?> getConversationByOrderId(String orderId, String riderId);
  Future<String> createOrGetConversation({
    required String orderId,
    required String customerId,
    required String customerName,
    required String riderId,
    required String riderName,
    String? orderTitle,
    double? orderTotal,
  });
}

class DeliveryChatRepository implements DeliveryChatRepositoryBase {
  final IChatRepository chatRepository;
  final FirebaseFirestore firestore;
  final FirebaseAuth auth;

  DeliveryChatRepository({
    required this.chatRepository,
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  })  : firestore = firestore ?? FirebaseFirestore.instance,
        auth = auth ?? FirebaseAuth.instance;

  @override
  Stream<List<ConversationModel>> getDeliveryConversations(String riderId) {
    if (riderId.isEmpty) return Stream.value([]);

    return firestore
        .collection('conversations')
        .where('sellerId', isEqualTo: riderId)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => ConversationModel.fromMap(doc.data(), doc.id))
          .toList()
        ..sort((a, b) {
          final aTime = a.lastMessageTimestamp ?? a.createdAt;
          final bTime = b.lastMessageTimestamp ?? b.createdAt;
          return bTime.compareTo(aTime);
        });
    });
  }

  @override
  Future<ConversationModel?> getConversationByOrderId(
      String orderId, String riderId) async {
    return chatRepository.getConversationByOrderId(
      orderId,
      userId: riderId,
      isSeller: true,
    );
  }

  @override
  Future<String> createOrGetConversation({
    required String orderId,
    required String customerId,
    required String customerName,
    required String riderId,
    required String riderName,
    String? orderTitle,
    double? orderTotal,
  }) async {
    final existing = await chatRepository.getConversationByParticipants(
      customerId,
      riderId,
    );

    if (existing != null) {
      if (orderId != existing.orderId && orderId.isNotEmpty) {
        await firestore.collection('conversations').doc(existing.id).update({
          'orderId': orderId,
          if (orderTitle != null) 'orderTitle': orderTitle,
          if (orderTotal != null) 'orderTotal': orderTotal,
        });
      }
      return existing.id;
    }

    return chatRepository.createConversation(
      buyerId: customerId,
      buyerName: customerName,
      sellerId: riderId,
      sellerName: riderName,
      orderId: orderId,
      orderTitle: orderTitle,
      orderTotal: orderTotal,
    );
  }
}
