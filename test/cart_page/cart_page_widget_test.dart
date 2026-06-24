// test/cart_page/cart_page_widget_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:food_delivery_app/features/buyer_bloc_architecture/Cart%20Page/cart_page.dart';

class FakeCartBloc extends Cubit<CartState> implements CartBloc {
  FakeCartBloc(super.initialState);

  @override
  void add(CartEvent event) {}

  @override
  void on<E extends CartEvent>(
    EventHandler<E, CartState> handler, {
    EventTransformer<E>? transformer,
  }) {
    // TODO: implement on
  }

  @override
  void onDone(CartEvent event, [Object? error, StackTrace? stackTrace]) {
    // TODO: implement onDone
  }

  @override
  void onEvent(CartEvent event) {
    // TODO: implement onEvent
  }

  @override
  void onTransition(Transition<CartEvent, CartState> transition) {
    // TODO: implement onTransition
  }
}

Widget _buildApp(CartState initialState) {
  return MaterialApp(
    home: BlocProvider<CartBloc>.value(
      value: FakeCartBloc(initialState),
      child: const CartPageUI(),
    ),
  );
}

void main() {
  group('CartPageUI Widget Tests', () {
    testWidgets('shows loading indicator when state is CartLoading', (
      tester,
    ) async {
      await tester.pumpWidget(_buildApp(const CartLoading()));
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('shows empty state when no items in cart', (tester) async {
      await tester.pumpWidget(_buildApp(const CartLoaded(items: [])));

      expect(find.text('Your cart is empty!'), findsOneWidget);
      expect(find.byType(ListView), findsNothing);
    });

    testWidgets('shows items and checkout button when cart has items', (
      tester,
    ) async {
      final mockItem = CartItem(
        id: 'item1',
        name: 'Delicious Burger',
        price: 150.0,
        sellerId: 'seller1',
        quantity: 2,
      );

      await tester.pumpWidget(
        _buildApp(
          CartLoaded(items: [mockItem], totalAmount: 300.0, totalCount: 2),
        ),
      );

      // Wait for animations
      await tester.pumpAndSettle();

      expect(find.text('Delicious Burger'), findsWidgets);
      expect(find.text('2'), findsWidgets); // quantity
      // Format checks
      expect(find.textContaining('300.00'), findsWidgets);
      expect(find.text('Checkout'), findsOneWidget);
    });
  });
}
