import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:uuid/uuid.dart';
import 'package:image_picker/image_picker.dart';
import '../core/models/conversation_model.dart';
import '../core/models/chat_message_model.dart';
import '../core/repositories/i_chat_repository.dart';
import 'package:rxdart/rxdart.dart';

class FirebaseChatRepository implements IChatRepository {
  final FirebaseFirestore _firestore;
  final _uuid = const Uuid();

  FirebaseChatRepository({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  static const Map<String, String> _notificationCollections = <String, String>{
    'buyer': 'buyer_user',
    'seller': 'sellers',
    'delivery_partner': 'delivery_partners',
  };

  @override
  Stream<List<ConversationModel>> getConversationsForUser(
    String userId, {
    bool isSeller = false,
    String? role,
  }) {
    if (userId.isEmpty) {
      return Stream.value([]);
    }

    final resolvedRole = role ??
        (isSeller
            ? 'seller'
            : 'buyer');

    if (resolvedRole == 'delivery_partner') {
      return _mergeDeliveryConversations(userId);
    }

    if (resolvedRole == 'seller') {
      // Backward (legacy `sellerId`) and forward (`participants` array)
      // compatible lookup so newly created seller_delivery and multi-party
      // conversations are always surfaced for the seller.
      final bySeller = _firestore
          .collection('conversations')
          .where('sellerId', isEqualTo: userId)
          .snapshots();
      final byParticipants = _firestore
          .collection('conversations')
          .where('participants', arrayContains: userId)
          .snapshots();

      return Rx.combineLatest2(
        bySeller,
        byParticipants,
        (sellerSnap, participantsSnap) {
          final map = <String, ConversationModel>{};
          for (final snap in [sellerSnap, participantsSnap]) {
            for (final doc in snap.docs) {
              map[doc.id] = ConversationModel.fromMap(doc.data(), doc.id);
            }
          }
          final conversations = map.values.toList();
          conversations.sort((a, b) {
            final aTime = a.lastMessageTimestamp ?? a.createdAt;
            final bTime = b.lastMessageTimestamp ?? b.createdAt;
            return bTime.compareTo(aTime);
          });
          return conversations;
        },
      ).onErrorReturn(<ConversationModel>[]);
    }

    final field = resolvedRole == 'seller' ? 'sellerId' : 'buyerId';

    return _firestore
        .collection('conversations')
        .where(field, isEqualTo: userId)
        .snapshots()
        .map(_sortConversations);
  }

  /// Merges legacy `sellerId`-based delivery chats with the new
  /// `deliveryPartnerId` and `participants`-based delivery chats.
  Stream<List<ConversationModel>> _mergeDeliveryConversations(
    String userId,
  ) {
    final legacy = _firestore
        .collection('conversations')
        .where('sellerId', isEqualTo: userId)
        .snapshots();
    final byDeliveryPartner = _firestore
        .collection('conversations')
        .where('deliveryPartnerId', isEqualTo: userId)
        .snapshots();
    final byParticipants = _firestore
        .collection('conversations')
        .where('participants', arrayContains: userId)
        .snapshots();

    return Rx.combineLatest3(
      legacy,
      byDeliveryPartner,
      byParticipants,
      (legacySnap, deliverySnap, participantsSnap) {
        final map = <String, ConversationModel>{};
        for (final snap in [legacySnap, deliverySnap, participantsSnap]) {
          for (final doc in snap.docs) {
            map[doc.id] = ConversationModel.fromMap(doc.data(), doc.id);
          }
        }
        final conversations = map.values.toList();
        conversations.sort((a, b) {
          final aTime = a.lastMessageTimestamp ?? a.createdAt;
          final bTime = b.lastMessageTimestamp ?? b.createdAt;
          return bTime.compareTo(aTime);
        });
        return conversations;
      },
    ).onErrorReturn(<ConversationModel>[]);
  }

  List<ConversationModel> _sortConversations(
    QuerySnapshot<Map<String, dynamic>> snapshot,
  ) {
    final conversations = snapshot.docs
        .map((doc) => ConversationModel.fromMap(doc.data(), doc.id))
        .toList();

    conversations.sort((a, b) {
      final aTime = a.lastMessageTimestamp ?? a.createdAt;
      final bTime = b.lastMessageTimestamp ?? b.createdAt;
      return bTime.compareTo(aTime); // descending
    });

    return conversations;
  }

  @override
  Stream<List<ChatMessageModel>> getMessagesStream(String conversationId) {
    if (conversationId.isEmpty) {
      return Stream.value([]);
    }

    final docRef = _firestore.collection('conversations').doc(conversationId);

    final textStream = docRef.collection('messages').snapshots();
    final photosStream = docRef.collection('photos').snapshots();
    final videosStream = docRef.collection('videos').snapshots();
    final audiosStream = docRef.collection('audios').snapshots();

    return Rx.combineLatest4(
      textStream,
      photosStream,
      videosStream,
      audiosStream,
      (textSnap, photosSnap, videosSnap, audiosSnap) {
        final allDocs = [
          ...textSnap.docs,
          ...photosSnap.docs,
          ...videosSnap.docs,
          ...audiosSnap.docs,
        ];

        final messages = allDocs
            .map(
              (doc) => ChatMessageModel.fromMap(
                doc.data(),
                doc.id,
                conversationId: conversationId,
              ),
            )
            .toList();

        messages.sort((a, b) {
          return a.timestamp.compareTo(b.timestamp);
        });

        return messages;
      },
    ).onErrorReturn(<ChatMessageModel>[]);
  }

  @override
  Future<void> sendMessage({
    required String conversationId,
    required String text,
    required String senderId,
    required String senderRole,
    String? receiverId,
    String? messageType,
    String? mediaUrl,
    String? fileName,
    int? fileSize,
    int? duration,
  }) async {
    final messageId = _uuid.v4();
    final timestamp = DateTime.now();

    final conversationRef = _firestore
        .collection('conversations')
        .doc(conversationId);
    final conversationDoc = await conversationRef.get();
    final conversation = conversationDoc.exists
        ? ConversationModel.fromMap(conversationDoc.data()!, conversationId)
        : null;

    // Resolve the recipient for read receipts and unread counters.
    String? resolvedReceiverId = receiverId;
    String resolvedReceiverRole = _otherRole(senderRole, conversation);

    if (resolvedReceiverId == null || resolvedReceiverId.isEmpty) {
      resolvedReceiverId = _otherParticipantId(conversation, senderRole);
    }

    final unreadField = _unreadFieldForRole(resolvedReceiverRole);

    final batch = _firestore.batch();

    String subCollection = 'messages';
    if (messageType == 'image') {
      subCollection = 'photos';
    } else if (messageType == 'video') {
      subCollection = 'videos';
    } else if (messageType == 'audio') {
      subCollection = 'audios';
    }

    final messageRef = _firestore
        .collection('conversations')
        .doc(conversationId)
        .collection(subCollection)
        .doc(messageId);

    batch.set(messageRef, {
      'conversationId': conversationId,
      'text': text,
      'senderId': senderId,
      'senderRole': senderRole,
      'timestamp': Timestamp.fromDate(timestamp),
      'isRead': false,
      'messageType': messageType ?? 'text',
      if (resolvedReceiverId != null && resolvedReceiverId.isNotEmpty)
        'receiverId': resolvedReceiverId,
      if (mediaUrl != null) 'mediaUrl': mediaUrl,
      if (fileName != null) 'fileName': fileName,
      if (fileSize != null) 'fileSize': fileSize,
      if (duration != null) 'duration': duration,
    });

    String displayLastMessage = text;
    final lowerType = (messageType ?? '').toLowerCase();
    final lowerText = text.toLowerCase();
    if (lowerType == 'pdf' || lowerType == 'document' || lowerType == 'invoice' || lowerText.contains('.pdf') || lowerText.startsWith('invoice_')) {
      displayLastMessage = '📄 Invoice.pdf';
    } else if (lowerType == 'image') {
      displayLastMessage = '📷 Photo';
    } else if (lowerType == 'audio') {
      displayLastMessage = '🎵 Audio message';
    }

    batch.update(conversationRef, {
      'lastMessage': displayLastMessage,
      'lastMessageSenderId': senderId,
      'lastMessageTimestamp': Timestamp.fromDate(timestamp),
      'updatedAt': Timestamp.fromDate(timestamp),
      unreadField: FieldValue.increment(1),
    });

    await batch.commit();

    // Trigger in-app notification for the recipient.
    if (resolvedReceiverId != null && resolvedReceiverId.isNotEmpty) {
      await _writeChatNotification(
        targetUserId: resolvedReceiverId,
        targetRole: resolvedReceiverRole,
        senderName: _senderName(conversation, senderRole, senderId),
        messageText: displayLastMessage,
        conversationId: conversationId,
      );
    }
  }

  String _otherRole(String senderRole, ConversationModel? conversation) {
    final type = conversation?.conversationType ?? 'buyer_seller';
    switch (senderRole) {
      case 'buyer':
        if (type == 'buyer_delivery') return 'delivery_partner';
        if (type == 'seller_delivery') return 'seller';
        return 'seller';
      case 'seller':
        if (type == 'seller_delivery') return 'delivery_partner';
        return 'buyer';
      case 'delivery_partner':
        if (type == 'seller_delivery') return 'seller';
        return 'buyer';
      default:
        return 'buyer';
    }
  }

  String? _otherParticipantId(
    ConversationModel? conversation,
    String senderRole,
  ) {
    if (conversation == null) return null;
    final otherRole = _otherRole(senderRole, conversation);
    switch (otherRole) {
      case 'buyer':
        return conversation.buyerId.isNotEmpty ? conversation.buyerId : null;
      case 'seller':
        return conversation.sellerId.isNotEmpty ? conversation.sellerId : null;
      case 'delivery_partner':
        return conversation.deliveryPartnerId;
      default:
        return null;
    }
  }

  String _unreadFieldForRole(String role) {
    switch (role) {
      case 'buyer':
        return 'buyerUnreadCount';
      case 'seller':
        return 'sellerUnreadCount';
      case 'delivery_partner':
        return 'deliveryUnreadCount';
      default:
        return 'buyerUnreadCount';
    }
  }

  String _senderName(
    ConversationModel? conversation,
    String senderRole,
    String senderId,
  ) {
    if (conversation != null) {
      switch (senderRole) {
        case 'buyer':
          return conversation.buyerName;
        case 'seller':
          return conversation.sellerName;
        case 'delivery_partner':
          return conversation.deliveryPartnerName ?? 'Delivery Partner';
      }
    }
    return senderId;
  }

  Future<void> _writeChatNotification({
    required String targetUserId,
    required String targetRole,
    required String senderName,
    required String messageText,
    required String conversationId,
  }) async {
    final collection = _notificationCollections[targetRole];
    if (collection == null || targetUserId.isEmpty) return;

    try {
      await _firestore
          .collection(collection)
          .doc(targetUserId)
          .collection('notifications')
          .add({
        'type': 'chat',
        'title': senderName,
        'body': messageText,
        'conversationId': conversationId,
        'createdAt': FieldValue.serverTimestamp(),
        'isRead': false,
      });
    } catch (_) {}
  }

  @override
  Future<void> deleteMessage({
    required String conversationId,
    required String messageId,
    required String messageType,
    required bool forEveryone,
    required String userId,
  }) async {
    String subCollection = 'messages';
    if (messageType == 'image') {
      subCollection = 'photos';
    } else if (messageType == 'video') {
      subCollection = 'videos';
    } else if (messageType == 'audio') {
      subCollection = 'audios';
    }

    final messageRef = _firestore
        .collection('conversations')
        .doc(conversationId)
        .collection(subCollection)
        .doc(messageId);

    if (forEveryone) {
      await messageRef.update({
        'isDeletedForEveryone': true,
      });
    } else {
      await messageRef.update({
        'deletedBy': FieldValue.arrayUnion([userId]),
      });
    }
  }

  @override
  Future<String> createConversation({
    required String buyerId,
    required String buyerName,
    required String sellerId,
    required String sellerName,
    String? shopName,
    String? sellerImageUrl,
    String? sellerPhone,
    String? productId,
    String? orderId,
    String? orderImageUrl,
    String? orderTitle,
    double? orderTotal,
    String? initialMessage,
    String? deliveryPartnerId,
    String? deliveryPartnerName,
    String? deliveryPartnerPhone,
    String? deliveryPartnerImageUrl,
    String? conversationType,
    List<String>? participants,
    Map<String, String>? participantRoles,
  }) async {
    final resolvedType = conversationType ?? 'buyer_seller';

    // Only de-duplicate for classic buyer-seller conversations. Delivery
    // conversations are scoped by their own participants/type.
    if (resolvedType == 'buyer_seller') {
      final existing = await getConversationByParticipants(buyerId, sellerId);
      if (existing != null) {
        if (orderId != null && orderId != existing.orderId) {
          final updateData = <String, dynamic>{'orderId': orderId};
          if (orderImageUrl != null) updateData['orderImageUrl'] = orderImageUrl;
          if (orderTitle != null) updateData['orderTitle'] = orderTitle;
          if (orderTotal != null) updateData['orderTotal'] = orderTotal;
          if (sellerPhone != null && sellerPhone.isNotEmpty) updateData['sellerPhone'] = sellerPhone;
          if (shopName != null && shopName.isNotEmpty) updateData['shopName'] = shopName;
          if (sellerImageUrl != null && sellerImageUrl.isNotEmpty) updateData['sellerImageUrl'] = sellerImageUrl;
          await _firestore.collection('conversations').doc(existing.id).update(updateData);

          await sendMessage(
            conversationId: existing.id,
            text: orderId,
            senderId: buyerId,
            senderRole: 'buyer',
            messageType: 'order_card',
          );
        }

        if (initialMessage != null && initialMessage.isNotEmpty) {
          await sendMessage(
            conversationId: existing.id,
            text: initialMessage,
            senderId: buyerId,
            senderRole: 'buyer',
          );
        }
        return existing.id;
      }
    }

    final conversationId = _uuid.v4();
    final now = DateTime.now();

    final resolvedParticipants = participants ??
        <String>[
          if (buyerId.isNotEmpty) buyerId,
          if (sellerId.isNotEmpty) sellerId,
          if (deliveryPartnerId != null && deliveryPartnerId.isNotEmpty)
            deliveryPartnerId,
        ];

    final resolvedRoles = participantRoles ??
        <String, String>{
          if (buyerId.isNotEmpty) buyerId: 'buyer',
          if (sellerId.isNotEmpty) sellerId: 'seller',
          if (deliveryPartnerId != null && deliveryPartnerId.isNotEmpty)
            deliveryPartnerId: 'delivery_partner',
        };

    await _firestore.collection('conversations').doc(conversationId).set({
      'buyerId': buyerId,
      'sellerId': sellerId,
      'buyerName': buyerName,
      'sellerName': sellerName,
      'shopName': shopName,
      'sellerImageUrl': sellerImageUrl,
      'sellerPhone': sellerPhone,
      'productId': productId,
      'orderId': orderId,
      'orderImageUrl': orderImageUrl,
      'orderTitle': orderTitle,
      'orderTotal': orderTotal,
      'lastMessage': initialMessage,
      'lastMessageSenderId': initialMessage != null ? buyerId : null,
      'lastMessageTimestamp': initialMessage != null
          ? Timestamp.fromDate(now)
          : null,
      'buyerUnreadCount': 0,
      'sellerUnreadCount': initialMessage != null ? 1 : 0,
      'deliveryUnreadCount': 0,
      'createdAt': Timestamp.fromDate(now),
      'updatedAt': Timestamp.fromDate(now),
      'deliveryPartnerId': deliveryPartnerId,
      'deliveryPartnerName': deliveryPartnerName,
      'deliveryPartnerPhone': deliveryPartnerPhone,
      'deliveryPartnerImageUrl': deliveryPartnerImageUrl,
      'conversationType': resolvedType,
      'participants': resolvedParticipants,
      'participantRoles': resolvedRoles,
    });

    if (orderId != null) {
      await sendMessage(
        conversationId: conversationId,
        text: orderId,
        senderId: buyerId,
        senderRole: 'buyer',
        messageType: 'order_card',
      );
    }

    if (initialMessage != null && initialMessage.isNotEmpty) {
      await sendMessage(
        conversationId: conversationId,
        text: initialMessage,
        senderId: buyerId,
        senderRole: 'buyer',
      );
    }

    return conversationId;
  }

  @override
  Future<void> updateConversationOrderDetails(
    String conversationId, {
    String? orderImageUrl,
    String? orderTitle,
    double? orderTotal,
  }) async {
    final data = <String, dynamic>{};
    if (orderImageUrl != null) data['orderImageUrl'] = orderImageUrl;
    if (orderTitle != null) data['orderTitle'] = orderTitle;
    if (orderTotal != null) data['orderTotal'] = orderTotal;

    if (data.isNotEmpty) {
      await _firestore
          .collection('conversations')
          .doc(conversationId)
          .update(data);
    }
  }

  @override
  Future<void> markConversationRead(
    String conversationId,
    String userId,
    bool isSeller,
  ) async {
    final field = isSeller ? 'sellerUnreadCount' : 'buyerUnreadCount';

    await _firestore.collection('conversations').doc(conversationId).update({
      field: 0,
    });

    await markMessagesAsRead(conversationId: conversationId, readerId: userId);
  }

  @override
  Future<void> markMessagesAsRead({
    required String conversationId,
    required String readerId,
  }) async {
    if (conversationId.isEmpty || readerId.isEmpty) return;

    final docRef = _firestore.collection('conversations').doc(conversationId);
    final batch = _firestore.batch();

    for (final subCollection in ['messages', 'photos', 'videos', 'audios']) {
      final snapshot = await docRef
          .collection(subCollection)
          .where('isRead', isEqualTo: false)
          .get();

      for (final doc in snapshot.docs) {
        final data = doc.data();
        final senderId = data['senderId'] as String? ?? '';
        if (senderId.isEmpty || senderId == readerId) continue;

        batch.update(doc.reference, {
          'isRead': true,
          'readAt': FieldValue.serverTimestamp(),
          'readBy': FieldValue.arrayUnion([readerId]),
        });
      }
    }

    // Reset unread counters for the reader role based on conversation type.
    final conversationDoc = await docRef.get();
    if (conversationDoc.exists) {
      final conversation =
          ConversationModel.fromMap(conversationDoc.data()!, conversationId);
      final counterField = _unreadFieldForRole(
        _readerRole(readerId, conversation),
      );
      batch.update(docRef, {counterField: 0});
    }

    await batch.commit();
  }

  String _readerRole(String readerId, ConversationModel conversation) {
    if (readerId == conversation.buyerId) return 'buyer';
    if (readerId == conversation.sellerId) return 'seller';
    if (readerId == conversation.deliveryPartnerId) return 'delivery_partner';
    // Fallback: infer from participantRoles map.
    return conversation.participantRoles[readerId] ?? 'buyer';
  }

  @override
  Future<ConversationModel?> getConversationByOrderId(String orderId, {String? userId, bool isSeller = false}) async {
    if (orderId.isEmpty) return null;

    final query = _firestore
        .collection('conversations')
        .where('orderId', isEqualTo: orderId);

    final queryWithUser = userId != null
        ? query.where(isSeller ? 'sellerId' : 'buyerId', isEqualTo: userId)
        : query;

    final snapshot = await queryWithUser.limit(1).get();

    if (snapshot.docs.isNotEmpty) {
      return ConversationModel.fromMap(
        snapshot.docs.first.data(),
        snapshot.docs.first.id,
      );
    }
    return null;
  }

  @override
  Future<String> uploadChatAttachment(
    dynamic file,
    String conversationId,
    String fileName,
  ) async {
    final storageRef = FirebaseStorage.instance
        .ref()
        .child('chat_attachments')
        .child(conversationId)
        .child('${_uuid.v4()}_$fileName');

    String contentType = 'application/octet-stream';
    if (fileName.toLowerCase().endsWith('.m4a')) {
      contentType = 'audio/mp4';
    } else if (fileName.toLowerCase().endsWith('.png')) {
      contentType = 'image/png';
    } else if (fileName.toLowerCase().endsWith('.jpg') || fileName.toLowerCase().endsWith('.jpeg')) {
      contentType = 'image/jpeg';
    } else if (fileName.toLowerCase().endsWith('.webm')) {
      contentType = 'audio/webm';
    } else if (fileName.toLowerCase().endsWith('.wav')) {
      contentType = 'audio/wav';
    } else if (fileName.toLowerCase().endsWith('.pdf')) {
      contentType = 'application/pdf';
    }

    final metadata = SettableMetadata(contentType: contentType);

    if (file is XFile) {
      final bytes = await file.readAsBytes();
      final uploadTask = storageRef.putData(bytes, metadata);
      final snapshot = await uploadTask;
      debugPrint('2. [Firebase Upload] Snapshot Total Bytes: ${snapshot.totalBytes}');
    } else if (file is File) {
      final uploadTask = storageRef.putFile(file, metadata);
      final snapshot = await uploadTask;
      debugPrint('2. [Firebase Upload] Snapshot Total Bytes: ${snapshot.totalBytes}');
      debugPrint('2. [Firebase Upload] Snapshot Bytes Transferred: ${snapshot.bytesTransferred}');
      final finalMetadata = await snapshot.ref.getMetadata();
      debugPrint('2. [Firebase Upload] Uploaded Content-Type: ${finalMetadata.contentType}');
    } else {
      // Assuming file is Uint8List for web
      final uploadTask = storageRef.putData(file, metadata);
      final snapshot = await uploadTask;
      debugPrint('2. [Firebase Upload] Snapshot Total Bytes: ${snapshot.totalBytes}');
      debugPrint('2. [Firebase Upload] Snapshot Bytes Transferred: ${snapshot.bytesTransferred}');
      final finalMetadata = await snapshot.ref.getMetadata();
      debugPrint('2. [Firebase Upload] Uploaded Content-Type: ${finalMetadata.contentType}');
    }

    final downloadUrl = await storageRef.getDownloadURL();
    debugPrint('2. [Firebase Upload] Download URL: $downloadUrl');
    return downloadUrl;
  }

  @override
  Future<ConversationModel?> getConversationByParticipants(
    String buyerId,
    String sellerId,
  ) async {
    if (buyerId.isEmpty || sellerId.isEmpty) return null;

    final snapshot = await _firestore
        .collection('conversations')
        .where('buyerId', isEqualTo: buyerId)
        .where('sellerId', isEqualTo: sellerId)
        .limit(1)
        .get();

    if (snapshot.docs.isEmpty) return null;

    final doc = snapshot.docs.first;
    return ConversationModel.fromMap(doc.data(), doc.id);
  }

  @override
  Future<ConversationModel?> getConversationBetween({
    required String user1Id,
    required String user2Id,
    String? orderId,
    String? type,
  }) async {
    if (user1Id.isEmpty || user2Id.isEmpty) return null;

    // New multi-party schema: participants array.
    final byParticipants = await _firestore
        .collection('conversations')
        .where('participants', arrayContains: user1Id)
        .get();

    for (final doc in byParticipants.docs) {
      final conversation = ConversationModel.fromMap(doc.data(), doc.id);
      if (!conversation.participants.contains(user2Id)) continue;
      if (orderId != null && conversation.orderId != orderId) continue;
      if (type != null && conversation.conversationType != type) continue;
      return conversation;
    }

    // Legacy schema: buyerId + sellerId.
    final legacy1 = await _firestore
        .collection('conversations')
        .where('buyerId', isEqualTo: user1Id)
        .where('sellerId', isEqualTo: user2Id)
        .limit(1)
        .get();
    if (legacy1.docs.isNotEmpty) {
      final doc = legacy1.docs.first;
      return ConversationModel.fromMap(doc.data(), doc.id);
    }

    final legacy2 = await _firestore
        .collection('conversations')
        .where('buyerId', isEqualTo: user2Id)
        .where('sellerId', isEqualTo: user1Id)
        .limit(1)
        .get();
    if (legacy2.docs.isNotEmpty) {
      final doc = legacy2.docs.first;
      return ConversationModel.fromMap(doc.data(), doc.id);
    }

    return null;
  }

  @override
  Future<void> setTypingStatus({
    required String conversationId,
    required String userId,
    required bool isTyping,
  }) async {
    if (conversationId.isEmpty || userId.isEmpty) return;

    final typingRef = _firestore
        .collection('conversations')
        .doc(conversationId)
        .collection('typing')
        .doc(userId);

    if (!isTyping) {
      // Auto-cleanup: remove the document so it no longer counts towards reads.
      await typingRef.delete();
      return;
    }

    await typingRef.set({
      'userId': userId,
      'isTyping': true,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  @override
  Stream<Map<String, bool>> getTypingStatusStream(String conversationId) {
    if (conversationId.isEmpty) {
      return Stream.value(const <String, bool>{});
    }

    const staleWindow = Duration(seconds: 5);

    return _firestore
        .collection('conversations')
        .doc(conversationId)
        .collection('typing')
        .snapshots()
        .map((snapshot) {
          final now = DateTime.now();
          final result = <String, bool>{};
          for (final doc in snapshot.docs) {
            final data = doc.data();
            final isTyping = data['isTyping'] as bool? ?? false;
            final rawTimestamp = data['timestamp'];
            DateTime? timestamp;
            if (rawTimestamp is Timestamp) timestamp = rawTimestamp.toDate();
            final isStale = timestamp != null &&
                now.difference(timestamp) > staleWindow;
            // A null timestamp means the server value has not resolved yet;
            // treat it as still typing.
            result[doc.id] = isTyping && !isStale;
          }
          return result;
        })
        .onErrorReturn(const <String, bool>{});
  }
}
