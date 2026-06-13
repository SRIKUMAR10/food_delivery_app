// test/cart_page/cart_page_bloc_test.dart

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import '../../lib/Buyer Bloc Architecture/Cart Page/cart_page.dart';

void main() {
  group('CartBloc Tests', () {
    final mockItem1 = CartItem(
      id: 'item1',
      name: 'Burger',
      price: 150.0,
      sellerId: 'seller1',
      quantity: 1,
    );

    final mockItem2 = CartItem(
      id: 'item2',
      name: 'Pizza',
      price: 300.0,
      sellerId: 'seller2',
      quantity: 2,
    );

    test('Initial state should be CartLoading', () {
      final bloc = CartBloc();
      expect(bloc.state, const CartLoading());
      bloc.close();
    });

    blocTest<CartBloc, CartState>(
      'LoadCartStarted emits CartLoaded',
      build: () => CartBloc(),
      act: (bloc) => bloc.add(const LoadCartStarted()),
      expect: () => [
        const CartLoaded(),
      ],
    );

    blocTest<CartBloc, CartState>(
      'CartItemAdded adds item to cart',
      build: () => CartBloc(),
      seed: () => const CartLoaded(),
      act: (bloc) => bloc.add(CartItemAdded(mockItem1)),
      expect: () => [
        CartLoaded(
          items: [mockItem1],
          totalAmount: 150.0,
          totalCount: 1,
        ),
      ],
    );

    blocTest<CartBloc, CartState>(
      'CartItemAdded increments quantity if item already exists',
      build: () => CartBloc(),
      seed: () => CartLoaded(
        items: [mockItem1],
        totalAmount: 150.0,
        totalCount: 1,
      ),
      act: (bloc) => bloc.add(CartItemAdded(mockItem1)),
      expect: () => [
        CartLoaded(
          items: [mockItem1.copyWith(quantity: 2)],
          totalAmount: 300.0,
          totalCount: 2,
        ),
      ],
    );

    blocTest<CartBloc, CartState>(
      'CartItemRemoved removes item completely',
      build: () => CartBloc(),
      seed: () => CartLoaded(
        items: [mockItem1, mockItem2],
        totalAmount: 750.0,
        totalCount: 3,
      ),
      act: (bloc) => bloc.add(const CartItemRemoved('item1')),
      expect: () => [
        CartLoaded(
          items: [mockItem2],
          totalAmount: 600.0,
          totalCount: 2,
        ),
      ],
    );

    blocTest<CartBloc, CartState>(
      'CartItemQuantityUpdated changes quantity',
      build: () => CartBloc(),
      seed: () => CartLoaded(
        items: [mockItem1],
        totalAmount: 150.0,
        totalCount: 1,
      ),
      act: (bloc) => bloc.add(const CartItemQuantityUpdated('item1', 1)),
      expect: () => [
        CartLoaded(
          items: [mockItem1.copyWith(quantity: 2)],
          totalAmount: 300.0,
          totalCount: 2,
        ),
      ],
    );

    blocTest<CartBloc, CartState>(
      'CartItemQuantityUpdated removes item if quantity reaches 0',
      build: () => CartBloc(),
      seed: () => CartLoaded(
        items: [mockItem1],
        totalAmount: 150.0,
        totalCount: 1,
      ),
      act: (bloc) => bloc.add(const CartItemQuantityUpdated('item1', -1)),
      expect: () => [
        const CartLoaded(
          items: [],
          totalAmount: 0.0,
          totalCount: 0,
        ),
      ],
    );

    blocTest<CartBloc, CartState>(
      'CartCleared removes all items',
      build: () => CartBloc(),
      seed: () => CartLoaded(
        items: [mockItem1, mockItem2],
        totalAmount: 750.0,
        totalCount: 3,
      ),
      act: (bloc) => bloc.add(const CartCleared()),
      expect: () => [
        const CartLoaded(),
      ],
    );
  });
}
