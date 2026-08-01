import 'package:flutter_test/flutter_test.dart';
import 'package:food_delivery_app/core/repositories/delivery_active_order_session_repository.dart';

void main() {
  group('DeliveryActiveOrderSessionRepository Tests', () {
    late DeliveryActiveOrderSessionRepository repository;

    setUp(() {
      repository = DeliveryActiveOrderSessionRepository();
    });

    tearDown(() {
      repository.dispose();
    });

    test('initial state has default values', () {
      final state = repository.currentState;
      expect(state.isOnline, isTrue);
      expect(state.walletBalance, equals(2450.50));
      expect(state.deliveryStage, equals(ActiveDeliveryStage.idle));
    });

    test('toggleOnlineStatus updates online state and emits stream event', () async {
      expect(repository.currentState.isOnline, isTrue);
      
      final expectation = expectLater(
        repository.sessionStream,
        emits(predicate<DeliverySessionState>((s) => s.isOnline == false)),
      );

      repository.toggleOnlineStatus();
      await expectation;
      expect(repository.currentState.isOnline, isFalse);
    });

    test('processWithdrawal updates wallet balance correctly', () async {
      final initialBalance = repository.currentState.walletBalance;
      const withdrawalAmount = 450.50;

      repository.processWithdrawal(withdrawalAmount);
      expect(
        repository.currentState.walletBalance,
        equals(initialBalance - withdrawalAmount),
      );
    });

    test('Active Delivery state machine transitions work seamlessly', () {
      repository.triggerIncomingOrder(
        orderId: '#ORD9999',
        storeName: 'Express Kitchen',
        customerName: 'Aravind',
        customerAddress: 'Nungambakkam, Chennai',
        orderAmount: 350.0,
      );

      expect(repository.currentState.deliveryStage, equals(ActiveDeliveryStage.incomingOrder));
      expect(repository.currentState.activeOrderId, equals('#ORD9999'));

      repository.acceptOrder();
      expect(repository.currentState.deliveryStage, equals(ActiveDeliveryStage.acceptedOrder));

      repository.confirmPickup();
      expect(repository.currentState.deliveryStage, equals(ActiveDeliveryStage.navigatingToCustomer));

      repository.completeDelivery();
      expect(repository.currentState.deliveryStage, equals(ActiveDeliveryStage.deliveryCompleted));
    });
  });
}
