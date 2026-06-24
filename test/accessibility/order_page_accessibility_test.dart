import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:food_delivery_app/features/buyer_bloc_architecture/Order Page/order_UI.dart';
import 'package:mocktail/mocktail.dart';

import 'package:food_delivery_app/features/buyer_bloc_architecture/Order Page/order_repository.dart';
import 'package:food_delivery_app/features/buyer_bloc_architecture/Order Page/order_models.dart';

class MockOrderRepository extends Mock implements OrderRepository {}

void main() {
  group('OrderPage Accessibility Tests', () {
    late MockOrderRepository mockOrderRepository;

    setUp(() {
      mockOrderRepository = MockOrderRepository();
      when(
        () => mockOrderRepository.getOrdersStream(),
      ).thenAnswer((_) => Stream.value(<OrderModel>[]));
    });

    testWidgets('OrderPage meets tap target and semantics guidelines', (
      WidgetTester tester,
    ) async {
      final SemanticsHandle handle = tester.ensureSemantics();

      await tester.pumpWidget(
        MaterialApp(home: OrderPageUI(orderRepository: mockOrderRepository)),
      );

      await tester.pumpAndSettle();

      // Verify that all tap targets are at least 48x48
      await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
      await expectLater(tester, meetsGuideline(iOSTapTargetGuideline));

      // Verify text contrast meets minimum requirements
      await expectLater(tester, meetsGuideline(textContrastGuideline));

      handle.dispose();
    });
  });
}
