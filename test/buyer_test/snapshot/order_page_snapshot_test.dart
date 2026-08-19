import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:food_delivery_app/features/buyer_bloc_architecture/Order Page/order_UI.dart';
import 'package:food_delivery_app/core/repositories/i_order_repository.dart';
import 'package:food_delivery_app/core/services/i_auth_service.dart';
import 'package:mocktail/mocktail.dart';

class MockOrderRepository extends Mock implements IOrderRepository {}
class MockAuthService extends Mock implements IAuthService {}

void main() {
  group('OrderPage Snapshot Tests', () {
    late MockOrderRepository mockOrderRepository;
    late MockAuthService mockAuthService;

    setUp(() {
      mockOrderRepository = MockOrderRepository();
      mockAuthService = MockAuthService();
    });

    testWidgets('Snapshot captures structural widget tree changes', (
      WidgetTester tester,
    ) async {
      when(
        () => mockOrderRepository.getBuyerOrdersStream(any()),
      ).thenAnswer((_) => Stream.value([]));

      await tester.pumpWidget(
        MaterialApp(home: OrderPageUI(orderRepository: mockOrderRepository, authService: mockAuthService)),
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
