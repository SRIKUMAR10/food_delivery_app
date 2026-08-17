import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:food_delivery_app/api_service/RazorpayApiService.dart';
import 'package:food_delivery_app/core/models/product_model.dart';
import 'package:food_delivery_app/core/repositories/i_cart_repository.dart';
import 'package:food_delivery_app/core/repositories/i_coupon_repository.dart';
import 'package:food_delivery_app/core/repositories/i_product_repository.dart';
import 'package:food_delivery_app/core/services/i_auth_service.dart';
import 'package:food_delivery_app/core/services/seller_status_service.dart';
import 'package:food_delivery_app/features/buyer_bloc_architecture/Cart%20Page/cart_page_Bloc.dart';
import 'package:food_delivery_app/features/buyer_bloc_architecture/Cart%20Page/cart_models.dart';

class MockCartRepository extends Mock implements ICartRepository {}
class MockCouponRepository extends Mock implements ICouponRepository {}
class MockProductRepository extends Mock implements IProductRepository {}
class MockAuthService extends Mock implements IAuthService {}
class MockSellerStatusService extends Mock implements SellerStatusService {}
class MockRazorpayApiService extends Mock implements RazorpayApiService {}

void main() {
  group('CartBloc Unit Tests', () {
    late MockCartRepository mockCartRepository;
    late MockCouponRepository mockCouponRepository;
    late MockProductRepository mockProductRepository;
    late MockAuthService mockAuthService;
    late MockSellerStatusService mockSellerStatusService;
    late MockRazorpayApiService mockRazorpayApiService;
    late CartBloc cartBloc;

    setUp(() {
      mockCartRepository = MockCartRepository();
      mockCouponRepository = MockCouponRepository();
      mockProductRepository = MockProductRepository();
      mockAuthService = MockAuthService();
      mockSellerStatusService = MockSellerStatusService();
      mockRazorpayApiService = MockRazorpayApiService();

      when(() => mockAuthService.currentUserId).thenReturn('test_uid');
      when(() => mockAuthService.authStateChanges).thenAnswer((_) => Stream<String?>.value('test_uid'));
      when(() => mockAuthService.ensureTokenReady()).thenAnswer((_) async {});
      when(() => mockCartRepository.getCartItemsStream(any()))
          .thenAnswer((_) => const Stream.empty());
      when(() => mockCouponRepository.getActiveCouponsBySellers(any()))
          .thenAnswer((_) => const Stream.empty());

      cartBloc = CartBloc(
        cartRepository: mockCartRepository,
        couponRepository: mockCouponRepository,
        productRepository: mockProductRepository,
        authService: mockAuthService,
        sellerStatusService: mockSellerStatusService,
        razorpayApiService: mockRazorpayApiService,
      );
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

    test('switches payment method between razorpay, cod, and wallet', () async {
      final item = CartItem(
        id: 'item1',
        name: 'Burger',
        price: 100.0,
        sellerId: 'seller1',
        quantity: 1,
      );

      when(() => mockCartRepository.getCartItemsStream('test_uid'))
          .thenAnswer((_) => Stream.value([item]));

      cartBloc.close();
      cartBloc = CartBloc(
        cartRepository: mockCartRepository,
        couponRepository: mockCouponRepository,
        productRepository: mockProductRepository,
        authService: mockAuthService,
        sellerStatusService: mockSellerStatusService,
        razorpayApiService: mockRazorpayApiService,
      );

      await Future.delayed(const Duration(milliseconds: 100));

      // Default payment method is Razorpay
      expect((cartBloc.state as CartLoaded).selectedPaymentMethod, CartPaymentMethod.razorpay);

      // Select COD
      cartBloc.add(const CartPaymentMethodSelected(CartPaymentMethod.cod));
      await Future.delayed(const Duration(milliseconds: 50));
      expect((cartBloc.state as CartLoaded).selectedPaymentMethod, CartPaymentMethod.cod);

      // Select Wallet
      cartBloc.add(const CartPaymentMethodSelected(CartPaymentMethod.wallet));
      await Future.delayed(const Duration(milliseconds: 50));
      expect((cartBloc.state as CartLoaded).selectedPaymentMethod, CartPaymentMethod.wallet);
    });

    test('checkout with COD creates order with paymentMethod COD', () async {
      final item = CartItem(
        id: 'item1',
        name: 'Burger',
        price: 100.0,
        sellerId: 'seller1',
        quantity: 1,
        isSelected: true,
      );

      when(() => mockCartRepository.getCartItemsStream('test_uid'))
          .thenAnswer((_) => Stream.value([item]));
      when(() => mockCartRepository.checkoutCart(
        any(),
        any(),
        any(),
        any(),
        customerPhone: any(named: 'customerPhone'),
        appliedCoupon: any(named: 'appliedCoupon'),
        paymentMethod: any(named: 'paymentMethod'),
      )).thenAnswer((_) async => {});

      when(() => mockSellerStatusService.checkAvailability(any())).thenAnswer(
        (_) async => const SellerAvailability(isOnline: true, isOpen: true),
      );
      final now = DateTime.now();
      when(() => mockProductRepository.getProduct('item1', 'seller1')).thenAnswer(
        (_) async => Product(
          id: 'item1',
          name: 'Burger',
          price: 100.0,
          status: ProductStatus.inStock,
          isActive: true,
          isArchived: false,
          availableStock: 10,
          createdAt: now,
          updatedAt: now,
        ),
      );

      cartBloc.close();
      cartBloc = CartBloc(
        cartRepository: mockCartRepository,
        couponRepository: mockCouponRepository,
        productRepository: mockProductRepository,
        authService: mockAuthService,
        sellerStatusService: mockSellerStatusService,
        razorpayApiService: mockRazorpayApiService,
      );
      await Future.delayed(const Duration(milliseconds: 100));

      cartBloc.add(const CartPaymentMethodSelected(CartPaymentMethod.cod));
      await Future.delayed(const Duration(milliseconds: 50));

      bool successCalled = false;
      cartBloc.add(CartCheckoutRequested(
        onSuccess: (_) {
          successCalled = true;
        }
      ));

      await Future.delayed(const Duration(milliseconds: 100));

      verify(() => mockCartRepository.checkoutCart(
        'test_uid',
        any(),
        any(),
        any(),
        customerPhone: any(named: 'customerPhone'),
        appliedCoupon: any(named: 'appliedCoupon'),
        paymentMethod: 'COD',
      )).called(1);
      expect(successCalled, true);
    });

    test('calculates correct subtotal, delivery fee, tax, and grand total', () async {
      final item = CartItem(
        id: 'item1',
        name: 'Burger',
        price: 200.0,
        sellerId: 'seller1',
        image: 'img.png',
        quantity: 2,
        isSelected: true,
      );

      when(() => mockCartRepository.getCartItemsStream('test_uid'))
          .thenAnswer((_) => Stream.value([item]));

      cartBloc.close();
      cartBloc = CartBloc(
        cartRepository: mockCartRepository,
        couponRepository: mockCouponRepository,
        productRepository: mockProductRepository,
        authService: mockAuthService,
        sellerStatusService: mockSellerStatusService,
        razorpayApiService: mockRazorpayApiService,
      );

      await Future.delayed(const Duration(milliseconds: 100));

      final state = cartBloc.state as CartLoaded;
      expect(state.totalAmount, 400.0); // 200 * 2
      expect(state.deliveryFee, 35.0); // Subtotal < 500
      expect(state.taxAmount, 20.0); // 5% of 400
      expect(state.platformFee, 5.0);
      expect(state.finalAmount, 460.0); // 400 + 35 + 20 + 5
    });

    test('applies coupon code and provides free delivery above 500 threshold', () async {
      final item = CartItem(
        id: 'item1',
        name: 'Burger',
        price: 300.0,
        sellerId: 'seller1',
        image: 'img.png',
        quantity: 2,
        isSelected: true,
      );

      when(() => mockCartRepository.getCartItemsStream('test_uid'))
          .thenAnswer((_) => Stream.value([item]));

      cartBloc.close();
      cartBloc = CartBloc(
        cartRepository: mockCartRepository,
        couponRepository: mockCouponRepository,
        productRepository: mockProductRepository,
        authService: mockAuthService,
        sellerStatusService: mockSellerStatusService,
        razorpayApiService: mockRazorpayApiService,
      );

      await Future.delayed(const Duration(milliseconds: 100));

      // Subtotal = 600 -> delivery fee is free (0.0)
      cartBloc.add(const CouponApplied(AppliedCoupon(
        code: 'SAVE50',
        sellerId: 'seller1',
        discountAmount: 50.0,
        isPercentage: false,
        couponId: 'c1',
      )));

      await Future.delayed(const Duration(milliseconds: 50));

      final state = cartBloc.state as CartLoaded;
      expect(state.totalAmount, 600.0);
      expect(state.discountAmount, 50.0);
      expect(state.deliveryFee, 0.0); // Free above 500
      expect(state.taxAmount, 27.5); // 5% of (600 - 50 = 550)
      expect(state.platformFee, 5.0);
      expect(state.finalAmount, 582.5); // 550 + 0 + 27.5 + 5
    });

    test('switches delivery address type in state', () async {
      final item = CartItem(
        id: 'item1',
        name: 'Burger',
        price: 100.0,
        sellerId: 'seller1',
        quantity: 1,
      );

      when(() => mockCartRepository.getCartItemsStream('test_uid'))
          .thenAnswer((_) => Stream.value([item]));

      cartBloc.close();
      cartBloc = CartBloc(
        cartRepository: mockCartRepository,
        couponRepository: mockCouponRepository,
        productRepository: mockProductRepository,
        authService: mockAuthService,
        sellerStatusService: mockSellerStatusService,
        razorpayApiService: mockRazorpayApiService,
      );

      await Future.delayed(const Duration(milliseconds: 100));

      cartBloc.add(const DeliveryAddressTypeChanged('Work'));
      await Future.delayed(const Duration(milliseconds: 50));

      final state = cartBloc.state as CartLoaded;
      expect(state.selectedAddressType, 'Work');
    });
  });
}
