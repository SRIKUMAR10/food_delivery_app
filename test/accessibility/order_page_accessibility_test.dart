import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:food_delivery_app/features/buyer_bloc_architecture/Order Page/order_UI.dart';
import 'package:mocktail/mocktail.dart';

import 'package:food_delivery_app/core/models/order_model.dart';
import 'package:food_delivery_app/core/repositories/i_order_repository.dart';
import 'package:food_delivery_app/core/services/i_auth_service.dart';

class MockOrderRepository extends Mock implements IOrderRepository {}

class MockAuthService extends Mock implements IAuthService {}

void main() {
  group('OrderPage Accessibility Tests', () {
    late MockOrderRepository mockOrderRepository;
    late MockAuthService mockAuthService;

    setUp(() {
      mockOrderRepository = MockOrderRepository();
      mockAuthService = MockAuthService();
      when(() => mockAuthService.currentUserId).thenReturn('test_uid');
      when(
        () => mockOrderRepository.getBuyerOrdersStream(any()),
      ).thenAnswer((_) => Stream.value(<OrderModel>[]));
    });

    testWidgets('OrderPage meets tap target and semantics guidelines', (
      WidgetTester tester,
    ) async {
      final SemanticsHandle handle = tester.ensureSemantics();

      await tester.pumpWidget(
        MaterialApp(
          home: OrderPageUI(
            orderRepository: mockOrderRepository,
            authService: mockAuthService,
          ),
        ),
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
