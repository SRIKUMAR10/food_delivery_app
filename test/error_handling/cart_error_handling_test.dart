import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:food_delivery_app/core/repositories/i_cart_repository.dart';
import 'package:food_delivery_app/core/repositories/i_coupon_repository.dart';
import 'package:food_delivery_app/core/repositories/i_product_repository.dart';
import 'package:food_delivery_app/core/services/i_auth_service.dart';
import 'package:food_delivery_app/core/services/seller_status_service.dart';
import 'package:food_delivery_app/features/buyer_bloc_architecture/Cart%20Page/cart_page_Bloc.dart';
import 'package:mocktail/mocktail.dart';

class MockCartRepository extends Mock implements ICartRepository {}
class MockCouponRepository extends Mock implements ICouponRepository {}
class MockProductRepository extends Mock implements IProductRepository {}
class MockAuthService extends Mock implements IAuthService {}
class MockSellerStatusService extends Mock implements SellerStatusService {}

void main() {
  group('Cart Error Handling Tests', () {
    late MockCartRepository mockCartRepository;
    late MockCouponRepository mockCouponRepository;
    late MockProductRepository mockProductRepository;
    late MockAuthService mockAuthService;
    late MockSellerStatusService mockSellerStatusService;

    setUp(() {
      mockCartRepository = MockCartRepository();
      mockCouponRepository = MockCouponRepository();
      mockProductRepository = MockProductRepository();
      mockAuthService = MockAuthService();
      mockSellerStatusService = MockSellerStatusService();

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
        return CartBloc(cartRepository: mockCartRepository, couponRepository: mockCouponRepository, productRepository: mockProductRepository, authService: mockAuthService, sellerStatusService: mockSellerStatusService);
      },
      act: (bloc) => bloc.add(const LoadCartStarted()),
      expect: () => [
        const CartLoading(),
        const CartLoaded(items: [], totalAmount: 0, totalCount: 0),
      ],
    );
  });
}
