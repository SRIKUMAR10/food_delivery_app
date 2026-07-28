import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:food_delivery_app/core/repositories/i_cart_repository.dart';
import 'package:food_delivery_app/core/repositories/i_coupon_repository.dart';
import 'package:food_delivery_app/core/services/i_auth_service.dart';
import 'package:food_delivery_app/features/buyer_bloc_architecture/Cart%20Page/cart_page.dart';
import 'package:food_delivery_app/features/buyer_bloc_architecture/Cart%20Page/cart_models.dart';
import 'package:mocktail/mocktail.dart';

class MockCartRepository extends Mock implements ICartRepository {}
class MockCouponRepository extends Mock implements ICouponRepository {}
class MockAuthService extends Mock implements IAuthService {}

void main() {
  group('Cart Page Performance Test', () {
    testWidgets('Measures scrolling performance on Cart Page', (
      WidgetTester tester,
    ) async {
      final mockCartRepository = MockCartRepository();
      final mockCouponRepository = MockCouponRepository();
      final mockAuthService = MockAuthService();

      when(() => mockAuthService.currentUserId).thenReturn('test_uid');
      when(() => mockAuthService.authStateChanges).thenAnswer((_) => Stream<String?>.value('test_uid'));

      final items = List.generate(20, (i) => CartItem(
        id: 'item$i',
        name: 'Food Item $i',
        price: 10.0 + i,
        quantity: 1,
        sellerId: 'seller$i',
        isSelected: true,
      ));

      when(() => mockCartRepository.getCartItemsStream('test_uid'))
          .thenAnswer((_) => Stream.value(items));
      when(() => mockCouponRepository.getActiveCouponsBySellers(any()))
          .thenAnswer((_) => const Stream.empty());

      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider(
            create: (_) =>
                CartBloc(cartRepository: mockCartRepository, couponRepository: mockCouponRepository, authService: mockAuthService)
                  ..add(const LoadCartStarted()),
            child: const CartPageUI(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      final listFinder = find.byType(ListView);

      if (listFinder.evaluate().isNotEmpty) {
        final stopwatch = Stopwatch()..start();
        await tester.fling(listFinder, const Offset(0, -500), 10000);
        await tester.pumpAndSettle();
        stopwatch.stop();
        expect(stopwatch.elapsedMilliseconds, lessThan(1000));
      }
    });
  });
}
