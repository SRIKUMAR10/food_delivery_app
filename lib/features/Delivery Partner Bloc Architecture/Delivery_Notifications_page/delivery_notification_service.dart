import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import '../../../core/models/delivery_partner_notification_model.dart';
import 'delivery_notification_strings.dart';

abstract class DeliveryNotificationServiceBase {
  String formatTimeAgo(DateTime dateTime, String localeCode);
  void triggerNotificationFeedback();
  String getLocalizedTitle(
    DeliveryPartnerNotificationModel notification,
    String localeCode,
  );
  String getLocalizedBody(
    DeliveryPartnerNotificationModel notification,
    String localeCode,
  );
}

class DeliveryNotificationService implements DeliveryNotificationServiceBase {
  @override
  String formatTimeAgo(DateTime dateTime, String localeCode) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return DeliveryNotificationStrings.of('justNow', localeCode);
    } else if (difference.inMinutes < 60) {
      return DeliveryNotificationStrings.of('minutesAgo', localeCode)
          .replaceAll('{minutes}', difference.inMinutes.toString());
    } else if (difference.inHours < 24) {
      return DeliveryNotificationStrings.of('hoursAgo', localeCode)
          .replaceAll('{hours}', difference.inHours.toString());
    } else {
      return DeliveryNotificationStrings.of('daysAgo', localeCode)
          .replaceAll('{days}', difference.inDays.toString());
    }
  }

  @override
  void triggerNotificationFeedback() {
    try {
      if (!kIsWeb) {
        HapticFeedback.mediumImpact();
      }
    } catch (_) {}
  }

  @override
  String getLocalizedTitle(
    DeliveryPartnerNotificationModel notification,
    String localeCode,
  ) {
    if (notification.title.isNotEmpty) return notification.title;

    switch (notification.type) {
      case DeliveryPartnerNotificationType.newDeliveryRequest:
        return DeliveryNotificationStrings.of('newDeliveryRequest', localeCode);
      case DeliveryPartnerNotificationType.orderAssigned:
        return DeliveryNotificationStrings.of('orderAssigned', localeCode);
      case DeliveryPartnerNotificationType.orderCancelled:
        return DeliveryNotificationStrings.of('orderCancelled', localeCode);
      case DeliveryPartnerNotificationType.pickupReminder:
        return DeliveryNotificationStrings.of('pickupReminder', localeCode);
      case DeliveryPartnerNotificationType.deliveryReminder:
        return DeliveryNotificationStrings.of('deliveryReminder', localeCode);
      case DeliveryPartnerNotificationType.paymentAdded:
        return DeliveryNotificationStrings.of('paymentAdded', localeCode);
      case DeliveryPartnerNotificationType.bonus:
        return DeliveryNotificationStrings.of('bonus', localeCode);
      case DeliveryPartnerNotificationType.incentive:
        return DeliveryNotificationStrings.of('incentive', localeCode);
      case DeliveryPartnerNotificationType.withdrawalSuccess:
        return DeliveryNotificationStrings.of('withdrawalSuccess', localeCode);
      case DeliveryPartnerNotificationType.verificationApproved:
        return DeliveryNotificationStrings.of(
            'verificationApproved', localeCode);
      case DeliveryPartnerNotificationType.verificationRejected:
        return DeliveryNotificationStrings.of(
            'verificationRejected', localeCode);
      case DeliveryPartnerNotificationType.accountStatus:
        return DeliveryNotificationStrings.of('accountStatus', localeCode);
      case DeliveryPartnerNotificationType.newMessage:
        return DeliveryNotificationStrings.of('newMessage', localeCode);
      default:
        return DeliveryNotificationStrings.of('title', localeCode);
    }
  }

  @override
  String getLocalizedBody(
    DeliveryPartnerNotificationModel notification,
    String localeCode,
  ) {
    return notification.body;
  }
}
