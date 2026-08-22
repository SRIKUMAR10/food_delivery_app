import 'dart:async';
import 'package:firebase_messaging/firebase_messaging.dart';
import '../../../core/models/seller_notification_model.dart';
import '../../../core/services/audio_notification_service.dart';

/// Coordinates real-time notifications for the seller app:
/// - Foreground FCM message mapping
/// - Audio chime playback for live alerts
/// - Parsing remote push payloads into [SellerNotificationModel]
class SellerNotificationService {
  final AudioNotificationService? audioService;

  SellerNotificationService({this.audioService});

  AudioNotificationService get _audio =>
      audioService ?? AudioNotificationService();

  /// Stream of FCM messages received while the app is active in foreground.
  Stream<SellerNotificationModel> get foregroundNotifications {
    return FirebaseMessaging.onMessage.map(fromRemoteMessage);
  }

  /// Maps an FCM [RemoteMessage] to a strongly-typed [SellerNotificationModel].
  SellerNotificationModel fromRemoteMessage(RemoteMessage message) {
    final data = message.data;
    final notification = message.notification;
    final now = DateTime.now();

    return SellerNotificationModel(
      id: message.messageId ?? 'fcm_${now.microsecondsSinceEpoch}',
      sellerId: (data['sellerId'] ?? data['userId'] ?? '').toString(),
      category: SellerNotificationCategory.fromString(
        data['category']?.toString() ?? data['type']?.toString(),
      ),
      subType: data['subType']?.toString(),
      title: notification?.title ?? data['title']?.toString() ?? '',
      titleTa: data['titleTa']?.toString(),
      body: notification?.body ?? data['body']?.toString() ?? '',
      bodyTa: data['bodyTa']?.toString(),
      orderId: data['orderId']?.toString(),
      productId: data['productId']?.toString(),
      productName: data['productName']?.toString(),
      customerName: data['customerName']?.toString(),
      deliveryPartnerName:
          (data['deliveryPartnerName'] ?? data['riderName'])?.toString(),
      conversationId: data['conversationId']?.toString(),
      payoutId: data['payoutId']?.toString(),
      amount: data['amount'] != null ? double.tryParse(data['amount'].toString()) : null,
      stockQuantity: data['stockQuantity'] != null
          ? int.tryParse(data['stockQuantity'].toString())
          : null,
      rating: data['rating'] != null ? double.tryParse(data['rating'].toString()) : null,
      reviewComment: data['reviewComment']?.toString(),
      imageUrl: data['imageUrl']?.toString(),
      iconType: data['iconType']?.toString(),
      priority:
          SellerNotificationPriority.fromString(data['priority']?.toString()),
      actionType: SellerNotificationActionType.fromString(
        data['actionType']?.toString() ?? data['clickAction']?.toString(),
      ),
      actionPayload: data['actionPayload'] is Map
          ? Map<String, dynamic>.from(data['actionPayload'] as Map)
          : <String, dynamic>{},
      createdAt: now,
    );
  }

  /// Plays a notification sound chime (safe across Web, Android, iOS, Windows, macOS, Linux).
  void playChime({
    String ringtoneName = AudioNotificationService.defaultRingtone,
    double volume = 0.8,
    bool loop = false,
  }) {
    _audio.playNewOrderSound(
      ringtoneName: ringtoneName,
      volume: volume,
      loop: loop,
    );
  }

  /// Halts active audio playback.
  void stopAudio() {
    _audio.stop();
  }

  void dispose() {
    _audio.dispose();
  }
}
