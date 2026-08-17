import '../models/buyer_notification_model.dart';

/// Contract for reading and mutating a buyer's notification feed located at
/// `buyer_user/{uid}/notifications/{notificationId}`.
abstract interface class IBuyerNotificationRepository {
  /// Real-time stream of notifications ordered by most recent first.
  Stream<List<BuyerNotificationModel>> watchNotifications(String userId);

  /// Real-time unread count derived from the notification stream.
  Stream<int> watchUnreadCount(String userId);

  /// Marks a single notification as read.
  Future<void> markAsRead(String userId, String notificationId);

  /// Marks every unread notification as read.
  Future<void> markAllAsRead(String userId);

  /// Deletes a single notification.
  Future<void> deleteNotification(String userId, String notificationId);

  /// Re-inserts a previously deleted notification (used by the Undo action).
  Future<void> restoreNotification(
      String userId, BuyerNotificationModel notification);

  /// Deletes every notification for the buyer.
  Future<void> clearAllNotifications(String userId);
}
