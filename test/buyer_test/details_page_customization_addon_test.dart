import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:food_delivery_app/core/models/product_model.dart';
import 'package:food_delivery_app/core/services/pricing_engine.dart';
import 'package:food_delivery_app/features/buyer_bloc_architecture/Details_Page/details_page_UI.dart';
import 'package:food_delivery_app/features/buyer_bloc_architecture/Details_Page/details_page_Bloc.dart';
import 'package:food_delivery_app/features/buyer_bloc_architecture/Details_Page/details_page_State.dart';
import 'package:food_delivery_app/features/buyer_bloc_architecture/Favorites_Page/favorites_bloc.dart';
import 'package:food_delivery_app/features/buyer_bloc_architecture/Favorites_Page/favorites_state.dart';
import 'package:food_delivery_app/features/buyer_bloc_architecture/Cart Page/cart_page_Bloc.dart';
import 'package:food_delivery_app/features/buyer_bloc_architecture/Cart Page/cart_models.dart';
import 'package:food_delivery_app/features/buyer_bloc_architecture/home_Page/home_page_models.dart';
import 'package:food_delivery_app/core/services/i_auth_service.dart';
import 'package:food_delivery_app/core/repositories/i_seller_repository.dart';
import 'package:mocktail/mocktail.dart';

class MockAuthService extends Mock implements IAuthService {}
class MockSellerRepository extends Mock implements ISellerRepository {}
class MockFavoritesBloc extends Mock implements FavoritesBloc {}
class MockCartBloc extends Mock implements CartBloc {}
class MockDetailsBloc extends Mock implements DetailsBloc {}

void main() {
  late MockAuthService mockAuthService;
  late MockSellerRepository mockSellerRepository;
  late MockFavoritesBloc mockFavoritesBloc;
  late MockCartBloc mockCartBloc;
  late MockDetailsBloc mockDetailsBloc;

  setUpAll(() {
    registerFallbackValue(const CartItem(id: '', name: '', price: 0, sellerId: ''));
  });

  setUp(() {
    mockAuthService = MockAuthService();
    mockSellerRepository = MockSellerRepository();
    mockFavoritesBloc = MockFavoritesBloc();
    mockCartBloc = MockCartBloc();
    mockDetailsBloc = MockDetailsBloc();

    when(() => mockAuthService.currentUserId).thenReturn('test_user_123');
    when(() => mockAuthService.currentUserDisplayName).thenReturn('Test Buyer');
    when(() => mockFavoritesBloc.state).thenReturn(const FavoritesLoaded(favoriteIds: {}, items: []));
    when(() => mockFavoritesBloc.stream).thenAnswer((_) => const Stream.empty());
    when(() => mockCartBloc.state).thenReturn(const CartLoaded());
    when(() => mockCartBloc.stream).thenAnswer((_) => const Stream.empty());
    when(() => mockDetailsBloc.state).thenReturn(const DetailsState(quantity: 1, currentRating: 4.8, averageRating: 4.8));
    when(() => mockDetailsBloc.stream).thenAnswer((_) => Stream.value(const DetailsState(quantity: 1, currentRating: 4.8, averageRating: 4.8)));
  });

  final testProductWithVariantsAndAddons = Product(
    id: 'prod_burger_001',
    name: 'Gourmet Crispy Burger',
    price: 1050.0,
    basePrice: 1000.0,
    gstPercentage: 5.0,
    discountPrice: 0.0,
    taxType: 'intraState',
    status: ProductStatus.inStock,
    sellerId: 'seller_101',
    description: 'Fresh artisanal burger with handcrafted patty and gourmet sauce.',
    variants: const [
      ProductVariant(
        id: 'var_large',
        name: 'Large',
        basePrice: 1500.0,
        discountPercentage: 8.0,
        gstPercentage: 5.0,
        taxType: 'intraState',
        stock: 25,
        isAvailable: true,
      ),
      ProductVariant(
        id: 'var_regular',
        name: 'Regular',
        basePrice: 1000.0,
        discountPercentage: 0.0,
        gstPercentage: 5.0,
        taxType: 'intraState',
        stock: 50,
        isAvailable: true,
      ),
    ],
    customizationGroups: const [
      ProductCustomizationGroup(
        groupName: 'Add_on',
        isRequired: false,
        minSelect: 0,
        maxSelect: 5,
        options: [
          ProductAddon(
            id: 'addon_mayo',
            name: 'Extra Mayo',
            basePrice: 20.0,
            discountPercentage: 25.0,
            gstPercentage: 5.0,
            taxType: 'intraState',
          ),
          ProductAddon(
            id: 'addon_cheese',
            name: 'Extra Cheese',
            basePrice: 35.0,
            discountPercentage: 0.0,
            gstPercentage: 5.0,
            taxType: 'intraState',
          ),
        ],
      ),
    ],
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
  );

  group('PricingEngine Mathematical Computations', () {
    test('Calculates Large variant with 8% discount (₹1500 base -> ₹1380 taxable)', () {
      final largeVariant = testProductWithVariantsAndAddons.variants.first;
      expect(largeVariant.name, equals('Large'));
      expect(largeVariant.basePrice, equals(1500.0));
      expect(largeVariant.discountPercentage, equals(8.0));
      expect(largeVariant.discountAmount, equals(120.0));
      expect(largeVariant.taxablePrice, equals(1380.0));
    });

    test('Calculates Extra Mayo with 25% discount (₹20 base -> ₹15 taxable) and Extra Cheese (₹35 taxable)', () {
      final mayo = testProductWithVariantsAndAddons.customizationGroups.first.options[0];
      final cheese = testProductWithVariantsAndAddons.customizationGroups.first.options[1];
      expect(mayo.name, equals('Extra Mayo'));
      expect(mayo.basePrice, equals(20.0));
      expect(mayo.discountPercentage, equals(25.0));
      expect(mayo.discountAmount, equals(5.0));
      expect(mayo.taxablePrice, equals(15.0));

      expect(cheese.name, equals('Extra Cheese'));
      expect(cheese.basePrice, equals(35.0));
      expect(cheese.taxablePrice, equals(35.0));
    });

    test('Calculates combined item breakdown accurately', () {
      final largeVariant = testProductWithVariantsAndAddons.variants.first;
      final addons = testProductWithVariantsAndAddons.customizationGroups.first.options;

      final breakdown = PricingEngine.calculateItemBreakdown(
        product: testProductWithVariantsAndAddons,
        selectedVariant: largeVariant,
        selectedAddons: addons,
      );

      // Base: 1380 taxable, Mayo: 15 taxable, Cheese: 35 taxable => Total Taxable = 1430.0
      expect(breakdown.totalTaxableAmount, equals(1430.0));
      expect(breakdown.totalDiscount, equals(125.0)); // 120 + 5
      expect(breakdown.addons.length, equals(2));
      expect(breakdown.addons[0].title, equals('Extra Mayo'));
      expect(breakdown.addons[0].taxableAmount, equals(15.0));
      expect(breakdown.addons[1].title, equals('Extra Cheese'));
      expect(breakdown.addons[1].taxableAmount, equals(35.0));
    });
  });

  group('DetailsPageUI Widget Rendering Tests', () {
    Widget createWidgetUnderTest() {
      final foodItem = FoodItem(
        id: testProductWithVariantsAndAddons.id,
        name: testProductWithVariantsAndAddons.name,
        price: testProductWithVariantsAndAddons.price,
        category: 'Burgers',
        description: testProductWithVariantsAndAddons.description,
        sellerId: testProductWithVariantsAndAddons.sellerId,
        variants: testProductWithVariantsAndAddons.variants,
        customizationGroups: testProductWithVariantsAndAddons.customizationGroups,
      );

      return MultiRepositoryProvider(
        providers: [
          RepositoryProvider<IAuthService>.value(value: mockAuthService),
          RepositoryProvider<ISellerRepository>.value(value: mockSellerRepository),
        ],
        child: MultiBlocProvider(
          providers: [
            BlocProvider<FavoritesBloc>.value(value: mockFavoritesBloc),
            BlocProvider<CartBloc>.value(value: mockCartBloc),
            BlocProvider<DetailsBloc>.value(value: mockDetailsBloc),
          ],
          child: MaterialApp(
            home: DetailsPageUI(
              id: testProductWithVariantsAndAddons.id,
              name: testProductWithVariantsAndAddons.name,
              price: testProductWithVariantsAndAddons.price,
              description: testProductWithVariantsAndAddons.description,
              sellerId: testProductWithVariantsAndAddons.sellerId,
              foodItem: foodItem,
              detailsBloc: mockDetailsBloc,
            ),
          ),
        ),
      );
    }

    testWidgets('Renders Product Variants / Sizes, Large with taxable price ₹1,380 and 8% off, and Add_on customization group', (tester) async {
      tester.view.physicalSize = const Size(1200, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Check Variants header
      expect(find.text('Product Variants / Sizes'), findsOneWidget);
      expect(find.text('Select your preferred portion size'), findsOneWidget);

      // Check Large Variant with ₹1,380 taxable price, strikethrough ₹1,500, and 8% off
      expect(find.text('Large'), findsAtLeastNWidgets(1));
      expect(find.text('₹1,380'), findsAtLeastNWidgets(1));
      expect(find.text('₹1,500'), findsAtLeastNWidgets(1));
      expect(find.text('8% off'), findsOneWidget);

      // Check Regular Variant with ₹1,000
      expect(find.text('Regular'), findsAtLeastNWidgets(1));
      expect(find.text('₹1,000'), findsAtLeastNWidgets(1));

      // Check Customization / Add-on Groups header
      expect(find.text('Customization / Add-on Groups'), findsOneWidget);
      expect(find.text('Add_on'), findsOneWidget);
      expect(find.text('Optional'), findsOneWidget);
      expect(find.text('Choose up to 5 options'), findsOneWidget);

      // Check Options Extra Mayo (+ ₹15, strikethrough ₹20, 25% off) and Extra Cheese (+ ₹35)
      expect(find.text('Extra Mayo'), findsOneWidget);
      expect(find.text('+ ₹15'), findsOneWidget);
      expect(find.text('₹20'), findsOneWidget);
      expect(find.text('25% off'), findsOneWidget);

      expect(find.text('Extra Cheese'), findsOneWidget);
      expect(find.text('+ ₹35'), findsOneWidget);
    });

    testWidgets('Tapping Extra Mayo and Extra Cheese toggles their selection state', (tester) async {
      tester.view.physicalSize = const Size(1200, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Tap on Extra Mayo
      await tester.tap(find.text('Extra Mayo'));
      await tester.pumpAndSettle();

      // Tap on Extra Cheese
      await tester.tap(find.text('Extra Cheese'));
      await tester.pumpAndSettle();

      // Verify that checkboxes are rendered
      expect(find.byIcon(Icons.check), findsNWidgets(2));
    });
  });
}
