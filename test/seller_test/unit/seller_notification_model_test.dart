import 'package:flutter_test/flutter_test.dart';
import 'package:food_delivery_app/core/models/seller_notification_model.dart';

void main() {
  group('SellerNotificationModel Unit Tests', () {
    final now = DateTime(2026, 8, 17, 10, 30);

    test('All SellerNotificationCategory enum values map correctly to and from strings', () {
      final categories = [
        SellerNotificationCategory.newOrder,
        SellerNotificationCategory.orderAccepted,
        SellerNotificationCategory.orderCancelled,
        SellerNotificationCategory.paymentUpdate,
        SellerNotificationCategory.deliveryPartnerAssigned,
        SellerNotificationCategory.pickupNotification,
        SellerNotificationCategory.customerMessage,
        SellerNotificationCategory.newReview,
        SellerNotificationCategory.lowStock,
        SellerNotificationCategory.outOfStock,
        SellerNotificationCategory.payoutCompleted,
        SellerNotificationCategory.promotional,
        SellerNotificationCategory.system,
      ];

      expect(categories.length, 13);

      for (final cat in categories) {
        final key = cat.value;
        final parsed = SellerNotificationCategory.fromString(key);
        expect(parsed, cat);
      }

      expect(
        SellerNotificationCategory.fromString('does_not_exist'),
        SellerNotificationCategory.unknown,
      );
    });

    test('Serialization toMap and fromMap works seamlessly', () {
      final model = SellerNotificationModel(
        id: 'notif_101',
        sellerId: 'seller_123',
        title: 'New Order Received',
        titleTa: 'புதிய ஆர்டர் வந்துள்ளது',
        body: 'Order #ORD-123 received with 3 items',
        bodyTa: 'ஆர்டர் #ORD-123 பெறப்பட்டது (3 பொருட்கள்)',
        category: SellerNotificationCategory.newOrder,
        priority: SellerNotificationPriority.urgent,
        actionType: SellerNotificationActionType.navigateOrder,
        orderId: 'ORD-123',
        customerName: 'Karthik',
        amount: 450.0,
        stockQuantity: 3,
        isRead: false,
        createdAt: now,
        actionPayload: {'orderId': 'ORD-123', 'amount': 450.0},
      );

      final map = model.toMap();
      expect(map['title'], 'New Order Received');
      expect(map['titleTa'], 'புதிய ஆர்டர் வந்துள்ளது');
      expect(map['category'], 'new_order');
      expect(map['priority'], 'urgent');
      expect(map['actionType'], 'navigate_order');
      expect(map['orderId'], 'ORD-123');
      expect(map['amount'], 450.0);
      expect(map['stockQuantity'], 3);
      expect(map['isRead'], false);

      final reconstructed = SellerNotificationModel.fromMap('notif_101', map);
      expect(reconstructed.id, 'notif_101');
      expect(reconstructed.sellerId, 'seller_123');
      expect(reconstructed.title, 'New Order Received');
      expect(reconstructed.titleTa, 'புதிய ஆர்டர் வந்துள்ளது');
      expect(reconstructed.category, SellerNotificationCategory.newOrder);
      expect(reconstructed.priority, SellerNotificationPriority.urgent);
      expect(
        reconstructed.actionType,
        SellerNotificationActionType.navigateOrder,
      );
      expect(reconstructed.orderId, 'ORD-123');
      expect(reconstructed.amount, 450.0);
      expect(reconstructed.stockQuantity, 3);
      expect(reconstructed.isRead, false);
    });

    test('Bilingual localization helper returns Tamil or English accurately', () {
      final model = SellerNotificationModel(
        id: 'notif_102',
        sellerId: 'seller_123',
        title: 'Low Stock Alert',
        titleTa: 'குறைந்த இருப்பு எச்சரிக்கை',
        body: 'Paneer Butter Masala has only 3 units left',
        bodyTa: 'பனீர் பட்டர் மசாலா இருப்பில் 3 மட்டுமே உள்ளது',
        category: SellerNotificationCategory.lowStock,
        priority: SellerNotificationPriority.high,
        stockQuantity: 3,
        productName: 'Paneer Butter Masala',
        createdAt: now,
      );

      expect(model.getLocalizedTitle('en'), 'Low Stock Alert');
      expect(model.getLocalizedTitle('ta'), 'குறைந்த இருப்பு எச்சரிக்கை');
      expect(
        model.getLocalizedBody('en'),
        'Paneer Butter Masala has only 3 units left',
      );
      expect(
        model.getLocalizedBody('ta'),
        'பனீர் பட்டர் மசாலா இருப்பில் 3 மட்டுமே உள்ளது',
      );
    });

    test('copyWith updates fields without mutating original instance', () {
      final model = SellerNotificationModel(
        id: 'notif_103',
        sellerId: 'seller_123',
        title: 'Payout Completed',
        body: 'Weekly payout credited',
        category: SellerNotificationCategory.payoutCompleted,
        amount: 5200.0,
        isRead: false,
        createdAt: now,
      );

      final updated = model.copyWith(isRead: true, amount: 6000.0);
      expect(model.isRead, false);
      expect(model.amount, 5200.0);
      expect(updated.isRead, true);
      expect(updated.amount, 6000.0);
      expect(updated.id, 'notif_103');
    });

    test('Fallback values work safely when parsing malformed or minimal map', () {
      final minimalMap = <String, dynamic>{};
      final parsed = SellerNotificationModel.fromMap('doc_999', minimalMap);

      expect(parsed.id, 'doc_999');
      expect(parsed.sellerId, '');
      expect(parsed.title, '');
      expect(parsed.body, '');
      expect(parsed.category, SellerNotificationCategory.unknown);
      expect(parsed.priority, SellerNotificationPriority.medium);
      expect(parsed.actionType, SellerNotificationActionType.none);
      expect(parsed.isRead, false);
    });
  });
}
