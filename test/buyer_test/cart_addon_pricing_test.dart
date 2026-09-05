import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:food_delivery_app/features/buyer_bloc_architecture/Cart Page/cart_models.dart';
import 'package:food_delivery_app/features/buyer_bloc_architecture/Cart Page/cart_page_Bloc.dart';
import 'package:food_delivery_app/features/buyer_bloc_architecture/Cart Page/cart_page_UI.dart';
import 'package:food_delivery_app/core/repositories/i_cart_repository.dart';
import 'package:food_delivery_app/core/repositories/i_coupon_repository.dart';
import 'package:food_delivery_app/core/repositories/i_product_repository.dart';
import 'package:food_delivery_app/core/repositories/i_user_profile_repository.dart';
import 'package:food_delivery_app/core/services/i_auth_service.dart';
import 'package:mocktail/mocktail.dart';

class MockCartRepository extends Mock implements ICartRepository {}
class MockCouponRepository extends Mock implements ICouponRepository {}
class MockProductRepository extends Mock implements IProductRepository {}
class MockAuthService extends Mock implements IAuthService {}
class MockUserProfileRepository extends Mock implements IUserProfileRepository {}
class MockCartBloc extends Mock implements CartBloc {}

void main() {
  late MockCartRepository mockCartRepository;
  late MockCouponRepository mockCouponRepository;
  late MockProductRepository mockProductRepository;
  late MockAuthService mockAuthService;
  late MockUserProfileRepository mockUserProfileRepository;
  late CartBloc cartBloc;

  setUpAll(() {
    registerFallbackValue(const CartItem(id: '', name: '', price: 0, sellerId: ''));
  });

  setUp(() {
    mockCartRepository = MockCartRepository();
    mockCouponRepository = MockCouponRepository();
    mockProductRepository = MockProductRepository();
    mockAuthService = MockAuthService();
    mockUserProfileRepository = MockUserProfileRepository();

    when(() => mockAuthService.currentUserId).thenReturn('test_user_cart');
    when(() => mockAuthService.currentUserDisplayName).thenReturn('Test Buyer');
    when(() => mockAuthService.currentUserEmail).thenReturn('buyer@example.com');
    when(() => mockAuthService.authStateChanges).thenAnswer((_) => Stream.value('test_user_cart'));
    when(() => mockAuthService.ensureTokenReady()).thenAnswer((_) async {});

    when(() => mockUserProfileRepository.watchProfile(any())).thenAnswer((_) => const Stream.empty());
    when(() => mockUserProfileRepository.loadProfile(any())).thenAnswer((_) async => null);
    when(() => mockUserProfileRepository.watchWalletBalance(any())).thenAnswer((_) => const Stream.empty());

    when(() => mockCouponRepository.getActiveCouponsBySellers(any())).thenAnswer((_) => Stream.value([]));

    cartBloc = CartBloc(
      cartRepository: mockCartRepository,
      couponRepository: mockCouponRepository,
      productRepository: mockProductRepository,
      authService: mockAuthService,
      userProfileRepository: mockUserProfileRepository,
    );
  });

  tearDown(() {
    cartBloc.close();
  });

  final testCartItemWithAddons = CartItem(
    id: 'prod_burger_001_Large_ExtraMayo-ExtraCheese',
    productId: 'prod_burger_001',
    name: 'Gourmet Crispy Burger',
    price: 1485.0, // 1449 (Large) + 18 (Mayo) + 18 (Cheese)
    sellerId: 'seller_101',
    quantity: 1,
    isSelected: true,
    selectedVariantName: 'Large',
    selectedVariantPrice: 1449.0,
    selectedAddons: const ['Extra Mayo (+₹18)', 'Extra Cheese (+₹18)'],
    priceSnapshot: PriceSnapshot(
      basePrice: 1414.28,
      discountAmount: 120.0,
      taxableAmount: 1414.28,
      gstPercentage: 5.0,
      gstAmount: 70.72,
      cgstAmount: 35.36,
      sgstAmount: 35.36,
      roundOff: 0.0,
      finalPrice: 1485.0,
      capturedAt: DateTime.now(),
      taxStrategy: 'restaurantLevel',
    ),
  );

  group('CartBloc Add-on Price Snapshot & State Management', () {
    test('generateCartItemId generates deterministic ID for product, variant and sorted addons', () {
      final cartId = generateCartItemId(
        productId: 'prod_burger_001',
        variantName: 'Large',
        selectedAddons: ['Extra Cheese', 'Extra Mayo'],
      );
      expect(cartId, equals('prod_burger_001_Large_ExtraCheese-ExtraMayo'));
    });

    test('Loads cart item with variants and addons and computes subtotal correctly', () async {
      when(() => mockCartRepository.getCartItemsStream('test_user_cart'))
          .thenAnswer((_) => Stream.value([testCartItemWithAddons]));

      final expectedState = cartBloc.stream.firstWhere((state) => state is CartLoaded && state.items.isNotEmpty);

      cartBloc.add(const LoadCartStarted());

      final state = await expectedState as CartLoaded;
      expect(state.items.length, equals(1));
      expect(state.totalAmount, equals(1485.0));
      expect(state.totalCount, equals(1));
      expect(state.deliveryFee, equals(0.0)); // >= 500 free delivery
      expect(state.platformFee, equals(5.0));
      expect(state.finalAmount, greaterThan(1485.0));
    });
  });

  group('CartPageUI Widget Tests for Addons & Pricing', () {
    late MockCartBloc mockCartBloc;

    setUp(() {
      mockCartBloc = MockCartBloc();
      when(() => mockCartBloc.stream).thenAnswer((_) => const Stream.empty());
      when(() => mockCartBloc.close()).thenAnswer((_) async {});
    });

    testWidgets('Renders Cart item with Size: Large, + Extra Mayo, and + Extra Cheese', (tester) async {
      when(() => mockCartBloc.state).thenReturn(
        CartLoaded(
          items: [testCartItemWithAddons],
          totalAmount: 1485.0,
          totalCount: 1,
          finalAmount: 1564.25,
          deliveryFee: 0.0,
          taxAmount: 74.25,
          platformFee: 5.0,
          selectedPaymentMethod: CartPaymentMethod.razorpay,
        ),
      );

      await tester.pumpWidget(
        MultiRepositoryProvider(
          providers: [
            RepositoryProvider<IAuthService>.value(value: mockAuthService),
          ],
          child: BlocProvider<CartBloc>.value(
            value: mockCartBloc,
            child: const MaterialApp(
              home: CartPageUI(),
            ),
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Gourmet Crispy Burger'), findsOneWidget);
      expect(find.text('Size: Large'), findsOneWidget);
      expect(find.text('+ Extra Mayo (+₹18)'), findsOneWidget);
      expect(find.text('+ Extra Cheese (+₹18)'), findsOneWidget);
      expect(find.textContaining('1,485'), findsWidgets);
    });
  });
}
