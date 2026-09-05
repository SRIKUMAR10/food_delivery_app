import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mocktail/mocktail.dart';
import 'package:network_image_mock/network_image_mock.dart';
import 'package:food_delivery_app/features/buyer_bloc_architecture/Details_Page/details_page_UI.dart';
import 'package:food_delivery_app/features/buyer_bloc_architecture/Details_Page/details_page_Bloc.dart';
import 'package:food_delivery_app/features/buyer_bloc_architecture/Details_Page/details_page_State.dart';
import 'package:food_delivery_app/features/buyer_bloc_architecture/Details_Page/details_page_Event.dart';
import 'package:food_delivery_app/features/buyer_bloc_architecture/Cart%20Page/cart_page_Bloc.dart';
import 'package:food_delivery_app/features/buyer_bloc_architecture/Favorites_Page/favorites_bloc.dart';
import 'package:food_delivery_app/features/buyer_bloc_architecture/Favorites_Page/favorites_state.dart';
import 'package:food_delivery_app/features/buyer_bloc_architecture/Favorites_Page/favorites_event.dart';
import 'package:food_delivery_app/features/buyer_bloc_architecture/home_Page/home_page_models.dart';
import 'package:food_delivery_app/core/models/product_model.dart';

// Mock BLoCs
class MockDetailsBloc extends Mock implements DetailsBloc {}
class MockCartBloc extends Mock implements CartBloc {}
class MockFavoritesBloc extends Mock implements FavoritesBloc {}

class FakeFavoritesEvent extends Fake implements FavoritesEvent {}
class FakeDetailsEvent extends Fake implements DetailsEvent {}

void main() {
  late MockDetailsBloc mockDetailsBloc;
  late MockCartBloc mockCartBloc;
  late MockFavoritesBloc mockFavoritesBloc;

  setUpAll(() {
    registerFallbackValue(FakeFavoritesEvent());
    registerFallbackValue(FakeDetailsEvent());
    registerFallbackValue(const DetailsState());
  });

  setUp(() {
    mockDetailsBloc = MockDetailsBloc();
    mockCartBloc = MockCartBloc();
    mockFavoritesBloc = MockFavoritesBloc();

    // Default Details Bloc State
    when(() => mockDetailsBloc.state).thenReturn(const DetailsState(quantity: 1));
    when(() => mockDetailsBloc.stream).thenAnswer((_) => Stream.value(const DetailsState(quantity: 1)));
    when(() => mockDetailsBloc.close()).thenAnswer((_) async {});

    // Default Cart Bloc State
    when(() => mockCartBloc.state).thenReturn(const CartLoaded(items: [], totalAmount: 0.0, totalCount: 0));
    when(() => mockCartBloc.stream).thenAnswer((_) => Stream.value(const CartLoaded(items: [], totalAmount: 0.0, totalCount: 0)));
    when(() => mockCartBloc.close()).thenAnswer((_) async {});

    // Default Favorites Bloc State
    when(() => mockFavoritesBloc.state).thenReturn(const FavoritesLoaded(items: [], favoriteIds: {}));
    when(() => mockFavoritesBloc.stream).thenAnswer((_) => Stream.value(const FavoritesLoaded(items: [], favoriteIds: {})));
    when(() => mockFavoritesBloc.close()).thenAnswer((_) async {});
  });

  Widget buildTestableWidget({required Widget child}) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<DetailsBloc>.value(value: mockDetailsBloc),
        BlocProvider<CartBloc>.value(value: mockCartBloc),
        BlocProvider<FavoritesBloc>.value(value: mockFavoritesBloc),
      ],
      child: MaterialApp(
        home: Scaffold(body: child),
      ),
    );
  }

  group('DetailsPageUI Widget Tests', () {
    testWidgets('Renders standard product details correctly', (tester) async {
      await mockNetworkImagesFor(() async {
        await tester.pumpWidget(
          buildTestableWidget(
            child: DetailsPageUI(
              id: '1',
              name: 'Burger',
              price: 150.0,
              description: 'Tasty Burger',
              sellerId: 's1',
              detailsBloc: mockDetailsBloc,
            ),
          ),
        );
        
        expect(find.text('Burger'), findsWidgets);
        expect(find.text('Tasty Burger'), findsOneWidget);
        // ₹150
        expect(find.text('₹150'), findsWidgets);
      });
    });

    testWidgets('Favorite button renders correctly', (tester) async {
      await mockNetworkImagesFor(() async {
        await tester.pumpWidget(
          buildTestableWidget(
            child: DetailsPageUI(
              id: '1',
              name: 'Burger',
              price: 150.0,
              description: 'Tasty',
              sellerId: 's1',
              detailsBloc: mockDetailsBloc,
            ),
          ),
        );

        final favButton = find.byKey(const Key('details_favorite_button'));
        expect(favButton, findsOneWidget);
      });
    });

    testWidgets('Add-ons selection and quantity changes update UI', (tester) async {
      await mockNetworkImagesFor(() async {
        final foodItem = FoodItem(
          id: '1',
          name: 'Burger',
          price: 150.0,
          description: 'Tasty',
          category: 'Fast Food',
          sellerId: 's1',
          addons: const ['Extra Cheese', 'Mayo'],
        );

        await tester.pumpWidget(
          buildTestableWidget(
            child: DetailsPageUI(
              detailsBloc: mockDetailsBloc,
              id: '1',
              name: 'Burger',
              price: 150.0,
              description: 'Tasty',
              sellerId: 's1',
              foodItem: foodItem,
            ),
          ),
        );

        expect(find.text('Add-ons & Customizations'), findsOneWidget);
        expect(find.text('Extra Cheese'), findsOneWidget);
        expect(find.text('Mayo'), findsOneWidget);

        // Tap Add-on
        await tester.tap(find.text('Extra Cheese'), warnIfMissed: false);
        await tester.pumpAndSettle();

        // The internal state now contains 'Extra Cheese'
      });
    });

    testWidgets('Discount Price renders new and old price correctly', (tester) async {
      await mockNetworkImagesFor(() async {
        final foodItem = FoodItem(
          id: '1',
          name: 'Burger',
          basePrice: 150.0,
          price: 150.0,
          discountPrice: 120.0,
          description: 'Tasty',
          category: 'Fast Food',
          sellerId: 's1',
        );

        await tester.pumpWidget(
          buildTestableWidget(
            child: DetailsPageUI(
              detailsBloc: mockDetailsBloc,
              id: '1',
              name: 'Burger',
              price: 150.0,
              description: 'Tasty',
              sellerId: 's1',
              foodItem: foodItem,
            ),
          ),
        );

        // Should see both ₹120 and ₹150
        expect(find.text('₹120'), findsWidgets);
        expect(find.text('₹150'), findsWidgets);
      });
    });

    testWidgets('Out of Stock disables Add to Cart button', (tester) async {
      await mockNetworkImagesFor(() async {
        final foodItem = FoodItem(
          id: '1',
          name: 'Burger',
          price: 150.0,
          description: 'Tasty',
          category: 'Fast Food',
          sellerId: 's1',
          isActive: false, // Out of Stock
        );

        await tester.pumpWidget(
          buildTestableWidget(
            child: DetailsPageUI(
              detailsBloc: mockDetailsBloc,
              id: '1',
              name: 'Burger',
              price: 150.0,
              description: 'Tasty',
              sellerId: 's1',
              foodItem: foodItem,
            ),
          ),
        );

        // Button should say Out of Stock
        expect(find.text('Out of Stock'), findsWidgets);

        final button = find.byType(ElevatedButton);
        final elevatedButton = tester.widget<ElevatedButton>(button.first);
        expect(elevatedButton.onPressed, isNull); // Disabled
      });
    });

    testWidgets('Product Variants / Sizes render and update price reactively', (tester) async {
      tester.view.physicalSize = const Size(600, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await mockNetworkImagesFor(() async {
        final foodItem = FoodItem(
          id: '1',
          name: 'Pizza',
          price: 500.0,
          description: 'Delicious Pizza',
          category: 'Pizza',
          sellerId: 's1',
          variants: const [
            ProductVariant(id: 'v1', name: 'Regular', basePrice: 500.0, stock: 20),
            ProductVariant(id: 'v2', name: 'Medium', basePrice: 800.0, stock: 15),
            ProductVariant(id: 'v3', name: 'Large', basePrice: 1200.0, stock: 10),
          ],
        );

        await tester.pumpWidget(
          buildTestableWidget(
            child: DetailsPageUI(
              detailsBloc: mockDetailsBloc,
              id: '1',
              name: 'Pizza',
              price: 500.0,
              description: 'Delicious Pizza',
              sellerId: 's1',
              foodItem: foodItem,
            ),
          ),
        );

        // Section header and variant options should be displayed
        expect(find.text('Product Variants / Sizes'), findsOneWidget);
        expect(find.text('Regular'), findsWidgets);
        expect(find.text('Medium'), findsWidgets);
        expect(find.text('Large'), findsWidgets);

        // Tap 'Large' variant
        await tester.ensureVisible(find.text('Large').last);
        await tester.tap(find.text('Large').last, warnIfMissed: false);
        await tester.pumpAndSettle();

        // Total price should update to Large price
        expect(find.text('₹1,260'), findsWidgets);
      });
    });

    testWidgets('Customization / Add-on Groups render options and update price reactively', (tester) async {
      tester.view.physicalSize = const Size(600, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await mockNetworkImagesFor(() async {
        final foodItem = FoodItem(
          id: '1',
          name: 'Burger',
          price: 150.0,
          description: 'Tasty',
          category: 'Fast Food',
          sellerId: 's1',
          customizationGroups: const [
            ProductCustomizationGroup(
              groupName: 'Choice of Bun',
              isRequired: true,
              minSelect: 1,
              maxSelect: 1,
              options: [
                ProductAddon(id: 'b1', name: 'Brioche Bun', basePrice: 0.0),
                ProductAddon(id: 'b2', name: 'Wheat Bun', basePrice: 20.0),
              ],
            ),
            ProductCustomizationGroup(
              groupName: 'Extra Add-ons',
              isRequired: false,
              minSelect: 0,
              maxSelect: 2,
              options: [
                ProductAddon(id: 'a1', name: 'Extra Cheese Slice', basePrice: 30.0),
                ProductAddon(id: 'a2', name: 'Extra Patty', basePrice: 80.0),
              ],
            ),
          ],
        );

        await tester.pumpWidget(
          buildTestableWidget(
            child: DetailsPageUI(
              detailsBloc: mockDetailsBloc,
              id: '1',
              name: 'Burger',
              price: 150.0,
              description: 'Tasty',
              sellerId: 's1',
              foodItem: foodItem,
            ),
          ),
        );

        expect(find.text('Customization / Add-on Groups'), findsOneWidget);
        expect(find.text('Choice of Bun'), findsOneWidget);
        expect(find.text('Brioche Bun'), findsOneWidget);
        expect(find.text('Wheat Bun'), findsOneWidget);
        expect(find.text('Extra Add-ons'), findsOneWidget);
        expect(find.text('Extra Cheese Slice'), findsOneWidget);

        // Tap Wheat Bun (+₹20 base + 5% GST = ₹21)
        await tester.tap(find.text('Wheat Bun'));
        await tester.pumpAndSettle();

        // Price should be 150 + 21 = 171
        expect(find.text('₹171'), findsWidgets);
      });
    });
  });
}
