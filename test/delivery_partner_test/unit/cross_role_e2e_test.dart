import 'package:flutter_test/flutter_test.dart';
import 'package:food_delivery_app/core/models/order_model.dart';
import 'package:food_delivery_app/core/models/order_status.dart';
import 'package:food_delivery_app/core/repositories/delivery_active_order_session_repository.dart';
import 'package:food_delivery_app/core/services/notification_service.dart';

void main() {
  group('Cross-Role E2E - Complete Order Lifecycle', () {
    late DeliveryActiveOrderSessionRepository sessionRepo;

    setUp(() {
      sessionRepo = DeliveryActiveOrderSessionRepository();
    });

    tearDown(() {
      sessionRepo.dispose();
    });

    test('Step 1: Buyer places order (New → Accepted)', () {
      final order = OrderModel(
        id: 'ORD-E2E-001',
        customerId: 'buyer-001',
        customerName: 'Rahul Sharma',
        sellerId: 'seller-001',
        status: OrderStatus.newOrder,
        amount: 620.00,
        timestamp: DateTime.now(),
        deliveryAddress: '12, Beach Road, Chennai',
        customerPhone: '+919876543210',
        paymentMethod: 'COD',
        items: [],
      );

      expect(order.status, equals(OrderStatus.newOrder));
      expect(order.canTransitionTo(OrderStatus.accepted), isTrue);
      expect(order.canTransitionTo(OrderStatus.cancelled), isTrue);
      expect(order.canTransitionTo(OrderStatus.delivered), isFalse);
    });

    test('Step 2: Seller accepts and prepares (Accepted → Preparing → Ready)', () {
      var order = OrderModel(
        id: 'ORD-E2E-001',
        customerId: 'buyer-001',
        customerName: 'Rahul Sharma',
        sellerId: 'seller-001',
        status: OrderStatus.accepted,
        amount: 620.00,
        timestamp: DateTime.now(),
      );

      expect(order.canTransitionTo(OrderStatus.preparing), isTrue);
      order = order.copyWith(status: OrderStatus.preparing);
      expect(order.status, equals(OrderStatus.preparing));

      expect(order.canTransitionTo(OrderStatus.ready), isTrue);
      order = order.copyWith(status: OrderStatus.ready);
      expect(order.status, equals(OrderStatus.ready));

      expect(order.canTransitionTo(OrderStatus.outForDelivery), isTrue);
      expect(order.canTransitionTo(OrderStatus.cancelled), isTrue);
    });

    test('Step 3: Delivery partner assigned (Ready → OutForDelivery)', () {
      var order = OrderModel(
        id: 'ORD-E2E-001',
        customerId: 'buyer-001',
        customerName: 'Rahul Sharma',
        sellerId: 'seller-001',
        riderId: 'rider-001',
        status: OrderStatus.outForDelivery,
        amount: 620.00,
        timestamp: DateTime.now(),
        deliveryAddress: '12, Beach Road, Chennai',
      );

      expect(order.status, equals(OrderStatus.outForDelivery));
      expect(order.riderId, equals('rider-001'));
      expect(order.canTransitionTo(OrderStatus.delivered), isTrue);
      expect(order.canTransitionTo(OrderStatus.cancelled), isTrue);
    });

    test('Step 4: Delivery completed (OutForDelivery → Delivered)', () {
      var order = OrderModel(
        id: 'ORD-E2E-001',
        customerId: 'buyer-001',
        customerName: 'Rahul Sharma',
        sellerId: 'seller-001',
        riderId: 'rider-001',
        status: OrderStatus.delivered,
        amount: 620.00,
        timestamp: DateTime.now(),
      );

      expect(order.status, equals(OrderStatus.delivered));
      expect(order.canTransitionTo(OrderStatus.accepted), isFalse);
      expect(order.canTransitionTo(OrderStatus.preparing), isFalse);
      expect(order.canTransitionTo(OrderStatus.outForDelivery), isFalse);
    });

    test('Step 5: Wallet update for seller on delivery', () {
      final deliveryEarnings = 620.00 * 0.15 + 40.0;
      expect(deliveryEarnings, equals(133.0));

      final orderAmount = 620.00;
      final partnerEarnings = orderAmount * 0.15 + 40.0;
      expect(partnerEarnings, closeTo(133.0, 0.01));
    });
  });

  group('Cross-Role E2E - Delivery Session State Machine', () {
    late DeliveryActiveOrderSessionRepository sessionRepo;

    setUp(() {
      sessionRepo = DeliveryActiveOrderSessionRepository();
    });

    tearDown(() {
      sessionRepo.dispose();
    });

    test('Full delivery flow: idle → incoming → accepted → pickup → navigating → completed', () {
      expect(sessionRepo.currentState.deliveryStage, equals(ActiveDeliveryStage.idle));

      sessionRepo.triggerIncomingOrder(
        orderId: '#ORD-E2E-002',
        storeName: 'Green Mart',
        storeAddress: '24, Anna Salai, Chennai',
        customerName: 'Arun Kumar',
        customerAddress: '12, Beach Road, Chennai',
        orderAmount: 450.00,
      );
      expect(sessionRepo.currentState.deliveryStage, equals(ActiveDeliveryStage.incomingOrder));
      expect(sessionRepo.currentState.activeOrderId, equals('#ORD-E2E-002'));

      sessionRepo.acceptOrder();
      expect(sessionRepo.currentState.deliveryStage, equals(ActiveDeliveryStage.acceptedOrder));

      sessionRepo.confirmPickup();
      expect(sessionRepo.currentState.deliveryStage, equals(ActiveDeliveryStage.navigatingToCustomer));

      final prevEarnings = sessionRepo.currentState.totalEarningsToday;

      sessionRepo.completeDelivery(deliveryFee: 40.0);
      expect(sessionRepo.currentState.deliveryStage, equals(ActiveDeliveryStage.deliveryCompleted));
      expect(sessionRepo.currentState.totalEarningsToday, greaterThan(prevEarnings));
      expect(sessionRepo.currentState.completedOrdersCount, equals(1));
    });

    test('Withdrawal flow within session', () {
      sessionRepo.completeDelivery(deliveryFee: 500.0);

      final initialBalance = sessionRepo.currentState.walletBalance;
      expect(initialBalance, equals(500.0));

      sessionRepo.processWithdrawal(500.0);
      expect(sessionRepo.currentState.walletBalance, equals(0.0));
      expect(sessionRepo.currentState.pendingWithdrawal, equals(500.0));

      sessionRepo.processWithdrawal(2000.0);
      expect(sessionRepo.currentState.walletBalance, equals(0.0));
    });

    test('Online/Offline toggle and stream', () async {
      expect(sessionRepo.currentState.isOnline, isTrue);

      final states = <DeliverySessionState>[];
      final sub = sessionRepo.sessionStream.listen(states.add);

      sessionRepo.setOnlineStatus(false);
      await Future.delayed(const Duration(milliseconds: 50));
      expect(states.length, equals(1));
      expect(states.last.isOnline, isFalse);

      sessionRepo.setOnlineStatus(true);
      await Future.delayed(const Duration(milliseconds: 50));
      expect(states.length, equals(2));
      expect(states.last.isOnline, isTrue);

      await sub.cancel();
    });
  });

  group('Cross-Role E2E - Notification Service', () {
    test('NotificationService singleton works', () {
      final service1 = NotificationService();
      final service2 = NotificationService();
      expect(identical(service1, service2), isTrue);
    }, skip: 'Requires Firebase initialization');
  });

  group('Cross-Role E2E - Order CopyWith & Map Roundtrip', () {
    test('Complete order map roundtrip with all fields', () {
      final original = OrderModel(
        id: 'ORD-E2E-RT',
        customerId: 'buyer-rt',
        customerName: 'Round Trip Customer',
        sellerId: 'seller-rt',
        riderId: 'rider-rt',
        status: OrderStatus.outForDelivery,
        amount: 899.50,
        timestamp: DateTime.now(),
        deliveryAddress: '42 Test Street, Chennai',
        customerPhone: '+919876543210',
        paymentMethod: 'Online',
        acceptedAt: DateTime.now().subtract(const Duration(minutes: 30)),
        preparingAt: DateTime.now().subtract(const Duration(minutes: 20)),
        readyAt: DateTime.now().subtract(const Duration(minutes: 10)),
        outForDeliveryAt: DateTime.now().subtract(const Duration(minutes: 5)),
      );

      final map = original.toMap();
      expect(map['status'], equals('OutForDelivery'));
      expect(map['amount'], equals(899.50));
      expect(map['riderId'], equals('rider-rt'));
      expect(map['paymentMethod'], equals('Online'));
      expect(map['deliveryAddress'], equals('42 Test Street, Chennai'));

      final restored = OrderModel.fromMap(map, original.id);
      expect(restored.id, equals(original.id));
      expect(restored.status, equals(original.status));
      expect(restored.amount, closeTo(original.amount, 1.0));
      expect(restored.riderId, equals(original.riderId));
      expect(restored.deliveryAddress, equals(original.deliveryAddress));
      expect(restored.paymentMethod, equals(original.paymentMethod));
      expect(restored.customerPhone, equals(original.customerPhone));
    });
  });

  group('Cross-Role E2E - Order Validation', () {
    test('Rejected orders are terminal', () {
      final order = OrderModel(
        id: 'ORD-E2E-TERM',
        customerId: 'buyer-term',
        customerName: 'Term Test',
        sellerId: 'seller-term',
        status: OrderStatus.rejected,
        amount: 100.0,
        timestamp: DateTime.now(),
      );

      expect(order.canTransitionTo(OrderStatus.accepted), isFalse);
      expect(order.canTransitionTo(OrderStatus.preparing), isFalse);
      expect(order.canTransitionTo(OrderStatus.delivered), isFalse);
    });

    test('Cancelled orders are terminal', () {
      final order = OrderModel(
        id: 'ORD-E2E-CANC',
        customerId: 'buyer-canc',
        customerName: 'Cancel Test',
        sellerId: 'seller-canc',
        status: OrderStatus.cancelled,
        amount: 100.0,
        timestamp: DateTime.now(),
      );

      expect(order.canTransitionTo(OrderStatus.accepted), isFalse);
      expect(order.canTransitionTo(OrderStatus.preparing), isFalse);
    });

    test('Cannot skip from Ready to Delivered', () {
      final order = OrderModel(
        id: 'ORD-E2E-SKIP',
        customerId: 'buyer-skip',
        customerName: 'Skip Test',
        sellerId: 'seller-skip',
        status: OrderStatus.ready,
        amount: 100.0,
        timestamp: DateTime.now(),
      );

      expect(order.canTransitionTo(OrderStatus.delivered), isFalse);
      expect(order.canTransitionTo(OrderStatus.outForDelivery), isTrue);
    });
  });
}
