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

enum CartPaymentMethod { razorpay, cod, wallet }

/// The state when the cart is fully loaded and ready to be displayed.
class CartLoaded extends CartState {
  final List<CartItem> items;
  final double totalAmount;
  final int totalCount;
  final AppliedCoupon? appliedCoupon;
  final double discountAmount;
  final double deliveryFee;
  final double taxAmount;
  final double platformFee;
  final double finalAmount;
  final List<AppliedCoupon> availableCoupons;
  final String? couponMessage;
  final bool isCouponLoading;
  final String selectedAddressType;
  final String deliveryAddress;
  final String homeAddress;
  final String workAddress;
  final String otherAddress;
  final String customerName;
  final String customerPhone;
  final CartPaymentMethod selectedPaymentMethod;
  final bool isCheckingOut;
  final double walletBalance;
  final String? paymentError;

  const CartLoaded({
    this.items = const [],
    this.totalAmount = 0.0,
    this.totalCount = 0,
    this.appliedCoupon,
    this.discountAmount = 0.0,
    this.deliveryFee = 0.0,
    this.taxAmount = 0.0,
    this.platformFee = 0.0,
    this.finalAmount = 0.0,
    this.availableCoupons = const [],
    this.couponMessage,
    this.isCouponLoading = false,
    this.selectedAddressType = 'Home',
    this.deliveryAddress = '',
    this.homeAddress = '',
    this.workAddress = '',
    this.otherAddress = '',
    this.customerName = '',
    this.customerPhone = '',
    this.selectedPaymentMethod = CartPaymentMethod.razorpay,
    this.isCheckingOut = false,
    this.walletBalance = 0.0,
    this.paymentError,
  });

  /// Creates a copy of this state with the specified fields replaced with the new values.
  CartLoaded copyWith({
    List<CartItem>? items,
    double? totalAmount,
    int? totalCount,
    AppliedCoupon? appliedCoupon,
    bool clearCoupon = false,
    double? discountAmount,
    double? deliveryFee,
    double? taxAmount,
    double? platformFee,
    double? finalAmount,
    List<AppliedCoupon>? availableCoupons,
    String? couponMessage,
    bool clearCouponMessage = false,
    bool? isCouponLoading,
    String? selectedAddressType,
    String? deliveryAddress,
    String? homeAddress,
    String? workAddress,
    String? otherAddress,
    String? customerName,
    String? customerPhone,
    CartPaymentMethod? selectedPaymentMethod,
    bool? isCheckingOut,
    double? walletBalance,
    String? paymentError,
    bool clearPaymentError = false,
  }) {
    return CartLoaded(
      items: items ?? this.items,
      totalAmount: totalAmount ?? this.totalAmount,
      totalCount: totalCount ?? this.totalCount,
      appliedCoupon: clearCoupon ? null : (appliedCoupon ?? this.appliedCoupon),
      discountAmount: discountAmount ?? this.discountAmount,
      deliveryFee: deliveryFee ?? this.deliveryFee,
      taxAmount: taxAmount ?? this.taxAmount,
      platformFee: platformFee ?? this.platformFee,
      finalAmount: finalAmount ?? this.finalAmount,
      availableCoupons: availableCoupons ?? this.availableCoupons,
      couponMessage: clearCouponMessage ? null : (couponMessage ?? this.couponMessage),
      isCouponLoading: isCouponLoading ?? this.isCouponLoading,
      selectedAddressType: selectedAddressType ?? this.selectedAddressType,
      deliveryAddress: deliveryAddress ?? this.deliveryAddress,
      homeAddress: homeAddress ?? this.homeAddress,
      workAddress: workAddress ?? this.workAddress,
      otherAddress: otherAddress ?? this.otherAddress,
      customerName: customerName ?? this.customerName,
      customerPhone: customerPhone ?? this.customerPhone,
      selectedPaymentMethod: selectedPaymentMethod ?? this.selectedPaymentMethod,
      isCheckingOut: isCheckingOut ?? this.isCheckingOut,
      walletBalance: walletBalance ?? this.walletBalance,
      paymentError: clearPaymentError ? null : (paymentError ?? this.paymentError),
    );
  }

  @override
  List<Object?> get props => [
        items,
        totalAmount,
        totalCount,
        appliedCoupon,
        discountAmount,
        deliveryFee,
        taxAmount,
        platformFee,
        finalAmount,
        availableCoupons,
        couponMessage,
        isCouponLoading,
        selectedAddressType,
        deliveryAddress,
        homeAddress,
        workAddress,
        otherAddress,
        customerName,
        customerPhone,
        selectedPaymentMethod,
        isCheckingOut,
        walletBalance,
        paymentError,
      ];
}

/// A state representing an error that occurred during a cart operation.
class CartError extends CartState {
  final String message;
  final CartState? previousState;

  const CartError(this.message, {this.previousState});

  @override
  List<Object?> get props => [message, previousState];
}
