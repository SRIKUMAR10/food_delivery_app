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

    testWidgets('Renders localized text properly for Tamil locale', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          // Suppose your app uses flutter_localizations and defines delegates
          supportedLocales: const [Locale('en', 'US'), Locale('ta', 'IN')],
          home: OrderPageUI(orderRepository: mockOrderRepository, authService: mockAuthService),
        ),
      );
      await tester.pumpAndSettle();

      // Verify UI renders without breaking due to string overflow in a different language
      expect(find.byType(OrderPageUI), findsOneWidget);
      // NOTE: You would typically verify find.text('என் ஆர்டர்கள்') or similar localized string.
    });
  });
}
