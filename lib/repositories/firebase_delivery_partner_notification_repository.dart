import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../core/models/delivery_partner_notification_model.dart';
import '../core/repositories/i_delivery_partner_notification_repository.dart';

class FirebaseDeliveryPartnerNotificationRepository
    implements IDeliveryPartnerNotificationRepository {
  final FirebaseFirestore? _firestore;

  FirebaseDeliveryPartnerNotificationRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? _safeFirestore();

  static FirebaseFirestore? _safeFirestore() {
    try {
      return FirebaseFirestore.instance;
    } catch (_) {
      return null;
    }
  }

  CollectionReference<Map<String, dynamic>>? _notifRef(String partnerId) {
    if (_firestore == null) return null;
    return _firestore!
        .collection('delivery_partners')
        .doc(partnerId)
        .collection('notifications');
  }

  @override
  Stream<List<DeliveryPartnerNotificationModel>> watchNotifications(
    String partnerId,
  ) {
    if (partnerId.trim().isEmpty || _firestore == null) {
      return Stream.value(const []);
    }

    final ref = _notifRef(partnerId);
    if (ref == null) return Stream.value(const []);

    return ref
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return DeliveryPartnerNotificationModel.fromFirestore(doc);
      }).toList();
    }).handleError((error) {
      debugPrint('Error streaming delivery notifications: $error');
      return <DeliveryPartnerNotificationModel>[];
    });
  }

  @override
  Future<List<DeliveryPartnerNotificationModel>> getNotifications(
    String partnerId,
  ) async {
    if (partnerId.trim().isEmpty || _firestore == null) return const [];


    try {
      final ref = _notifRef(partnerId);
      if (ref == null) return const [];
      final snapshot = await ref
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs.map((doc) {
        return DeliveryPartnerNotificationModel.fromFirestore(doc);
      }).toList();
    } catch (e) {
      debugPrint('Error fetching delivery notifications: $e');
      return const [];
    }
  }

  @override
  Future<void> markAsRead(String partnerId, String notificationId) async {
    if (partnerId.trim().isEmpty || notificationId.trim().isEmpty) return;

    try {
      await _notifRef(partnerId)?.doc(notificationId).update({
        'isRead': true,
        'readAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      debugPrint('Error marking notification as read: $e');
    }
  }

  @override
  Future<void> markAllAsRead(String partnerId) async {
    if (partnerId.trim().isEmpty || _firestore == null) return;

    try {
      final ref = _notifRef(partnerId);
      if (ref == null) return;
      final unreadDocs =
          await ref.where('isRead', isEqualTo: false).get();

      final batch = _firestore!.batch();
      for (final doc in unreadDocs.docs) {
        batch.update(doc.reference, {
          'isRead': true,
          'readAt': FieldValue.serverTimestamp(),
        });
      }
      await batch.commit();
    } catch (e) {
      debugPrint('Error marking all notifications as read: $e');
    }
  }

  @override
  Future<void> deleteNotification(
    String partnerId,
    String notificationId,
  ) async {
    if (partnerId.trim().isEmpty || notificationId.trim().isEmpty) return;

    try {
      await _notifRef(partnerId)?.doc(notificationId).delete();
    } catch (e) {
      debugPrint('Error deleting notification: $e');
    }
  }

  @override
  Future<void> clearAll(String partnerId) async {
    if (partnerId.trim().isEmpty || _firestore == null) return;

    try {
      final ref = _notifRef(partnerId);
      if (ref == null) return;
      final allDocs = await ref.get();
      final batch = _firestore!.batch();
      for (final doc in allDocs.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();
    } catch (e) {
      debugPrint('Error clearing all notifications: $e');
    }
  }

  @override
  Future<void> sendNotification(
    DeliveryPartnerNotificationModel notification,
  ) async {
    if (notification.recipientId.trim().isEmpty) return;

    try {
      await _notifRef(notification.recipientId)?.add(notification.toFirestore());
    } catch (e) {
      debugPrint('Error sending delivery partner notification: $e');
    }
  }
}
