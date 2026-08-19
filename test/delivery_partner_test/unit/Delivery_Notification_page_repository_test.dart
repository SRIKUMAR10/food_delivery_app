import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:food_delivery_app/core/models/delivery_partner_notification_model.dart';
import 'package:food_delivery_app/core/repositories/i_delivery_partner_notification_repository.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Notifications_page/delivery_notification_repository.dart';

class MockIDeliveryPartnerNotificationRepository extends Mock
    implements IDeliveryPartnerNotificationRepository {}

void main() {
  late MockIDeliveryPartnerNotificationRepository mockRemote;
  late DeliveryNotificationRepository repository;

  final sampleNotification = DeliveryPartnerNotificationModel(
    id: 'test_1',
    recipientId: 'partner_abc',
    title: 'Order Assigned',
    body: 'You have been assigned order #1001',
    type: DeliveryPartnerNotificationType.orderAssigned,
    category: DeliveryNotificationCategory.order,
    data: const {'orderId': '1001'},
    isRead: false,
    createdAt: DateTime.now(),
  );

  setUp(() {
    mockRemote = MockIDeliveryPartnerNotificationRepository();
    repository = DeliveryNotificationRepository(remoteRepository: mockRemote);
  });

  group('DeliveryNotificationRepository Tests', () {
    test('watchNotifications delegates to remote repository stream', () async {
      when(() => mockRemote.watchNotifications('partner_abc'))
          .thenAnswer((_) => Stream.value([sampleNotification]));

      final stream = repository.watchNotifications('partner_abc');
      expect(await stream.first, [sampleNotification]);
      verify(() => mockRemote.watchNotifications('partner_abc')).called(1);
    });

    test('getNotifications delegates to remote repository', () async {
      when(() => mockRemote.getNotifications('partner_abc'))
          .thenAnswer((_) async => [sampleNotification]);

      final result = await repository.getNotifications('partner_abc');
      expect(result, [sampleNotification]);
      verify(() => mockRemote.getNotifications('partner_abc')).called(1);
    });

    test('markAsRead delegates to remote repository', () async {
      when(() => mockRemote.markAsRead('partner_abc', 'test_1'))
          .thenAnswer((_) async {});

      await repository.markAsRead('partner_abc', 'test_1');
      verify(() => mockRemote.markAsRead('partner_abc', 'test_1')).called(1);
    });

    test('markAllAsRead delegates to remote repository', () async {
      when(() => mockRemote.markAllAsRead('partner_abc'))
          .thenAnswer((_) async {});

      await repository.markAllAsRead('partner_abc');
      verify(() => mockRemote.markAllAsRead('partner_abc')).called(1);
    });

    test('deleteNotification delegates to remote repository', () async {
      when(() => mockRemote.deleteNotification('partner_abc', 'test_1'))
          .thenAnswer((_) async {});

      await repository.deleteNotification('partner_abc', 'test_1');
      verify(() => mockRemote.deleteNotification('partner_abc', 'test_1')).called(1);
    });

    test('clearAll delegates to remote repository', () async {
      when(() => mockRemote.clearAll('partner_abc'))
          .thenAnswer((_) async {});

      await repository.clearAll('partner_abc');
      verify(() => mockRemote.clearAll('partner_abc')).called(1);
    });
  });
}
