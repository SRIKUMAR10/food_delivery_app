import '../../../core/models/delivery_partner_notification_model.dart';
import '../../../core/repositories/i_delivery_partner_notification_repository.dart';
import '../../../repositories/firebase_delivery_partner_notification_repository.dart';

abstract class DeliveryNotificationRepositoryBase {
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
}

class DeliveryNotificationRepository
    implements DeliveryNotificationRepositoryBase {
  final IDeliveryPartnerNotificationRepository _remoteRepository;

  DeliveryNotificationRepository({
    IDeliveryPartnerNotificationRepository? remoteRepository,
  }) : _remoteRepository = remoteRepository ??
            FirebaseDeliveryPartnerNotificationRepository();

  @override
  Stream<List<DeliveryPartnerNotificationModel>> watchNotifications(
    String partnerId,
  ) {
    return _remoteRepository.watchNotifications(partnerId);
  }

  @override
  Future<List<DeliveryPartnerNotificationModel>> getNotifications(
    String partnerId,
  ) {
    return _remoteRepository.getNotifications(partnerId);
  }

  @override
  Future<void> markAsRead(String partnerId, String notificationId) {
    return _remoteRepository.markAsRead(partnerId, notificationId);
  }

  @override
  Future<void> markAllAsRead(String partnerId) {
    return _remoteRepository.markAllAsRead(partnerId);
  }

  @override
  Future<void> deleteNotification(String partnerId, String notificationId) {
    return _remoteRepository.deleteNotification(partnerId, notificationId);
  }

  @override
  Future<void> clearAll(String partnerId) {
    return _remoteRepository.clearAll(partnerId);
  }
}
