import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:food_delivery_app/features/buyer_bloc_architecture/Order%20Page/order_UI.dart';
import 'package:food_delivery_app/core/repositories/i_order_repository.dart';
import 'package:food_delivery_app/core/services/i_auth_service.dart';
import 'package:mocktail/mocktail.dart';

class MockOrderRepository extends Mock implements IOrderRepository {}
class MockAuthService extends Mock implements IAuthService {}

void main() {
  group('OrderPage Localization Tests', () {
    late MockOrderRepository mockOrderRepository;
    late MockAuthService mockAuthService;

    setUp(() {
      mockOrderRepository = MockOrderRepository();
      mockAuthService = MockAuthService();
      when(
        () => mockOrderRepository.getBuyerOrdersStream(any()),
      ).thenAnswer((_) => Stream.value([]));
    });

    testWidgets('Renders localized text properly', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          supportedLocales: const [Locale('en', 'US'), Locale('ta', 'IN')],
          home: OrderPageUI(orderRepository: mockOrderRepository, authService: mockAuthService),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(OrderPageUI), findsOneWidget);
    });
  });
}
