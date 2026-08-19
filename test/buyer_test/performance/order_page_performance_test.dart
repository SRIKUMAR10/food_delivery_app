import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:food_delivery_app/features/buyer_bloc_architecture/Order Page/order_UI.dart';
import 'package:mocktail/mocktail.dart';

import 'package:food_delivery_app/core/models/order_model.dart';
import 'package:food_delivery_app/core/models/order_status.dart';
import 'package:food_delivery_app/core/repositories/i_order_repository.dart';
import 'package:food_delivery_app/core/services/i_auth_service.dart';

class MockIOrderRepository extends Mock implements IOrderRepository {}

class MockIAuthService extends Mock implements IAuthService {}

void main() {
  group('Order Page Performance Test', () {
    testWidgets('Measures scrolling performance on Order Page', (
      WidgetTester tester,
    ) async {
      final mockRepository = MockIOrderRepository();
      final mockAuthService = MockIAuthService();

      final mockOrders = List.generate(20, (i) => OrderModel(
        id: 'order$i',
        customerId: 'test_uid',
        customerName: 'Test Customer',
        sellerId: 'seller1',
        status: OrderStatus.newOrder,
        amount: 500.0,
        timestamp: DateTime.now(),
        items: const [],
      ));

      when(() => mockAuthService.currentUserId).thenReturn('test_uid');
      when(() => mockAuthService.ensureTokenReady()).thenAnswer((_) async {});
      when(
        () => mockRepository.getBuyerOrdersStream(any()),
      ).thenAnswer((_) => Stream.value(mockOrders));

      await tester.pumpWidget(
        MaterialApp(
          home: OrderPageUI(
            orderRepository: mockRepository,
            authService: mockAuthService,
          ),
        ),
      );

      await tester.pumpAndSettle();

      final listFinder = find.byType(ListView);

      if (listFinder.evaluate().isNotEmpty) {
        // Record performance trace
        final stopwatch = Stopwatch()..start();
        // Scroll down the list
        await tester.fling(listFinder, const Offset(0, -500), 10000);
        await tester.pumpAndSettle();
        stopwatch.stop();
        expect(stopwatch.elapsedMilliseconds, lessThan(1000));
      }
    });
  });
}
