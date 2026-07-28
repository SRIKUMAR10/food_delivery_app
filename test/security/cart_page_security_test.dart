import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:food_delivery_app/core/repositories/i_cart_repository.dart';
import 'package:food_delivery_app/core/repositories/i_coupon_repository.dart';
import 'package:food_delivery_app/core/services/i_auth_service.dart';
import 'package:food_delivery_app/features/buyer_bloc_architecture/Cart Page/cart_page.dart';

class MockCartRepository extends Mock implements ICartRepository {}
class MockCouponRepository extends Mock implements ICouponRepository {}
class MockAuthService extends Mock implements IAuthService {}

void main() {
  group('Cart Security Tests', () {
    late MockCartRepository mockCartRepository;
    late MockCouponRepository mockCouponRepository;
    late MockAuthService mockAuthService;

    setUp(() {
      mockCartRepository = MockCartRepository();
      mockCouponRepository = MockCouponRepository();
      mockAuthService = MockAuthService();
    });

    blocTest<CartBloc, CartState>(
      'Denies access / Returns empty cart if user is not authenticated',
      build: () {
        when(() => mockAuthService.currentUserId).thenReturn(null);
        when(() => mockAuthService.authStateChanges).thenAnswer((_) => Stream<String?>.empty());
        return CartBloc(cartRepository: mockCartRepository, couponRepository: mockCouponRepository, authService: mockAuthService);
      },
      act: (bloc) => bloc.add(const LoadCartStarted()),
      expect: () => const [
        CartLoaded(items: [], totalAmount: 0.0, totalCount: 0),
      ],
    );
  });
}
