import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart';

import '../../../core/models/buyer_notification_model.dart';
import '../../../core/services/audio_notification_service.dart';

/// Coordinates the pieces that make a notification "feel" real-time:
///
///  * FCM foreground message mapping (best-effort across platforms),
///  * audio chime playback, and
///  * a helper to build a [BuyerNotificationModel] from a [RemoteMessage].
class BuyerNotificationService {
  final AudioNotificationService? audioService;

  BuyerNotificationService({this.audioService});

  AudioNotificationService get _audio =>
      audioService ?? AudioNotificationService();

  /// Stream of FCM messages received while the app is in the foreground.
  Stream<BuyerNotificationModel> get foregroundNotifications {
    return FirebaseMessaging.onMessage.map(fromRemoteMessage);
  }

  /// Maps an FCM [RemoteMessage] into a [BuyerNotificationModel].
  BuyerNotificationModel fromRemoteMessage(RemoteMessage message) {
    final data = message.data;
    final notification = message.notification;
    final now = DateTime.now();
    return BuyerNotificationModel(
      id: message.messageId ?? 'fcm_${now.microsecondsSinceEpoch}',
      userId: data['userId'] ?? '',
      category: BuyerNotificationCategory.fromString(data['category']),
      subType: data['subType'],
      title: notification?.title ?? data['title'] ?? '',
      titleTa: data['titleTa'],
      body: notification?.body ?? data['body'] ?? '',
      bodyTa: data['bodyTa'],
      orderId: data['orderId'],
      conversationId: data['conversationId'],
      couponCode: data['couponCode'],
      productId: data['productId'],
      imageUrl: data['imageUrl'],
      iconType: data['iconType'],
      priority: BuyerNotificationPriority.fromString(data['priority']),
      actionType: BuyerNotificationActionType.fromString(data['actionType']),
      actionPayload: data['actionPayload'] is Map
          ? Map<String, dynamic>.from(data['actionPayload'] as Map)
          : <String, dynamic>{},
      createdAt: now,
    );
  }

  /// Plays the pleasant notification chime (no-op in test environments).
  void playChime() {
    _audio.playNewOrderSound();
  }

  void dispose() {
    _audio.dispose();
  }
}
