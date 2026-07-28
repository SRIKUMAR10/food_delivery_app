import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:food_delivery_app/core/repositories/i_cart_repository.dart';
import 'package:food_delivery_app/core/repositories/i_coupon_repository.dart';
import 'package:food_delivery_app/core/services/i_auth_service.dart';
import 'package:food_delivery_app/features/buyer_bloc_architecture/Cart%20Page/cart_page_Bloc.dart';
import 'package:mocktail/mocktail.dart';

class MockCartRepository extends Mock implements ICartRepository {}
class MockCouponRepository extends Mock implements ICouponRepository {}
class MockAuthService extends Mock implements IAuthService {}

void main() {
  group('Cart Error Handling Tests', () {
    late MockCartRepository mockCartRepository;
    late MockCouponRepository mockCouponRepository;
    late MockAuthService mockAuthService;

    setUp(() {
      mockCartRepository = MockCartRepository();
      mockCouponRepository = MockCouponRepository();
      mockAuthService = MockAuthService();

      when(() => mockAuthService.currentUserId).thenReturn('user123');
      when(() => mockAuthService.authStateChanges).thenAnswer((_) => Stream<String?>.empty());
      when(() => mockCouponRepository.getActiveCouponsBySellers(any()))
          .thenAnswer((_) => const Stream.empty());
    });

    blocTest<CartBloc, CartState>(
      'Handles repository exception gracefully without crashing (emits empty or error)',
      build: () {
        when(() => mockCartRepository.getCartItemsStream('user123')).thenThrow(
          Exception('unavailable'),
        );
        return CartBloc(cartRepository: mockCartRepository, couponRepository: mockCouponRepository, authService: mockAuthService);
      },
      act: (bloc) => bloc.add(const LoadCartStarted()),
      expect: () => [
        const CartLoading(),
        const CartLoaded(items: [], totalAmount: 0, totalCount: 0),
      ],
    );
  });
}
