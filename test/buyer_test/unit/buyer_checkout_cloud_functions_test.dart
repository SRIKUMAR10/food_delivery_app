import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:food_delivery_app/core/repositories/i_cart_repository.dart';
import 'package:food_delivery_app/core/repositories/i_coupon_repository.dart';
import 'package:food_delivery_app/core/repositories/i_product_repository.dart';
import 'package:food_delivery_app/core/repositories/i_user_profile_repository.dart';
import 'package:food_delivery_app/core/services/i_auth_service.dart';
import 'package:food_delivery_app/core/services/seller_status_service.dart';
import 'package:food_delivery_app/core/models/product_model.dart';
import 'package:food_delivery_app/features/buyer_bloc_architecture/Cart%20Page/cart_models.dart';
import 'package:food_delivery_app/features/buyer_bloc_architecture/Cart%20Page/cart_page_Bloc.dart';

class MockCartRepository extends Mock implements ICartRepository {}
class MockCouponRepository extends Mock implements ICouponRepository {}
class MockProductRepository extends Mock implements IProductRepository {}
class MockAuthService extends Mock implements IAuthService {}
class MockSellerStatusService extends Mock implements SellerStatusService {}
class MockUserProfileRepository extends Mock implements IUserProfileRepository {}

void main() {
  late MockCartRepository mockCartRepo;
  late MockCouponRepository mockCouponRepo;
  late MockProductRepository mockProductRepo;
  late MockAuthService mockAuthService;
  late MockSellerStatusService mockSellerStatusService;
  late MockUserProfileRepository mockUserProfileRepo;
  late CartBloc cartBloc;

  final sampleCartItem = CartItem(
    id: 'prod_101',
    name: 'Spicy Chicken Burger',
    price: 199.0,
    quantity: 2,
    sellerId: 'seller_123',
    isSelected: true,
  );

  final sampleProduct = Product(
    id: 'prod_101',
    name: 'Spicy Chicken Burger',
    price: 199.0,
    sellerId: 'seller_123',
    availableStock: 10,
    status: ProductStatus.inStock,
    isActive: true,
    category: 'Burgers',
    description: 'Tasty burger',
    imageUrls: const [],
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
  );

  late StreamController<double?> walletStreamController;

  setUp(() {
    mockCartRepo = MockCartRepository();
    mockCouponRepo = MockCouponRepository();
    mockProductRepo = MockProductRepository();
    mockAuthService = MockAuthService();
    mockSellerStatusService = MockSellerStatusService();
    mockUserProfileRepo = MockUserProfileRepository();
    walletStreamController = StreamController<double?>.broadcast();

    when(() => mockAuthService.authStateChanges).thenAnswer((_) => const Stream.empty());
    when(() => mockAuthService.ensureTokenReady()).thenAnswer((_) async {});
    when(() => mockAuthService.currentUserId).thenReturn('buyer_user_123');
    when(() => mockAuthService.currentUserDisplayName).thenReturn('Karthik');
    when(() => mockAuthService.currentUserEmail).thenReturn('karthik@example.com');
    when(() => mockUserProfileRepo.loadProfile(any())).thenAnswer((_) async => null);
    when(() => mockUserProfileRepo.watchProfile(any())).thenAnswer((_) => const Stream.empty());
    when(() => mockUserProfileRepo.watchWalletBalance(any())).thenAnswer((_) => walletStreamController.stream);

    when(() => mockCartRepo.getCartItemsStream(any())).thenAnswer((_) => Stream.value([sampleCartItem]));
    when(() => mockCouponRepo.getActiveCouponsBySellers(any())).thenAnswer((_) => const Stream.empty());
    when(() => mockSellerStatusService.checkAvailability(any()))
        .thenAnswer((_) async => const SellerAvailability(isOnline: true, isOpen: true));
    when(() => mockProductRepo.getProduct(any(), any())).thenAnswer((_) async => sampleProduct);

    cartBloc = CartBloc(
      cartRepository: mockCartRepo,
      couponRepository: mockCouponRepo,
      productRepository: mockProductRepo,
      authService: mockAuthService,
      sellerStatusService: mockSellerStatusService,
      userProfileRepository: mockUserProfileRepo,
    );
  });

  tearDown(() {
    walletStreamController.close();
    cartBloc.close();
  });

  group('Buyer Checkout & Order Placement Tests', () {
    test('COD Checkout invokes checkoutCart and returns placedOrderId', () async {
      when(() => mockCartRepo.checkoutCart(
            any(),
            any(),
            any(),
            any(),
            customerPhone: any(named: 'customerPhone'),
            appliedCoupon: any(named: 'appliedCoupon'),
            paymentMethod: 'COD',
          )).thenAnswer((_) async => 'ORD-REAL-12345');

      cartBloc.add(const LoadCartStarted());
      await cartBloc.stream.firstWhere((s) => s is CartLoaded);

      cartBloc.add(const CartPaymentMethodSelected(CartPaymentMethod.cod));
      await cartBloc.stream.firstWhere((s) => s is CartLoaded && s.selectedPaymentMethod == CartPaymentMethod.cod);

      String? returnedOrderId;
      cartBloc.add(CartCheckoutRequested(
        onSuccess: (orderId) {
          returnedOrderId = orderId;
        },
      ));

      await expectLater(
        cartBloc.stream,
        emitsInOrder([
          predicate<CartState>((s) => s is CartLoaded && s.isCheckingOut),
          predicate<CartState>((s) => s is CartLoaded && !s.isCheckingOut),
        ]),
      );

      expect(returnedOrderId, equals('ORD-REAL-12345'));
      verify(() => mockCartRepo.checkoutCart(
            'buyer_user_123',
            any(),
            any(),
            any(),
            customerPhone: any(named: 'customerPhone'),
            appliedCoupon: any(named: 'appliedCoupon'),
            paymentMethod: 'COD',
          )).called(1);
    });

    test('FoodGo Wallet Checkout verifies balance, invokes checkoutCart, and returns placedOrderId', () async {
      when(() => mockCartRepo.checkoutCart(
            any(),
            any(),
            any(),
            any(),
            customerPhone: any(named: 'customerPhone'),
            appliedCoupon: any(named: 'appliedCoupon'),
            paymentMethod: 'Wallet',
          )).thenAnswer((_) async => 'ORD-WALLET-77777');

      cartBloc.add(const LoadCartStarted());
      await cartBloc.stream.firstWhere((s) => s is CartLoaded);

      cartBloc.add(const CartPaymentMethodSelected(CartPaymentMethod.wallet));
      await cartBloc.stream.firstWhere((s) => s is CartLoaded && s.selectedPaymentMethod == CartPaymentMethod.wallet);

      // Add wallet balance to stream
      walletStreamController.add(1000.0);
      await cartBloc.stream.firstWhere((s) => s is CartLoaded && s.walletBalance == 1000.0);

      String? returnedOrderId;
      cartBloc.add(CartCheckoutRequested(
        onSuccess: (orderId) {
          returnedOrderId = orderId;
        },
      ));

      await expectLater(
        cartBloc.stream,
        emitsInOrder([
          predicate<CartState>((s) => s is CartLoaded && s.isCheckingOut),
          predicate<CartState>((s) => s is CartLoaded && !s.isCheckingOut),
        ]),
      );

      expect(returnedOrderId, equals('ORD-WALLET-77777'));
      verify(() => mockCartRepo.checkoutCart(
            'buyer_user_123',
            any(),
            any(),
            any(),
            customerPhone: any(named: 'customerPhone'),
            appliedCoupon: any(named: 'appliedCoupon'),
            paymentMethod: 'Wallet',
          )).called(1);
    });

    test('Razorpay Payment verification invokes verifyAndCheckoutRazorpay and returns placedOrderId', () async {
      when(() => mockCartRepo.verifyAndCheckoutRazorpay(
            buyerId: any(named: 'buyerId'),
            razorpayOrderId: any(named: 'razorpayOrderId'),
            razorpayPaymentId: any(named: 'razorpayPaymentId'),
            razorpaySignature: any(named: 'razorpaySignature'),
            selectedItems: any(named: 'selectedItems'),
            customerName: any(named: 'customerName'),
            deliveryAddress: any(named: 'deliveryAddress'),
            customerPhone: any(named: 'customerPhone'),
            appliedCoupon: any(named: 'appliedCoupon'),
          )).thenAnswer((_) async => 'ORD-RZP-98765');

      cartBloc.add(const LoadCartStarted());
      await cartBloc.stream.firstWhere((s) => s is CartLoaded);

      String? returnedOrderId;
      final response = PaymentSuccessResponse('pay_123', 'order_456', 'sig_789', {});

      cartBloc.add(CartRazorpaySuccessReceived(
        response: response,
        onSuccess: (orderId) {
          returnedOrderId = orderId;
        },
      ));

      await expectLater(
        cartBloc.stream,
        emitsInOrder([
          predicate<CartState>((s) => s is CartLoaded && s.isCheckingOut),
          predicate<CartState>((s) => s is CartLoaded && !s.isCheckingOut),
        ]),
      );

      expect(returnedOrderId, equals('ORD-RZP-98765'));
      verify(() => mockCartRepo.verifyAndCheckoutRazorpay(
            buyerId: 'buyer_user_123',
            razorpayOrderId: 'order_456',
            razorpayPaymentId: 'pay_123',
            razorpaySignature: 'sig_789',
            selectedItems: any(named: 'selectedItems'),
            customerName: any(named: 'customerName'),
            deliveryAddress: any(named: 'deliveryAddress'),
            customerPhone: any(named: 'customerPhone'),
            appliedCoupon: any(named: 'appliedCoupon'),
          )).called(1);
    });
  });
}
