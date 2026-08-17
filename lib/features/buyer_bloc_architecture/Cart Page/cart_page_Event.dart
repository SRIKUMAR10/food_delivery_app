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

/// Dispatched when the user switches payment method (Razorpay, COD, Wallet).
class CartPaymentMethodSelected extends CartEvent {
  final CartPaymentMethod method;
  const CartPaymentMethodSelected(this.method);

  @override
  List<Object?> get props => [method];
}

/// Dispatched to trigger the checkout process (create order and clear cart).
class CartCheckoutRequested extends CartEvent {
  final void Function(String? message)? onSuccess;
  final void Function(String? message)? onInsufficientBalance;
  final void Function(String? orderId, double amount, String customerEmail, String customerPhone)? onOpenRazorpay;
  final void Function(String? message)? onFailure;

  const CartCheckoutRequested({
    this.onSuccess,
    this.onInsufficientBalance,
    this.onOpenRazorpay,
    this.onFailure,
  });
}

/// Dispatched when Razorpay client SDK returns payment success response.
class CartRazorpaySuccessReceived extends CartEvent {
  final PaymentSuccessResponse response;
  final void Function(String? message)? onSuccess;
  final void Function(String? message)? onFailure;

  const CartRazorpaySuccessReceived({
    required this.response,
    this.onSuccess,
    this.onFailure,
  });

  @override
  List<Object?> get props => [response.paymentId, response.orderId, response.signature];
}

/// Dispatched when Razorpay client SDK returns payment error or cancellation response.
class CartRazorpayFailedReceived extends CartEvent {
  final PaymentFailureResponse response;
  final void Function(String? message)? onFailure;

  const CartRazorpayFailedReceived({
    required this.response,
    this.onFailure,
  });

  @override
  List<Object?> get props => [response.code, response.message];
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

/// Dispatched when user enters a coupon code manually in the text field.
class ApplyCouponCodeRequested extends CartEvent {
  final String code;
  const ApplyCouponCodeRequested(this.code);

  @override
  List<Object?> get props => [code];
}

/// Dispatched when the user switches delivery address type (Home, Work, Other).
class DeliveryAddressTypeChanged extends CartEvent {
  final String addressType;
  const DeliveryAddressTypeChanged(this.addressType);

  @override
  List<Object?> get props => [addressType];
}

class _ProfileUpdated extends CartEvent {
  final dynamic profile;
  const _ProfileUpdated(this.profile);

  @override
  List<Object?> get props => [profile];
}

class _WalletBalanceUpdated extends CartEvent {
  final double balance;
  const _WalletBalanceUpdated(this.balance);

  @override
  List<Object?> get props => [balance];
}

