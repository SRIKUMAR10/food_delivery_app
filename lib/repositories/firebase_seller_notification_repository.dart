import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../core/models/seller_notification_model.dart';
import '../core/repositories/i_seller_notification_repository.dart';

/// Firestore implementation of [ISellerNotificationRepository].
///
/// Notifications are stored under `sellers/{sellerId}/notifications`.
/// Reserved documents such as `summary` or non-notification metadata are excluded.
class FirebaseSellerNotificationRepository
    implements ISellerNotificationRepository {
  final FirebaseFirestore firestore;

  FirebaseSellerNotificationRepository({FirebaseFirestore? firestore})
      : firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> _collection(String sellerId) =>
      firestore
          .collection('sellers')
          .doc(sellerId)
          .collection('notifications');

  @override
  Stream<List<SellerNotificationModel>> watchNotifications(String sellerId) {
    if (sellerId.isEmpty) {
      return Stream.value(<SellerNotificationModel>[]);
    }

    return _collection(sellerId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
          final notifications = snapshot.docs
              .where((doc) => doc.id != 'summary')
              .map((doc) => SellerNotificationModel.fromMap(doc.id, doc.data()))
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
  Stream<int> watchUnreadCount(String sellerId) {
    if (sellerId.isEmpty) {
      return Stream.value(0);
    }

    return watchNotifications(sellerId)
        .map((list) => list.where((n) => n.isUnread).length)
        .distinct();
  }

  @override
  Future<void> markAsRead(String sellerId, String notificationId) async {
    if (sellerId.isEmpty || notificationId.isEmpty) return;

    await _collection(sellerId).doc(notificationId).update({
      'isRead': true,
      'readAt': FieldValue.serverTimestamp(),
    });
  }

  @override
  Future<void> markAllAsRead(String sellerId) async {
    if (sellerId.isEmpty) return;

    final snapshot = await _collection(sellerId)
        .where('isRead', isEqualTo: false)
        .get();

    if (snapshot.docs.isEmpty) return;

    final batch = firestore.batch();
    for (final doc in snapshot.docs) {
      if (doc.id == 'summary') continue;
      batch.update(doc.reference, {
        'isRead': true,
        'readAt': FieldValue.serverTimestamp(),
      });
    }
    await batch.commit();
  }

  @override
  Future<void> deleteNotification(
      String sellerId, String notificationId) async {
    if (sellerId.isEmpty || notificationId.isEmpty) return;

    await _collection(sellerId).doc(notificationId).delete();
  }

  @override
  Future<void> restoreNotification(
      String sellerId, SellerNotificationModel notification) async {
    if (sellerId.isEmpty || notification.id.isEmpty) return;

    await _collection(sellerId)
        .doc(notification.id)
        .set(notification.toMap(), SetOptions(merge: true));
  }

  @override
  Future<void> clearAllNotifications(String sellerId) async {
    if (sellerId.isEmpty) return;

    final snapshot = await _collection(sellerId).get();
    if (snapshot.docs.isEmpty) return;

    final batch = firestore.batch();
    for (final doc in snapshot.docs) {
      batch.delete(doc.reference);
    }
    await batch.commit();
  }

  @override
  Future<String> createNotification(
      String sellerId, SellerNotificationModel notification) async {
    if (sellerId.isEmpty) return '';

    final docRef = notification.id.isNotEmpty
        ? _collection(sellerId).doc(notification.id)
        : _collection(sellerId).doc();

    final data = notification.toMap();
    data['id'] = docRef.id;
    data['sellerId'] = sellerId;
    data['createdAt'] = FieldValue.serverTimestamp();

    await docRef.set(data, SetOptions(merge: true));
    return docRef.id;
  }
}
