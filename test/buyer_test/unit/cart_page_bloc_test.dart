import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:food_delivery_app/core/repositories/i_cart_repository.dart';
import 'package:food_delivery_app/core/repositories/i_coupon_repository.dart';
import 'package:food_delivery_app/core/services/i_auth_service.dart';
import 'package:food_delivery_app/features/buyer_bloc_architecture/Cart%20Page/cart_page_Bloc.dart';
import 'package:food_delivery_app/features/buyer_bloc_architecture/Cart%20Page/cart_models.dart';

class MockCartRepository extends Mock implements ICartRepository {}
class MockCouponRepository extends Mock implements ICouponRepository {}
class MockAuthService extends Mock implements IAuthService {}

void main() {
  group('CartBloc Unit Tests', () {
    late MockCartRepository mockCartRepository;
    late MockCouponRepository mockCouponRepository;
    late MockAuthService mockAuthService;
    late CartBloc cartBloc;

    setUp(() {
      mockCartRepository = MockCartRepository();
      mockCouponRepository = MockCouponRepository();
      mockAuthService = MockAuthService();

      when(() => mockAuthService.currentUserId).thenReturn('test_uid');
      when(() => mockAuthService.authStateChanges).thenAnswer((_) => Stream<String?>.value('test_uid'));
      when(() => mockCartRepository.getCartItemsStream(any()))
          .thenAnswer((_) => const Stream.empty());
      when(() => mockCouponRepository.getActiveCouponsBySellers(any()))
          .thenAnswer((_) => const Stream.empty());

      cartBloc = CartBloc(cartRepository: mockCartRepository, couponRepository: mockCouponRepository, authService: mockAuthService);
    });

    tearDown(() {
      cartBloc.close();
    });

    test('initial state is CartLoading', () {
      expect(cartBloc.state, isA<CartLoading>());
    });

    test('adds an item to cart and loads it', () async {
      final item = CartItem(
        id: 'item1',
        name: 'Burger',
        price: 5.0,
        sellerId: 'seller1',
        image: 'img.png',
        quantity: 1,
      );

      cartBloc.add(CartItemAdded(item));
      await Future.delayed(const Duration(milliseconds: 100));

      verify(() => mockCartRepository.addItem('test_uid', item)).called(1);
    });

    test('checkout creates orders in root collection', () async {
      final item1 = CartItem(
        id: 'item1',
        name: 'Burger',
        price: 5.0,
        sellerId: 'seller1',
        image: 'img.png',
        quantity: 1,
        isSelected: true,
      );

      final item2 = CartItem(
        id: 'item2',
        name: 'Pizza',
        price: 10.0,
        sellerId: 'seller2',
        image: 'img2.png',
        quantity: 1,
        isSelected: true,
      );

      when(() => mockCartRepository.getCartItemsStream('test_uid'))
          .thenAnswer((_) => Stream.value([item1, item2]));
      when(() => mockCartRepository.checkoutCart(any(), any(), any()))
          .thenAnswer((_) async => {});

      cartBloc.close();
      cartBloc = CartBloc(cartRepository: mockCartRepository, couponRepository: mockCouponRepository, authService: mockAuthService);
      await Future.delayed(const Duration(milliseconds: 100));

      bool successCalled = false;

      cartBloc.add(CartCheckoutRequested(
        onSuccess: () {
          successCalled = true;
        }
      ));

      await Future.delayed(const Duration(milliseconds: 100));

      verify(() => mockCartRepository.checkoutCart('test_uid', any(), any())).called(1);
      expect(successCalled, true);
    });
  });
}
