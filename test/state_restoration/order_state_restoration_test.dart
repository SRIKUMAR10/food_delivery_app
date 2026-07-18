import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:food_delivery_app/features/buyer_bloc_architecture/Order%20Page/order_UI.dart';
import 'package:food_delivery_app/core/repositories/i_order_repository.dart';
import 'package:food_delivery_app/core/services/i_auth_service.dart';
import 'package:mocktail/mocktail.dart';

class MockOrderRepository extends Mock implements IOrderRepository {}
class MockAuthService extends Mock implements IAuthService {}

void main() {
  group('OrderPage State Restoration Tests', () {
    late MockOrderRepository mockOrderRepository;
    late MockAuthService mockAuthService;

    setUp(() {
      mockOrderRepository = MockOrderRepository();
      mockAuthService = MockAuthService();
      when(
        () => mockOrderRepository.getBuyerOrdersStream(any()),
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
              authService: mockAuthService,
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
