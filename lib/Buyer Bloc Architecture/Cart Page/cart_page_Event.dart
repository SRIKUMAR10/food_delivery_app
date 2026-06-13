// lib/Buyer Bloc Architecture/Cart Page/cart_page_Event.dart
//
// Defines all the events that can be triggered within the Cart feature.

part of 'cart_page_Bloc.dart';

sealed class CartEvent extends Equatable {
  const CartEvent();

  @override
  List<Object?> get props => [];
}

/// Dispatched when the cart is initially loaded.
class LoadCartStarted extends CartEvent {
  const LoadCartStarted();
}

/// Dispatched when a new item is added to the cart.
class CartItemAdded extends CartEvent {
  final CartItem item;

  const CartItemAdded(this.item);

  @override
  List<Object?> get props => [item];
}

/// Dispatched when an item is completely removed from the cart.
class CartItemRemoved extends CartEvent {
  final String id;

  const CartItemRemoved(this.id);

  @override
  List<Object?> get props => [id];
}

/// Dispatched when the quantity of an item is incremented or decremented.
class CartItemQuantityUpdated extends CartEvent {
  final String id;
  final int delta; // Usually 1 or -1

  const CartItemQuantityUpdated(this.id, this.delta);

  @override
  List<Object?> get props => [id, delta];
}

/// Dispatched to clear all items from the cart (e.g. after successful checkout).
class CartCleared extends CartEvent {
  const CartCleared();
}

/// Dispatched to trigger the checkout process (create order and clear cart).
class CartCheckoutRequested extends CartEvent {
  final void Function()? onSuccess;
  final void Function()? onInsufficientBalance;

  const CartCheckoutRequested({this.onSuccess, this.onInsufficientBalance});
}
