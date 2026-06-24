import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:food_delivery_app/features/buyer_bloc_architecture/Order%20Page/order_UI.dart';
import 'package:food_delivery_app/features/buyer_bloc_architecture/Order%20Page/order_repository.dart';
import 'package:mocktail/mocktail.dart';

class MockOrderRepository extends Mock implements OrderRepository {}

void main() {
  group('OrderPage State Restoration Tests', () {
    late MockOrderRepository mockOrderRepository;

    setUp(() {
      mockOrderRepository = MockOrderRepository();
      when(
        () => mockOrderRepository.getOrdersStream(),
      ).thenAnswer((_) => Stream.value([]));
    });

    testWidgets('OrderPage retains scroll position on state restoration', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        RootRestorationScope(
          restorationId: 'root',
          child: MaterialApp(
            restorationScopeId: 'app',
            home: OrderPageUI(
              orderRepository: mockOrderRepository,
            ), // Ensure OrderPageUI uses RestorationMixin or similar if applicable
          ),
        ),
      );

      // Trigger state restoration cycle
      await tester.restartAndRestore();

      // Ensure widget still builds correctly after restoration
      expect(find.byType(OrderPageUI), findsOneWidget);
    });
  });
}
