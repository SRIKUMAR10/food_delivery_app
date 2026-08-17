import 'dart:async';
import '../models/seller_notification_model.dart';

/// Abstract contract for real-time seller notification persistence and live streams.
abstract class ISellerNotificationRepository {
  /// Stream that emits the live list of notifications for a seller,
  /// ordered newest to oldest and excluding summary/metadata documents.
  Stream<List<SellerNotificationModel>> watchNotifications(String sellerId);

  /// Real-time stream of the number of unread notifications for a seller.
  Stream<int> watchUnreadCount(String sellerId);

  /// Marks a specific notification as read.
  Future<void> markAsRead(String sellerId, String notificationId);

  /// Marks all unread notifications as read in a single batch.
  Future<void> markAllAsRead(String sellerId);

  /// Deletes a specific notification from Firestore.
  Future<void> deleteNotification(String sellerId, String notificationId);

  /// Restores a previously deleted notification (e.g. on Undo).
  Future<void> restoreNotification(
      String sellerId, SellerNotificationModel notification);

  /// Permanently removes all notifications for this seller.
  Future<void> clearAllNotifications(String sellerId);

  /// Creates a new notification document in Firestore.
  Future<String> createNotification(
      String sellerId, SellerNotificationModel notification);
}
