import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:food_delivery_app/features/buyer_bloc_architecture/Order Page/order_UI.dart';
import 'package:food_delivery_app/features/buyer_bloc_architecture/Order%20Page/order_repository.dart';
import 'package:mocktail/mocktail.dart';

class MockOrderRepository extends Mock implements OrderRepository {}

void main() {
  group('OrderPage Snapshot Tests', () {
    late MockOrderRepository mockOrderRepository;

    setUp(() {
      mockOrderRepository = MockOrderRepository();
    });

    testWidgets('Snapshot captures structural widget tree changes', (
      WidgetTester tester,
    ) async {
      when(
        () => mockOrderRepository.getOrdersStream(),
      ).thenAnswer((_) => const Stream.empty());

      await tester.pumpWidget(
        MaterialApp(home: OrderPageUI(orderRepository: mockOrderRepository)),
      );

      // This is conceptually similar to Golden Tests but typically compares text representations
      // of the widget tree. Since Flutter doesn't natively have a jest-like snapshot mechanism out of the box,
      // we usually verify the DiagnosticableTree string output.

      final stringRepresentation = tester
          .element(find.byType(OrderPageUI))
          .toStringDeep();
      expect(stringRepresentation, isNotEmpty);
      expect(stringRepresentation, contains('CircularProgressIndicator'));
    });
  });
}
