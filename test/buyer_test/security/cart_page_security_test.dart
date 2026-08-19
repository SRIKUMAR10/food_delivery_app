import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:food_delivery_app/core/repositories/i_cart_repository.dart';
import 'package:food_delivery_app/core/repositories/i_coupon_repository.dart';
import 'package:food_delivery_app/core/repositories/i_product_repository.dart';
import 'package:food_delivery_app/core/services/i_auth_service.dart';
import 'package:food_delivery_app/core/services/seller_status_service.dart';
import 'package:food_delivery_app/features/buyer_bloc_architecture/Cart Page/cart_page.dart';

class MockCartRepository extends Mock implements ICartRepository {}
class MockCouponRepository extends Mock implements ICouponRepository {}
class MockProductRepository extends Mock implements IProductRepository {}
class MockAuthService extends Mock implements IAuthService {}
class MockSellerStatusService extends Mock implements SellerStatusService {}

void main() {
  group('Cart Security Tests', () {
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
    });

    blocTest<CartBloc, CartState>(
      'Denies access / Returns empty cart if user is not authenticated',
      build: () {
        when(() => mockAuthService.currentUserId).thenReturn(null);
        when(() => mockAuthService.authStateChanges).thenAnswer((_) => Stream<String?>.empty());
        when(() => mockAuthService.ensureTokenReady()).thenAnswer((_) async {});
        return CartBloc(cartRepository: mockCartRepository, couponRepository: mockCouponRepository, productRepository: mockProductRepository, authService: mockAuthService, sellerStatusService: mockSellerStatusService);
      },
      act: (bloc) => bloc.add(const LoadCartStarted()),
      expect: () => const [
        CartLoaded(items: [], totalAmount: 0.0, totalCount: 0),
      ],
    );
  });
}
