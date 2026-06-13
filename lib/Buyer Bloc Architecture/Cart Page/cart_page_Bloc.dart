// lib/Buyer Bloc Architecture/Cart Page/cart_page_Bloc.dart
//
// The Business Logic Component (BLoC) for the Cart.
// Handles adding, removing, updating items, and calculating totals.

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'cart_models.dart';

part 'cart_page_Event.dart';
part 'cart_page_State.dart';

class CartBloc extends Bloc<CartEvent, CartState> {
  CartBloc() : super(const CartLoading()) {
    on<LoadCartStarted>(_onLoadCartStarted);
    on<CartItemAdded>(_onCartItemAdded);
    on<CartItemRemoved>(_onCartItemRemoved);
    on<CartItemQuantityUpdated>(_onCartItemQuantityUpdated);
    on<CartCleared>(_onCartCleared);
  }

  /// Initializes the cart state.
  void _onLoadCartStarted(
    LoadCartStarted event,
    Emitter<CartState> emit,
  ) {
    // Currently, the cart is purely in-memory.
    // If we wanted to load from Firestore, we would fetch data here.
    emit(const CartLoaded());
  }

  /// Adds a new item to the cart, or increments its quantity if it already exists.
  void _onCartItemAdded(
    CartItemAdded event,
    Emitter<CartState> emit,
  ) {
    if (state is! CartLoaded) return;
    final currentState = state as CartLoaded;

    final List<CartItem> updatedItems = List.from(currentState.items);
    final existingIndex = updatedItems.indexWhere((i) => i.id == event.item.id);

    if (existingIndex != -1) {
      final existingItem = updatedItems[existingIndex];
      updatedItems[existingIndex] = existingItem.copyWith(
        quantity: existingItem.quantity + event.item.quantity,
      );
    } else {
      updatedItems.add(event.item);
    }

    _emitUpdatedCart(emit, updatedItems);
  }

  /// Removes an item from the cart entirely, regardless of its quantity.
  void _onCartItemRemoved(
    CartItemRemoved event,
    Emitter<CartState> emit,
  ) {
    if (state is! CartLoaded) return;
    final currentState = state as CartLoaded;

    final List<CartItem> updatedItems = List.from(currentState.items)
      ..removeWhere((i) => i.id == event.id);

    _emitUpdatedCart(emit, updatedItems);
  }

  /// Updates the quantity of an item by a specific delta (e.g., +1 or -1).
  /// If the quantity reaches zero, the item is removed.
  void _onCartItemQuantityUpdated(
    CartItemQuantityUpdated event,
    Emitter<CartState> emit,
  ) {
    if (state is! CartLoaded) return;
    final currentState = state as CartLoaded;

    final List<CartItem> updatedItems = List.from(currentState.items);
    final index = updatedItems.indexWhere((i) => i.id == event.id);

    if (index != -1) {
      final existingItem = updatedItems[index];
      final newQuantity = existingItem.quantity + event.delta;

      if (newQuantity <= 0) {
        updatedItems.removeAt(index);
      } else {
        updatedItems[index] = existingItem.copyWith(quantity: newQuantity);
      }

      _emitUpdatedCart(emit, updatedItems);
    }
  }

  /// Clears all items from the cart.
  void _onCartCleared(
    CartCleared event,
    Emitter<CartState> emit,
  ) {
    _emitUpdatedCart(emit, const []);
  }

  /// Helper function to calculate totals and emit the new CartLoaded state.
  void _emitUpdatedCart(Emitter<CartState> emit, List<CartItem> items) {
    double totalAmount = 0.0;
    int totalCount = 0;

    for (final item in items) {
      totalAmount += (item.price * item.quantity);
      totalCount += item.quantity;
    }

    emit(CartLoaded(
      items: items,
      totalAmount: totalAmount,
      totalCount: totalCount,
    ));
  }
}
