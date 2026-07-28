// lib/Buyer Bloc Architecture/Cart Page/cart_page_State.dart
//
// Defines all the possible states of the Cart feature.

part of 'cart_page_Bloc.dart';

sealed class CartState extends Equatable {
  const CartState();

  @override
  List<Object?> get props => [];
}

/// The initial state when the cart is loading or hasn't been initialized yet.
class CartLoading extends CartState {
  const CartLoading();
}

/// The state when the cart is fully loaded and ready to be displayed.
class CartLoaded extends CartState {
  final List<CartItem> items;
  final double totalAmount;
  final int totalCount;
  final AppliedCoupon? appliedCoupon;
  final double discountAmount;
  final double finalAmount;
  final List<AppliedCoupon> availableCoupons;
  final String? couponMessage;

  const CartLoaded({
    this.items = const [],
    this.totalAmount = 0.0,
    this.totalCount = 0,
    this.appliedCoupon,
    this.discountAmount = 0.0,
    this.finalAmount = 0.0,
    this.availableCoupons = const [],
    this.couponMessage,
  });

  /// Creates a copy of this state with the specified fields replaced with the new values.
  CartLoaded copyWith({
    List<CartItem>? items,
    double? totalAmount,
    int? totalCount,
    AppliedCoupon? appliedCoupon,
    bool clearCoupon = false,
    double? discountAmount,
    double? finalAmount,
    List<AppliedCoupon>? availableCoupons,
    String? couponMessage,
    bool clearCouponMessage = false,
  }) {
    return CartLoaded(
      items: items ?? this.items,
      totalAmount: totalAmount ?? this.totalAmount,
      totalCount: totalCount ?? this.totalCount,
      appliedCoupon: clearCoupon ? null : (appliedCoupon ?? this.appliedCoupon),
      discountAmount: discountAmount ?? this.discountAmount,
      finalAmount: finalAmount ?? this.finalAmount,
      availableCoupons: availableCoupons ?? this.availableCoupons,
      couponMessage: clearCouponMessage ? null : (couponMessage ?? this.couponMessage),
    );
  }

  @override
  List<Object?> get props => [items, totalAmount, totalCount, appliedCoupon, discountAmount, finalAmount, availableCoupons, couponMessage];
}

/// A state representing an error that occurred during a cart operation.
class CartError extends CartState {
  final String message;
  final CartState? previousState;

  const CartError(this.message, {this.previousState});

  @override
  List<Object?> get props => [message, previousState];
}
