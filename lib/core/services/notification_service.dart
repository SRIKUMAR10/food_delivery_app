import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:logger/logger.dart';

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  debugPrint('Handling a background message: ${message.messageId}');
}

class NotificationService {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final Logger _logger = Logger();

  static final NotificationService _instance = NotificationService._internal();

  factory NotificationService() {
    return _instance;
  }

  NotificationService._internal();

  Future<void> initialize() async {
    // Request permission for iOS and web
    NotificationSettings settings = await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      _logger.i('User granted permission for notifications');
      await _setupFCMToken();
    } else {
      _logger.w('User declined or has not accepted permission');
    }

    // Register background message handler
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

    // Handle token refresh
    _firebaseMessaging.onTokenRefresh.listen((newToken) {
      _saveTokenToDatabase(newToken);
    });

    // Handle foreground messages (optional visual handling can be added later)
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      _logger.i('Received a foreground message: ${message.messageId}');
      // Here you could use flutter_local_notifications to show a heads-up display
    });
  }

  Future<void> _setupFCMToken() async {
    try {
      String? token = await _firebaseMessaging.getToken();
      if (token != null) {
        await _saveTokenToDatabase(token);
      }
    } catch (e) {
      _logger.e('Error getting FCM token: $e');
    }
  }

  Future<void> _saveTokenToDatabase(String token) async {
    final User? user = _auth.currentUser;
    if (user != null) {
      final uid = user.uid;
      final tokenData = {
        'fcmToken': token,
        'updatedAt': FieldValue.serverTimestamp(),
      };
      try {
        await Future.wait([
          _firestore.collection('buyer_user').doc(uid).set(tokenData, SetOptions(merge: true)),
          _firestore.collection('sellers').doc(uid).set(tokenData, SetOptions(merge: true)),
          _firestore.collection('delivery_partners').doc(uid).set(tokenData, SetOptions(merge: true)),
        ]);
        _logger.i('FCM token saved successfully for user $uid');
      } catch (e) {
        _logger.e('Failed to save FCM token: $e');
      }
    } else {
      _logger.w('Cannot save FCM token: User is not logged in.');
    }
  }

  Future<void> sendChatNotification({
    required String targetUserId,
    required String senderName,
    required String messageText,
    required String conversationId,
    required String targetRole,
  }) async {
    if (targetUserId.isEmpty) return;

    final notificationData = {
      'type': 'chat',
      'title': senderName,
      'body': messageText,
      'conversationId': conversationId,
      'createdAt': FieldValue.serverTimestamp(),
      'isRead': false,
    };

    final collections = _collectionsForRole(targetRole);
    for (final collection in collections) {
      try {
        await _firestore
            .collection(collection)
            .doc(targetUserId)
            .collection('notifications')
            .add(notificationData);
      } catch (_) {}
    }
  }

  List<String> _collectionsForRole(String targetRole) {
    switch (targetRole) {
      case 'buyer':
        return const ['buyer_user'];
      case 'seller':
        return const ['sellers'];
      case 'delivery_partner':
        return const ['delivery_partners'];
      default:
        return const ['buyer_user', 'sellers', 'delivery_partners'];
    }
  }

  Future<void> sendOrderStatusNotification({
    required String targetUserId,
    required String orderId,
    required String status,
    required String title,
    required String body,
  }) async {
    if (targetUserId.isEmpty) return;
    final notificationData = {
      'orderId': orderId,
      'status': status,
      'title': title,
      'body': body,
      'createdAt': FieldValue.serverTimestamp(),
      'isRead': false,
    };

    try {
      await _firestore
          .collection('buyer_user')
          .doc(targetUserId)
          .collection('notifications')
          .add(notificationData);
    } catch (_) {}

    try {
      await _firestore
          .collection('sellers')
          .doc(targetUserId)
          .collection('notifications')
          .add(notificationData);
    } catch (_) {}

    try {
      await _firestore
          .collection('delivery_partners')
          .doc(targetUserId)
          .collection('notifications')
          .add(notificationData);
    } catch (_) {}
  }
}
