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

  @override
  Stream<List<ConversationModel>> getConversationsForUser(
    String userId, {
    required bool isSeller,
  }) {
    if (userId.isEmpty) {
      return Stream.value([]);
    }

    final field = isSeller ? 'sellerId' : 'buyerId';

    return _firestore
        .collection('conversations')
        .where(field, isEqualTo: userId)
        .snapshots()
        .map((snapshot) {
          final conversations = snapshot.docs
              .map((doc) => ConversationModel.fromMap(doc.data(), doc.id))
              .toList();
          
          conversations.sort((a, b) {
            final aTime = a.lastMessageTimestamp ?? a.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
            final bTime = b.lastMessageTimestamp ?? b.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
            return bTime.compareTo(aTime); // descending
          });
          
          return conversations;
        });
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
    String? messageType,
    String? mediaUrl,
    String? fileName,
    int? fileSize,
    int? duration,
  }) async {
    final messageId = _uuid.v4();
    final timestamp = DateTime.now();

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
      if (mediaUrl != null) 'mediaUrl': mediaUrl,
      if (fileName != null) 'fileName': fileName,
      if (fileSize != null) 'fileSize': fileSize,
      if (duration != null) 'duration': duration,
    });

    final conversationRef = _firestore
        .collection('conversations')
        .doc(conversationId);

    final unreadField = senderRole == 'buyer'
        ? 'sellerUnreadCount'
        : 'buyerUnreadCount';

    batch.update(conversationRef, {
      'lastMessage': text,
      'lastMessageSenderId': senderId,
      'lastMessageTimestamp': Timestamp.fromDate(timestamp),
      'updatedAt': Timestamp.fromDate(timestamp),
      unreadField: FieldValue.increment(1),
    });

    await batch.commit();
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
    String? productId,
    String? orderId,
    String? orderImageUrl,
    String? orderTitle,
    double? orderTotal,
    String? initialMessage,
  }) async {
    final existing = await getConversationByParticipants(buyerId, sellerId);
    if (existing != null) {
      if (orderId != null && orderId != existing.orderId) {
        final updateData = <String, dynamic>{'orderId': orderId};
        if (orderImageUrl != null) updateData['orderImageUrl'] = orderImageUrl;
        if (orderTitle != null) updateData['orderTitle'] = orderTitle;
        if (orderTotal != null) updateData['orderTotal'] = orderTotal;
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

    final conversationId = _uuid.v4();
    final now = DateTime.now();

    await _firestore.collection('conversations').doc(conversationId).set({
      'buyerId': buyerId,
      'sellerId': sellerId,
      'buyerName': buyerName,
      'sellerName': sellerName,
      'shopName': shopName,
      'sellerImageUrl': sellerImageUrl,
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
      'createdAt': Timestamp.fromDate(now),
      'updatedAt': Timestamp.fromDate(now),
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
}
