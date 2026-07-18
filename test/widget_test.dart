// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';
import 'package:food_delivery_app/features/buyer_bloc_architecture/Cart%20Page/cart_page.dart';
import 'package:food_delivery_app/features/buyer_bloc_architecture/Favorites_Page/favorites_bloc.dart';
import 'package:food_delivery_app/repositories/product_repository.dart';
import 'package:mocktail/mocktail.dart';

import 'package:food_delivery_app/main.dart';

import 'package:firebase_core/firebase_core.dart';
import './mock_firebase.dart';

import 'package:food_delivery_app/features/buyer_bloc_architecture/Favorites_Page/favorites_event.dart';
import 'package:food_delivery_app/features/buyer_bloc_architecture/Favorites_Page/favorites_state.dart';
import 'package:food_delivery_app/features/buyer_bloc_architecture/home_Page/home_Page_Bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class MockProductRepository extends Mock implements ProductRepository {}

class FakeCartBloc extends Bloc<CartEvent, CartState> implements CartBloc {
  FakeCartBloc() : super(const CartLoading()) {
    on<LoadCartStarted>((event, emit) {});
  }
}

class FakeFavoritesBloc extends Bloc<FavoritesEvent, FavoritesState>
    implements FavoritesBloc {
  FakeFavoritesBloc() : super(const FavoritesLoading());
}

class FakeHomePageBloc extends Bloc<HomePageEvent, HomePageState>
    implements HomePageBloc {
  FakeHomePageBloc() : super(const HomePageInitial('default_id', []));
}

void main() {
  setupFirebaseAuthMocks();

  setUpAll(() async {
    await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: 'test-api-key',
        appId: 'test-app-id',
        messagingSenderId: 'test-sender-id',
        projectId: 'test-project-id',
      ),
    );
  });

  testWidgets('Onboarding page smoke test', (WidgetTester tester) async {
    final fakeCartBloc = FakeCartBloc();
    final fakeFavoritesBloc = FakeFavoritesBloc();
    final fakeHomePageBloc = FakeHomePageBloc();

    // Build our app and trigger a frame.
    await tester.pumpWidget(
      MyApp(
        cartBloc: fakeCartBloc,
        favoritesBloc: fakeFavoritesBloc,
        homePageBloc: fakeHomePageBloc,
      ),
    );
    await tester.pumpAndSettle();

    // Verify that onboarding elements are displayed.
    // Note: If main.dart has home: SellerAddProductScreen(), this will fail.
    // Make sure to set home: const OnboardingPage() in main.dart to pass this test.
    expect(find.text('Get Started'), findsOneWidget);
    expect(find.text('The Fastest\nFood Delivery'), findsOneWidget);
  });
}
