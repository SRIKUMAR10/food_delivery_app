import 'package:flutter_test/flutter_test.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:food_delivery_app/core/models/chat_message_model.dart';

void main() {
  group('ChatMessageModel', () {
    const testId = 'msg_1';
    const testConversationId = 'conv_1';
    const testText = 'Hello';
    const testSenderId = 'user_1';
    const testSenderRole = 'buyer';
    final testTimestamp = DateTime(2026, 7, 20, 10, 30);

    test('constructor sets all fields correctly', () {
      final model = ChatMessageModel(
        id: testId,
        conversationId: testConversationId,
        text: testText,
        senderId: testSenderId,
        senderRole: testSenderRole,
        timestamp: testTimestamp,
      );

      expect(model.id, testId);
      expect(model.conversationId, testConversationId);
      expect(model.text, testText);
      expect(model.senderId, testSenderId);
      expect(model.senderRole, testSenderRole);
      expect(model.timestamp, testTimestamp);
      expect(model.isRead, false);
      expect(model.messageType, 'text');
    });

    test('fromMap parses Firestore map correctly', () {
      final map = {
        'conversationId': testConversationId,
        'text': testText,
        'senderId': testSenderId,
        'senderRole': testSenderRole,
        'timestamp': Timestamp.fromDate(testTimestamp),
        'isRead': true,
        'messageType': 'text',
      };

      final model = ChatMessageModel.fromMap(map, testId);

      expect(model.id, testId);
      expect(model.conversationId, testConversationId);
      expect(model.text, testText);
      expect(model.senderId, testSenderId);
      expect(model.senderRole, testSenderRole);
      expect(model.timestamp, testTimestamp);
      expect(model.isRead, true);
      expect(model.messageType, 'text');
    });

    test('fromMap uses conversationId parameter over map value', () {
      final map = {
        'conversationId': 'wrong_conv',
        'text': testText,
        'senderId': testSenderId,
        'senderRole': testSenderRole,
        'timestamp': Timestamp.fromDate(testTimestamp),
        'isRead': false,
        'messageType': 'text',
      };

      final model = ChatMessageModel.fromMap(map, testId, conversationId: testConversationId);
      expect(model.conversationId, testConversationId);
    });

    test('fromMap uses map conversationId when parameter not provided', () {
      final map = {
        'conversationId': testConversationId,
        'text': testText,
        'senderId': testSenderId,
        'senderRole': testSenderRole,
        'timestamp': Timestamp.fromDate(testTimestamp),
        'isRead': false,
        'messageType': 'text',
      };

      final model = ChatMessageModel.fromMap(map, testId);
      expect(model.conversationId, testConversationId);
    });

    test('fromMap handles null values with defaults', () {
      final map = <String, dynamic>{};
      final model = ChatMessageModel.fromMap(map, testId);

      expect(model.id, testId);
      expect(model.text, '');
      expect(model.senderId, '');
      expect(model.senderRole, '');
      expect(model.isRead, false);
      expect(model.messageType, 'text');
    });

    test('toMap produces correct map', () {
      final model = ChatMessageModel(
        id: testId,
        conversationId: testConversationId,
        text: testText,
        senderId: testSenderId,
        senderRole: testSenderRole,
        timestamp: testTimestamp,
        isRead: true,
      );

      final map = model.toMap();

      expect(map['conversationId'], testConversationId);
      expect(map['text'], testText);
      expect(map['senderId'], testSenderId);
      expect(map['senderRole'], testSenderRole);
      expect(map['isRead'], true);
      expect(map['messageType'], 'text');
      expect(map['timestamp'], isA<Timestamp>());
      expect((map['timestamp'] as Timestamp).toDate(), testTimestamp);
    });

    test('copyWith updates only specified fields', () {
      final model = ChatMessageModel(
        id: testId,
        conversationId: testConversationId,
        text: testText,
        senderId: testSenderId,
        senderRole: testSenderRole,
        timestamp: testTimestamp,
      );

      final updated = model.copyWith(text: 'Updated', isRead: true);

      expect(updated.id, testId);
      expect(updated.text, 'Updated');
      expect(updated.isRead, true);
      expect(updated.conversationId, testConversationId);
      expect(updated.senderId, testSenderId);
    });

    test('copyWith with no arguments returns equal object', () {
      final model = ChatMessageModel(
        id: testId,
        conversationId: testConversationId,
        text: testText,
        senderId: testSenderId,
        senderRole: testSenderRole,
        timestamp: testTimestamp,
      );

      final copied = model.copyWith();
      expect(copied, model);
    });

    test('receiverId and readAt serialize in toMap and fromMap', () {
      final readAt = DateTime(2026, 7, 20, 11, 0);
      final model = ChatMessageModel(
        id: testId,
        conversationId: testConversationId,
        text: testText,
        senderId: testSenderId,
        senderRole: testSenderRole,
        timestamp: testTimestamp,
        receiverId: 'user_2',
        readAt: readAt,
      );

      final map = model.toMap();
      expect(map['receiverId'], 'user_2');
      expect((map['readAt'] as Timestamp).toDate(), readAt);

      final parsed = ChatMessageModel.fromMap(map, testId);
      expect(parsed.receiverId, 'user_2');
      expect(parsed.readAt, readAt);
    });

    test('copyWith preserves receiverId and readAt', () {
      final model = ChatMessageModel(
        id: testId,
        conversationId: testConversationId,
        text: testText,
        senderId: testSenderId,
        senderRole: testSenderRole,
        timestamp: testTimestamp,
      );

      final updated = model.copyWith(receiverId: 'user_2', isRead: true);
      expect(updated.receiverId, 'user_2');
      expect(updated.isRead, true);
    });

    test('Equatable props contain all fields', () {
      final model = ChatMessageModel(
        id: testId,
        conversationId: testConversationId,
        text: testText,
        senderId: testSenderId,
        senderRole: testSenderRole,
        timestamp: testTimestamp,
      );

      expect(model.props, [
        testId,
        testConversationId,
        testText,
        testSenderId,
        testSenderRole,
        testTimestamp,
        false,
        'text',
        null,
        null,
        null,
        null,
        const <String>[],
        false,
        null,
        null,
      ]);
    });

    test('Equatable equality works correctly', () {
      final a = ChatMessageModel(
        id: testId,
        conversationId: testConversationId,
        text: testText,
        senderId: testSenderId,
        senderRole: testSenderRole,
        timestamp: testTimestamp,
      );

      final b = ChatMessageModel(
        id: testId,
        conversationId: testConversationId,
        text: testText,
        senderId: testSenderId,
        senderRole: testSenderRole,
        timestamp: testTimestamp,
      );

      expect(a, b);

      final c = ChatMessageModel(
        id: 'different',
        conversationId: testConversationId,
        text: testText,
        senderId: testSenderId,
        senderRole: testSenderRole,
        timestamp: testTimestamp,
      );

      expect(a, isNot(c));
    });
  });
}
