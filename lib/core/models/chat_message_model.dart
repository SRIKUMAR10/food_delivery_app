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
  final String messageType; // text, image, audio, document
  final String? mediaUrl;
  final String? fileName;
  final int? fileSize;
  final int? duration; // for audio

  const ChatMessageModel({
    required this.id,
    required this.conversationId,
    required this.text,
    required this.senderId,
    required this.senderRole,
    required this.timestamp,
    this.isRead = false,
    this.messageType = 'text',
    this.mediaUrl,
    this.fileName,
    this.fileSize,
    this.duration,
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
      mediaUrl: map['mediaUrl'] as String?,
      fileName: map['fileName'] as String?,
      fileSize: map['fileSize'] as int?,
      duration: map['duration'] as int?,
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
      'mediaUrl': mediaUrl,
      'fileName': fileName,
      'fileSize': fileSize,
      'duration': duration,
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
    String? mediaUrl,
    String? fileName,
    int? fileSize,
    int? duration,
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
      mediaUrl: mediaUrl ?? this.mediaUrl,
      fileName: fileName ?? this.fileName,
      fileSize: fileSize ?? this.fileSize,
      duration: duration ?? this.duration,
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
    mediaUrl,
    fileName,
    fileSize,
    duration,
  ];
}
