import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:food_delivery_app/core/models/buyer_notification_model.dart';

BuyerNotificationModel _model({
  String id = 'id1',
  BuyerNotificationCategory category = BuyerNotificationCategory.orderUpdate,
  String title = 'English title',
  String? titleTa,
  String body = 'English body',
  String? bodyTa,
  DateTime? createdAt,
  bool isRead = false,
  BuyerNotificationActionType actionType = BuyerNotificationActionType.none,
}) {
  return BuyerNotificationModel(
    id: id,
    userId: 'user_abc',
    category: category,
    title: title,
    titleTa: titleTa,
    body: body,
    bodyTa: bodyTa,
    createdAt: createdAt,
    isRead: isRead,
    actionType: actionType,
  );
}

void main() {
  group('BuyerNotificationModel', () {
    test('fromMap parses all fields and enums', () {
      final now = DateTime.utc(2026, 8, 16, 15, 30);
      final map = <String, dynamic>{
        'userId': 'user_abc',
        'category': 'order_update',
        'subType': 'out_for_delivery',
        'title': 'Out for Delivery!',
        'titleTa': 'டெலிவரிக்கு புறப்பட்டது!',
        'body': 'Your meal is on the way.',
        'bodyTa': 'உணவு வந்துகொண்டிருக்கிறது.',
        'orderId': 'ORD_123',
        'priority': 'high',
        'isRead': false,
        'actionType': 'navigate_track_order',
        'actionPayload': {'orderId': 'ORD_123'},
        'createdAt': Timestamp.fromDate(now),
      };

      final model = BuyerNotificationModel.fromMap('id1', map);

      expect(model.id, 'id1');
      expect(model.userId, 'user_abc');
      expect(model.category, BuyerNotificationCategory.orderUpdate);
      expect(model.subType, 'out_for_delivery');
      expect(model.actionType, BuyerNotificationActionType.navigateTrackOrder);
      expect(model.priority, BuyerNotificationPriority.high);
      expect(model.orderId, 'ORD_123');
      expect(model.isRead, false);
      expect(model.createdAt?.millisecondsSinceEpoch, now.millisecondsSinceEpoch);
      expect(model.actionPayload['orderId'], 'ORD_123');
    });

    test('fromMap defaults gracefully for missing values', () {
      final model = BuyerNotificationModel.fromMap('id2', <String, dynamic>{});
      expect(model.category, BuyerNotificationCategory.unknown);
      expect(model.actionType, BuyerNotificationActionType.none);
      expect(model.priority, BuyerNotificationPriority.medium);
      expect(model.isRead, false);
      expect(model.title, '');
    });

    test('category enum parses known strings and defaults unknown', () {
      expect(
        BuyerNotificationCategory.fromString('offer_promo'),
        BuyerNotificationCategory.offerPromo,
      );
      expect(
        BuyerNotificationCategory.fromString('chat_message'),
        BuyerNotificationCategory.chatMessage,
      );
      expect(
        BuyerNotificationCategory.fromString('gibberish'),
        BuyerNotificationCategory.unknown,
      );
      expect(
        BuyerNotificationCategory.fromString(null),
        BuyerNotificationCategory.unknown,
      );
    });

    test('actionType enum parses known strings and defaults none', () {
      expect(
        BuyerNotificationActionType.fromString('navigate_track_order'),
        BuyerNotificationActionType.navigateTrackOrder,
      );
      expect(
        BuyerNotificationActionType.fromString('apply_coupon'),
        BuyerNotificationActionType.applyCoupon,
      );
      expect(
        BuyerNotificationActionType.fromString('nope'),
        BuyerNotificationActionType.none,
      );
    });

    test('localizedTitle and localizedBody honor Tamil', () {
      final model = _model(
        title: 'English',
        titleTa: 'தமிழ்',
        body: 'Body EN',
        bodyTa: 'Body TA',
      );
      expect(model.localizedTitle('ta'), 'தமிழ்');
      expect(model.localizedTitle('en'), 'English');
      expect(model.localizedBody('ta'), 'Body TA');
      expect(model.localizedBody('en'), 'Body EN');
    });

    test('localizedTitle falls back to English when Tamil missing', () {
      final model = _model(title: 'English', body: 'Body');
      expect(model.localizedTitle('ta'), 'English');
      expect(model.localizedBody('ta'), 'Body');
    });

    test('timeAgo formats relative timestamps', () {
      expect(
        _model(createdAt: DateTime.now().subtract(const Duration(seconds: 10)))
            .timeAgo,
        'Just now',
      );
      expect(
        _model(createdAt: DateTime.now().subtract(const Duration(minutes: 5)))
            .timeAgo,
        '5m ago',
      );
      expect(
        _model(createdAt: DateTime.now().subtract(const Duration(hours: 3)))
            .timeAgo,
        '3h ago',
      );
      expect(
        _model(createdAt: DateTime.now().subtract(const Duration(days: 2)))
            .timeAgo,
        '2d ago',
      );
    });

    test('isUnread and isExpired reflect state', () {
      final unread = _model(isRead: false);
      expect(unread.isUnread, true);
      expect(unread.isExpired, false);

      final expired = _model(
        createdAt: DateTime.now().subtract(const Duration(hours: 1)),
      );
      expect(expired.isExpired, false);
    });

    test('copyWith marks notification as read', () {
      final model = _model(isRead: false);
      final updated = model.copyWith(isRead: true, readAt: DateTime.now());
      expect(updated.isRead, true);
      expect(model.isRead, false);
    });

    test('toMap round-trips through fromMap', () {
      final model = _model(
        id: 'x',
        title: 'Title',
        titleTa: 'தலைப்பு',
        isRead: false,
      );
      final roundTripped = BuyerNotificationModel.fromMap('x', model.toMap());
      expect(roundTripped.title, 'Title');
      expect(roundTripped.titleTa, 'தலைப்பு');
      expect(roundTripped.category, model.category);
    });
  });
}
