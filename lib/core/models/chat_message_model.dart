import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class ChatMessageModel extends Equatable {
  final String id;
  final String conversationId;
  final String text;
  final String senderId;
  final String senderRole;
  final DateTime timestamp;
  final bool isRead;
  final String messageType;

  const ChatMessageModel({
    required this.id,
    required this.conversationId,
    required this.text,
    required this.senderId,
    required this.senderRole,
    required this.timestamp,
    this.isRead = false,
    this.messageType = 'text',
  });

  factory ChatMessageModel.fromMap(
    Map<String, dynamic> map,
    String documentId, {
    String? conversationId,
  }) {
    return ChatMessageModel(
      id: documentId,
      conversationId: conversationId ?? map['conversationId'] as String? ?? '',
      text: map['text'] as String? ?? '',
      senderId: map['senderId'] as String? ?? '',
      senderRole: map['senderRole'] as String? ?? '',
      timestamp: (map['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
      isRead: map['isRead'] as bool? ?? false,
      messageType: map['messageType'] as String? ?? 'text',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'conversationId': conversationId,
      'text': text,
      'senderId': senderId,
      'senderRole': senderRole,
      'timestamp': Timestamp.fromDate(timestamp),
      'isRead': isRead,
      'messageType': messageType,
    };
  }

  ChatMessageModel copyWith({
    String? id,
    String? conversationId,
    String? text,
    String? senderId,
    String? senderRole,
    DateTime? timestamp,
    bool? isRead,
    String? messageType,
  }) {
    return ChatMessageModel(
      id: id ?? this.id,
      conversationId: conversationId ?? this.conversationId,
      text: text ?? this.text,
      senderId: senderId ?? this.senderId,
      senderRole: senderRole ?? this.senderRole,
      timestamp: timestamp ?? this.timestamp,
      isRead: isRead ?? this.isRead,
      messageType: messageType ?? this.messageType,
    );
  }

  @override
  List<Object?> get props => [
    id,
    conversationId,
    text,
    senderId,
    senderRole,
    timestamp,
    isRead,
    messageType,
  ];
}
