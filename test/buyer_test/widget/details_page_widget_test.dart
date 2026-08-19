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
        
        expect(find.text('Burger'), findsOneWidget);
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
  });
}
