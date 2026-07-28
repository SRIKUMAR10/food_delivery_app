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

/// Dispatched when the selection state of an item is toggled.
class CartItemSelectionToggled extends CartEvent {
  final String id;
  final bool isSelected;

  const CartItemSelectionToggled(this.id, this.isSelected);

  @override
  List<Object?> get props => [id, isSelected];
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

/// Dispatched when available coupons should be loaded for sellers in cart.
class LoadAvailableCoupons extends CartEvent {
  final List<String> sellerIds;
  const LoadAvailableCoupons(this.sellerIds);

  @override
  List<Object?> get props => [sellerIds];
}

/// Dispatched when user applies a coupon code.
class CouponApplied extends CartEvent {
  final AppliedCoupon coupon;
  const CouponApplied(this.coupon);

  @override
  List<Object?> get props => [coupon];
}

/// Dispatched when user removes an applied coupon.
class CouponRemoved extends CartEvent {
  const CouponRemoved();
}

/// Dispatched when a coupon validation error occurs.
class CouponError extends CartEvent {
  final String message;
  const CouponError(this.message);

  @override
  List<Object?> get props => [message];
}
