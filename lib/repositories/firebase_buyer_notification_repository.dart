import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';

import '../core/models/buyer_notification_model.dart';
import '../core/repositories/i_buyer_notification_repository.dart';

/// Firestore implementation of [IBuyerNotificationRepository].
///
/// Notifications live in `buyer_user/{userId}/notifications` and the reserved
/// document `summary` (if present) is excluded from the feed because it stores
/// aggregate counters rather than a notification payload.
class FirebaseBuyerNotificationRepository
    implements IBuyerNotificationRepository {
  final FirebaseFirestore firestore;

  FirebaseBuyerNotificationRepository({FirebaseFirestore? firestore})
      : firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> _collection(String userId) =>
      firestore
          .collection('buyer_user')
          .doc(userId)
          .collection('notifications');

  @override
  Stream<List<BuyerNotificationModel>> watchNotifications(String userId) {
    return _collection(userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
          final notifications = snapshot.docs
              .where((doc) => doc.id != 'summary')
              .map((doc) => BuyerNotificationModel.fromMap(doc.id, doc.data()))
              .where((model) => !model.isExpired)
              .toList();
          notifications.sort((a, b) {
            final aTime = a.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
            final bTime = b.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
            return bTime.compareTo(aTime);
          });
          return notifications;
        });
  }

  @override
  Stream<int> watchUnreadCount(String userId) {
    return watchNotifications(userId)
        .map((list) => list.where((n) => n.isUnread).length)
        .distinct();
  }

  @override
  Future<void> markAsRead(String userId, String notificationId) async {
    await _collection(userId).doc(notificationId).update({
      'isRead': true,
      'readAt': FieldValue.serverTimestamp(),
    });
  }

  @override
  Future<void> markAllAsRead(String userId) async {
    final snapshot = await _collection(userId)
        .where('isRead', isEqualTo: false)
        .get();
    final batch = firestore.batch();
    for (final doc in snapshot.docs) {
      batch.update(doc.reference, {
        'isRead': true,
        'readAt': FieldValue.serverTimestamp(),
      });
    }
    if (snapshot.docs.isNotEmpty) {
      await batch.commit();
    }
  }

  @override
  Future<void> deleteNotification(String userId, String notificationId) async {
    await _collection(userId).doc(notificationId).delete();
  }

  @override
  Future<void> restoreNotification(
      String userId, BuyerNotificationModel notification) async {
    await _collection(userId).doc(notification.id).set(notification.toMap());
  }

  @override
  Future<void> clearAllNotifications(String userId) async {
    final snapshot = await _collection(userId).get();
    final batch = firestore.batch();
    for (final doc in snapshot.docs) {
      batch.delete(doc.reference);
    }
    if (snapshot.docs.isNotEmpty) {
      await batch.commit();
    }
  }
}
