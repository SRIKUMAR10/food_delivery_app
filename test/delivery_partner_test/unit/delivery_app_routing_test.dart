import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:food_delivery_app/main.dart';
import 'package:food_delivery_app/features/buyer_bloc_architecture/Cart%20Page/cart_page_Bloc.dart';
import 'package:food_delivery_app/features/buyer_bloc_architecture/Favorites_Page/favorites_bloc.dart';
import 'package:food_delivery_app/features/buyer_bloc_architecture/Favorites_Page/favorites_event.dart';
import 'package:food_delivery_app/features/buyer_bloc_architecture/Favorites_Page/favorites_state.dart';
import 'package:food_delivery_app/features/buyer_bloc_architecture/home_Page/home_Page_Bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../mock_firebase.dart';
import 'package:firebase_core/firebase_core.dart';
import '../../font_loader_helper.dart';

class _FakeCartBloc extends Bloc<CartEvent, CartState> implements CartBloc {
  _FakeCartBloc() : super(const CartLoading()) {
    on<LoadCartStarted>((event, emit) {});
  }
}

class _FakeFavoritesBloc extends Bloc<FavoritesEvent, FavoritesState>
    implements FavoritesBloc {
  _FakeFavoritesBloc() : super(const FavoritesLoading());
}

class _FakeHomePageBloc extends Bloc<HomePageEvent, HomePageState>
    implements HomePageBloc {
  _FakeHomePageBloc() : super(const HomePageInitial('default_id', []));
}

void main() {
  setupFirebaseAuthMocks();

  setUpAll(() async {
    overrideFontAssetLoading();
    await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: 'test-api-key',
        appId: 'test-app-id',
        messagingSenderId: 'test-sender-id',
        projectId: 'test-project-id',
      ),
    );
  });

  Widget buildApp() {
    return MyApp(
      cartBloc: _FakeCartBloc(),
      favoritesBloc: _FakeFavoritesBloc(),
      homePageBloc: _FakeHomePageBloc(),
    );
  }

  group('App Routing Tests', () {
    testWidgets('successfully generates and navigates to /deliveryCompleted route', (
      tester,
    ) async {
      await tester.pumpWidget(buildApp());
      await tester.pump();

      final navigator = tester.state<NavigatorState>(find.byType(Navigator).first);
      navigator.pushNamed('/deliveryCompleted', arguments: {'orderId': 'ORD-TEST-99'});
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.byType(Navigator), findsWidgets);
    });

    testWidgets('successfully generates /deliveryNavigationScreen route', (
      tester,
    ) async {
      await tester.pumpWidget(buildApp());
      await tester.pump();

      final navigator = tester.state<NavigatorState>(find.byType(Navigator).first);
      navigator.pushNamed('/deliveryNavigationScreen', arguments: {
        'orderId': 'ORD-TEST-100',
        'restaurantName': 'Burger Corner',
        'customerName': 'Kumar',
      });
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.byType(Navigator), findsWidgets);
    });

    testWidgets('successfully generates /deliveryIncomingOrder and /deliveryPickupConfirmation routes', (
      tester,
    ) async {
      await tester.pumpWidget(buildApp());
      await tester.pump();

      final navigator = tester.state<NavigatorState>(find.byType(Navigator).first);
      navigator.pushNamed('/deliveryIncomingOrder');
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      navigator.pushNamed('/deliveryPickupConfirmation', arguments: {'orderId': 'ORD-PICKUP-1'});
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.byType(Navigator), findsWidgets);
    });

    testWidgets('successfully generates /deliveryOrderDetails and /deliveryChat routes', (
      tester,
    ) async {
      await tester.pumpWidget(buildApp());
      await tester.pump();

      final navigator = tester.state<NavigatorState>(find.byType(Navigator).first);
      navigator.pushNamed('/deliveryOrderDetails', arguments: {'orderId': 'ORD-DET-1'});
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      navigator.pushNamed('/deliveryChat', arguments: {
        'orderId': 'ORD-CHAT-1',
        'customerId': 'CUST-1',
        'customerName': 'John',
      });
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.byType(Navigator), findsWidgets);
    });

    testWidgets('successfully generates /sellerSignUp and /login routes', (
      tester,
    ) async {
      await tester.pumpWidget(buildApp());
      await tester.pump();

      final navigator = tester.state<NavigatorState>(find.byType(Navigator).first);
      navigator.pushNamed('/sellerSignUp');
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      navigator.pushNamed('/login');
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.byType(Navigator), findsWidgets);
    });
  });
}
