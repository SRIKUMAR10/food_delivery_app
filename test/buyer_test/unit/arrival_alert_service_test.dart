import 'package:flutter_test/flutter_test.dart';
import 'package:food_delivery_app/core/services/arrival_alert_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('ArrivalAlertService Unit Tests', () {
    setUp(() {
      ArrivalAlertService.instance.clearAll();
    });

    test('Initial state: hasAlerted is false for new order', () {
      expect(ArrivalAlertService.instance.hasAlerted('order_123'), isFalse);
    });

    test('One-shot guard: First trigger returns true, subsequent trigger returns false', () async {
      final firstResult = await ArrivalAlertService.instance.triggerArrivalAlert(
        orderId: 'order_test_456',
        partnerName: 'Ramesh',
      );
      expect(firstResult, isTrue);
      expect(ArrivalAlertService.instance.hasAlerted('order_test_456'), isTrue);

      final secondResult = await ArrivalAlertService.instance.triggerArrivalAlert(
        orderId: 'order_test_456',
        partnerName: 'Ramesh',
      );
      expect(secondResult, isFalse);
    });

    test('resetAlert allows re-triggering for specified orderId', () async {
      await ArrivalAlertService.instance.triggerArrivalAlert(
        orderId: 'order_test_789',
      );
      expect(ArrivalAlertService.instance.hasAlerted('order_test_789'), isTrue);

      ArrivalAlertService.instance.resetAlert('order_test_789');
      expect(ArrivalAlertService.instance.hasAlerted('order_test_789'), isFalse);

      final reTriggerResult = await ArrivalAlertService.instance.triggerArrivalAlert(
        orderId: 'order_test_789',
      );
      expect(reTriggerResult, isTrue);
    });

    test('Empty orderId is safely rejected without alerting', () async {
      final result = await ArrivalAlertService.instance.triggerArrivalAlert(
        orderId: '',
      );
      expect(result, isFalse);
      expect(ArrivalAlertService.instance.hasAlerted(''), isFalse);
    });
  });
}
