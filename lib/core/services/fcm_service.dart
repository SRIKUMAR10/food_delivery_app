import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:logger/logger.dart';

// Top-level function for background message handling
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print('Handling a background message: ${message.messageId}');
}

class FCMService {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final Logger _logger = Logger();

  Future<void> initialize({Function(String token)? onTokenRefresh}) async {
    // Request permissions for iOS
    NotificationSettings settings = await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );

    _logger.i('User granted permission: ${settings.authorizationStatus}');

    if (settings.authorizationStatus == AuthorizationStatus.authorized || 
        settings.authorizationStatus == AuthorizationStatus.provisional) {
      
      FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

      // Get the initial token
      try {
        String? token = await _firebaseMessaging.getToken();
        if (token != null) {
          _logger.i('FCM Token generated');
          if (onTokenRefresh != null) onTokenRefresh(token);
        }
      } catch (e) {
        _logger.e('Error getting FCM token: $e');
      }

      // Listen for token refreshes
      _firebaseMessaging.onTokenRefresh.listen((newToken) {
        _logger.i('FCM Token Refreshed');
        if (onTokenRefresh != null) onTokenRefresh(newToken);
      }).onError((err) {
        _logger.e('Error on token refresh: $err');
      });

      // Listen for foreground messages generically
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        _logger.i('Received foreground message: ${message.notification?.title}');
      });
    }
  }
}
