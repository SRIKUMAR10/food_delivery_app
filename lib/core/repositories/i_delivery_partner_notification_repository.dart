import '../models/delivery_partner_notification_model.dart';

abstract class IDeliveryPartnerNotificationRepository {
  Stream<List<DeliveryPartnerNotificationModel>> watchNotifications(
    String partnerId,
  );

  Future<List<DeliveryPartnerNotificationModel>> getNotifications(
    String partnerId,
  );

  Future<void> markAsRead(String partnerId, String notificationId);

  Future<void> markAllAsRead(String partnerId);

  Future<void> deleteNotification(String partnerId, String notificationId);

  Future<void> clearAll(String partnerId);

  Future<void> sendNotification(DeliveryPartnerNotificationModel notification);
}
