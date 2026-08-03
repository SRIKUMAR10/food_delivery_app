import 'package:flutter_test/flutter_test.dart';
import 'package:food_delivery_app/core/repositories/delivery_active_order_session_repository.dart';

void main() {
  group('DeliveryActiveOrderSessionRepository', () {
    late DeliveryActiveOrderSessionRepository repo;

    setUp(() {
      repo = DeliveryActiveOrderSessionRepository();
    });

    tearDown(() {
      repo.dispose();
    });

    test('initial state is idle with default values', () {
      final state = repo.currentState;
      expect(state.isOnline, true);
      expect(state.walletBalance, 2450.50);
      expect(state.pendingWithdrawal, 500.00);
      expect(state.totalEarningsToday, 1280.00);
      expect(state.completedOrdersCount, 14);
      expect(state.deliveryStage, ActiveDeliveryStage.idle);
      expect(state.activeOrderId, isNull);
    });

    test('toggleOnlineStatus flips isOnline', () {
      repo.toggleOnlineStatus();
      expect(repo.currentState.isOnline, false);
      repo.toggleOnlineStatus();
      expect(repo.currentState.isOnline, true);
    });

    test('setOnlineStatus sets isOnline explicitly', () {
      repo.setOnlineStatus(false);
      expect(repo.currentState.isOnline, false);
      repo.setOnlineStatus(true);
      expect(repo.currentState.isOnline, true);
    });

    test('processWithdrawal updates wallet and pending withdrawal', () {
      repo.processWithdrawal(200.00);
      expect(repo.currentState.walletBalance, 2250.50);
      expect(repo.currentState.pendingWithdrawal, 700.00);
    });

    test('processWithdrawal with zero or negative amount does nothing', () {
      final before = repo.currentState;
      repo.processWithdrawal(0);
      expect(repo.currentState.walletBalance, before.walletBalance);
      repo.processWithdrawal(-100);
      expect(repo.currentState.walletBalance, before.walletBalance);
    });

    test('processWithdrawal exceeding balance does nothing', () {
      final before = repo.currentState;
      repo.processWithdrawal(10000.00);
      expect(repo.currentState.walletBalance, before.walletBalance);
    });

    test('triggerIncomingOrder sets stage and order details', () {
      repo.triggerIncomingOrder(
        orderId: '#ORD001',
        storeName: 'Test Store',
        customerName: 'Test Customer',
        orderAmount: 500.00,
      );
      final state = repo.currentState;
      expect(state.deliveryStage, ActiveDeliveryStage.incomingOrder);
      expect(state.activeOrderId, '#ORD001');
      expect(state.storeName, 'Test Store');
      expect(state.customerName, 'Test Customer');
      expect(state.orderAmount, 500.00);
    });

    group('State Machine Transitions', () {
      setUp(() {
        repo.triggerIncomingOrder();
      });

      test('acceptOrder transitions to acceptedOrder', () {
        repo.acceptOrder();
        expect(repo.currentState.deliveryStage, ActiveDeliveryStage.acceptedOrder);
      });

      test('declineOrder transitions to idle', () {
        repo.declineOrder();
        expect(repo.currentState.deliveryStage, ActiveDeliveryStage.idle);
      });

      test('confirmPickup transitions to navigatingToCustomer', () {
        repo.acceptOrder();
        repo.confirmPickup();
        expect(repo.currentState.deliveryStage, ActiveDeliveryStage.navigatingToCustomer);
      });

      test('completeDelivery updates earnings, wallet, count', () {
        repo.acceptOrder();
        repo.confirmPickup();

        final walletBefore = repo.currentState.walletBalance;
        final earningsBefore = repo.currentState.totalEarningsToday;
        final countBefore = repo.currentState.completedOrdersCount;

        repo.completeDelivery();

        final state = repo.currentState;
        expect(state.deliveryStage, ActiveDeliveryStage.deliveryCompleted);
        expect(state.walletBalance, walletBefore + 107.5);
        expect(state.totalEarningsToday, earningsBefore + 107.5);
        expect(state.completedOrdersCount, countBefore + 1);
      });

      test('resetOrder returns to idle', () {
        repo.acceptOrder();
        repo.confirmPickup();
        repo.completeDelivery();
        repo.resetOrder();
        expect(repo.currentState.deliveryStage, ActiveDeliveryStage.idle);
      });
    });

    group('Stream emissions', () {
      test('toggleOnlineStatus emits updated state on stream', () async {
        final future = repo.sessionStream.first;
        repo.toggleOnlineStatus();
        final state = await future.timeout(
          const Duration(seconds: 2),
          onTimeout: () => throw Exception('Stream did not emit'),
        );
        expect(state.isOnline, false);
      });
    });

    test('full delivery lifecycle', () {
      expect(repo.currentState.deliveryStage, ActiveDeliveryStage.idle);

      repo.triggerIncomingOrder();
      expect(repo.currentState.deliveryStage, ActiveDeliveryStage.incomingOrder);

      repo.acceptOrder();
      expect(repo.currentState.deliveryStage, ActiveDeliveryStage.acceptedOrder);

      repo.confirmPickup();
      expect(repo.currentState.deliveryStage, ActiveDeliveryStage.navigatingToCustomer);

      repo.completeDelivery();
      expect(repo.currentState.deliveryStage, ActiveDeliveryStage.deliveryCompleted);

      repo.resetOrder();
      expect(repo.currentState.deliveryStage, ActiveDeliveryStage.idle);
    });
  });
}
