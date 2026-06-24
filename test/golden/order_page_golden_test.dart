import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:food_delivery_app/features/buyer_bloc_architecture/Order%20Page/order_UI.dart';
import 'package:food_delivery_app/features/buyer_bloc_architecture/Order%20Page/order_models.dart';

import 'package:food_delivery_app/features/buyer_bloc_architecture/Order%20Page/order_repository.dart';
import 'package:mocktail/mocktail.dart';

class MockOrderRepository extends Mock implements OrderRepository {}

void main() {
  group('OrderPageUI Golden Tests', () {
    late MockOrderRepository mockOrderRepository;

    setUp(() {
      mockOrderRepository = MockOrderRepository();
    });

    testWidgets('Golden test for OrderLoaded state', (
      WidgetTester tester,
    ) async {
      // Create some fake data
      final mockOrders = [
        OrderModel(
          id: '1',
          status: 'Pending',
          totalAmount: 100.0,
          date: DateTime(2023, 1, 1),
          items: const [],
        ),
      ];

      when(
        () => mockOrderRepository.getOrdersStream(),
      ).thenAnswer((_) => Stream.value(mockOrders));

      await tester.pumpWidget(
        MaterialApp(home: OrderPageUI(orderRepository: mockOrderRepository)),
      );

      await tester.pumpAndSettle();

      // Matches the rendered widget against a saved image (golden file)
      // Note: Run `flutter test --update-goldens` to generate the initial image
      await expectLater(
        find.byType(OrderPageUI),
        matchesGoldenFile('goldens/order_page_loaded.png'),
      );
    });
  });
}
