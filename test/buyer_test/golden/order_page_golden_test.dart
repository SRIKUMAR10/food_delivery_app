import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:food_delivery_app/features/buyer_bloc_architecture/Order%20Page/order_UI.dart';
import 'package:mocktail/mocktail.dart';

import 'package:food_delivery_app/core/models/order_model.dart';
import 'package:food_delivery_app/core/models/order_status.dart';
import 'package:food_delivery_app/core/repositories/i_order_repository.dart';
import 'package:food_delivery_app/core/services/i_auth_service.dart';

class MockOrderRepository extends Mock implements IOrderRepository {}

class MockAuthService extends Mock implements IAuthService {}

void main() {
  group('OrderPageUI Golden Tests', () {
    late MockOrderRepository mockOrderRepository;
    late MockAuthService mockAuthService;

    setUp(() {
      mockOrderRepository = MockOrderRepository();
      mockAuthService = MockAuthService();
      when(() => mockAuthService.currentUserId).thenReturn('test_uid');
      when(() => mockAuthService.ensureTokenReady()).thenAnswer((_) async {});
    });

    testWidgets('Golden test for OrderLoaded state', (
      WidgetTester tester,
    ) async {
      // Create some fake data
      final mockOrders = [
        OrderModel(
          id: '1',
          customerId: 'cust1',
          customerName: 'Test Customer',
          sellerId: 'seller1',
          status: OrderStatus.newOrder,
          amount: 100.0,
          timestamp: DateTime(2023, 1, 1),
          items: const [],
        ),
      ];

      when(
        () => mockOrderRepository.getBuyerOrdersStream(any()),
      ).thenAnswer((_) => Stream.value(mockOrders));

      await tester.pumpWidget(
        MaterialApp(
          home: OrderPageUI(
            orderRepository: mockOrderRepository,
            authService: mockAuthService,
          ),
        ),
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
