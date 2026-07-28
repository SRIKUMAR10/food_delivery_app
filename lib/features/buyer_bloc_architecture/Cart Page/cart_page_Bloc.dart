import 'dart:async';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/services/i_auth_service.dart';
import '../../../core/services/business_hours_validator.dart';
import '../../../core/repositories/i_cart_repository.dart';
import '../../../core/repositories/i_coupon_repository.dart';
import 'cart_models.dart';

part 'cart_page_Event.dart';
part 'cart_page_State.dart';

class CartBloc extends Bloc<CartEvent, CartState> {
  final ICartRepository _cartRepository;
  final ICouponRepository _couponRepository;
  final IAuthService _authService;

  StreamSubscription<String?>? _authSubscription;
  StreamSubscription<List<AppliedCoupon>>? _couponSubscription;

  CartBloc({
    required ICartRepository cartRepository,
    required ICouponRepository couponRepository,
    required IAuthService authService,
  })  : _cartRepository = cartRepository,
        _couponRepository = couponRepository,
        _authService = authService,
        super(const CartLoading()) {
    
    _authSubscription = _authService.authStateChanges.listen((userId) {
      if (userId != null) {
        add(const LoadCartStarted());
      } else {
        add(const CartCleared());
      }
    });

    on<LoadCartStarted>(_onLoadCartStarted);
    on<CartItemAdded>(_onCartItemAdded);
    on<CartItemRemoved>(_onCartItemRemoved);
    on<CartItemQuantityUpdated>(_onCartItemQuantityUpdated);
    on<CartItemSelectionToggled>(_onCartItemSelectionToggled);
    on<CartCleared>(_onCartCleared);
    on<CartCheckoutRequested>(_onCartCheckoutRequested);
    on<LoadAvailableCoupons>(_onLoadAvailableCoupons);
    on<_CouponsLoaded>(_onCouponsLoaded);
    on<CouponApplied>(_onCouponApplied);
    on<CouponRemoved>(_onCouponRemoved);
    on<CouponError>(_onCouponError);
  }

  @override
  Future<void> close() {
    _authSubscription?.cancel();
    _couponSubscription?.cancel();
    return super.close();
  }

  String? get _currentUserId => _authService.currentUserId;

  void _subscribeToCoupons(List<String> sellerIds) {
    _couponSubscription?.cancel();
    _couponSubscription = _couponRepository
        .getActiveCouponsBySellers(sellerIds)
        .map(
          (coupons) => coupons.map((c) => AppliedCoupon(
            code: c.code,
            sellerId: c.sellerId,
            discountAmount: c.discountAmount,
            isPercentage: c.isPercentage,
            couponId: c.id,
          )).toList(),
        )
        .listen((availableCoupons) {
      if (!isClosed) {
        add(_CouponsLoaded(availableCoupons));
      }
    });
  }

  Future<void> _onLoadCartStarted(
    LoadCartStarted event,
    Emitter<CartState> emit,
  ) async {
    final uid = _currentUserId;
    if (uid == null) {
      emit(const CartLoaded(items: [], totalAmount: 0, totalCount: 0));
      return;
    }

    emit(const CartLoading());

    try {
      await emit.forEach<List<CartItem>>(
        _cartRepository.getCartItemsStream(uid),
        onData: (items) {
          double totalAmount = 0.0;
          int totalCount = 0;
          for (final item in items) {
            if (item.isSelected) {
              totalAmount += (item.price * item.quantity);
              totalCount += item.quantity;
            }
          }

          final sellerIds = items.map((i) => i.sellerId).toSet().toList();
          if (sellerIds.isNotEmpty) {
            _subscribeToCoupons(sellerIds);
          }

          return CartLoaded(
            items: items,
            totalAmount: totalAmount,
            totalCount: totalCount,
          );
        },
        onError: (error, stackTrace) =>
            const CartLoaded(items: [], totalAmount: 0, totalCount: 0),
      );
    } catch (_) {
      emit(const CartLoaded(items: [], totalAmount: 0, totalCount: 0));
    }
  }

  Future<void> _onCartItemAdded(
    CartItemAdded event,
    Emitter<CartState> emit,
  ) async {
    final uid = _currentUserId;
    if (uid == null) return;
    try {
      await _cartRepository.addItem(uid, event.item);
    } catch (e) {
      // Emit error or log
    }
  }

  Future<void> _onCartItemRemoved(
    CartItemRemoved event,
    Emitter<CartState> emit,
  ) async {
    final uid = _currentUserId;
    if (uid == null) return;
    try {
      await _cartRepository.removeItem(uid, event.id);
    } catch (e) {
      // Emit error or log
    }
  }

  Future<void> _onCartItemQuantityUpdated(
    CartItemQuantityUpdated event,
    Emitter<CartState> emit,
  ) async {
    final uid = _currentUserId;
    if (uid == null) return;
    try {
      await _cartRepository.updateQuantity(uid, event.id, event.delta);
    } catch (e) {
      // Emit error or log
    }
  }

  Future<void> _onCartItemSelectionToggled(
    CartItemSelectionToggled event,
    Emitter<CartState> emit,
  ) async {
    final uid = _currentUserId;
    if (uid == null) return;
    try {
      await _cartRepository.toggleSelection(uid, event.id, event.isSelected);
    } catch (e) {
      // Emit error or log
    }
  }

  Future<void> _onCartCleared(
    CartCleared event,
    Emitter<CartState> emit,
  ) async {
    _couponSubscription?.cancel();
    _couponSubscription = null;

    final uid = _currentUserId;
    if (uid == null) {
      emit(const CartLoaded(items: [], totalAmount: 0, totalCount: 0));
      return;
    }
    try {
      await _cartRepository.clearCart(uid);
    } catch (e) {
      // Handle error
    }
  }

  Future<void> _onCartCheckoutRequested(
    CartCheckoutRequested event,
    Emitter<CartState> emit,
  ) async {
    final uid = _currentUserId;
    if (uid == null) return;

    try {
      final currentState = state;
      if (currentState is CartLoaded) {
        final selectedItems = currentState.items.where((i) => i.isSelected).toList();
        if (selectedItems.isEmpty) return;

        await _cartRepository.checkoutCart(
          uid, selectedItems, 'Customer',
          appliedCoupon: currentState.appliedCoupon,
        );
        
        if (event.onSuccess != null) {
          event.onSuccess!();
        }
      }
    } catch (e) {
      print("Checkout Error: $e");
    }
  }

  void _onLoadAvailableCoupons(
    LoadAvailableCoupons event,
    Emitter<CartState> emit,
  ) {
    _subscribeToCoupons(event.sellerIds);
  }

  void _onCouponsLoaded(
    _CouponsLoaded event,
    Emitter<CartState> emit,
  ) {
    if (state is CartLoaded) {
      emit((state as CartLoaded).copyWith(
        availableCoupons: event.coupons,
      ));
    }
  }

  void _onCouponApplied(
    CouponApplied event,
    Emitter<CartState> emit,
  ) {
    if (state is CartLoaded) {
      final current = state as CartLoaded;
      final discount = event.coupon.isPercentage
          ? ((current.totalAmount * event.coupon.discountAmount / 100).clamp(0, current.totalAmount) as double)
          : (event.coupon.discountAmount.clamp(0, current.totalAmount) as double);
      final finalAmount = current.totalAmount - discount;

      emit(current.copyWith(
        appliedCoupon: event.coupon,
        discountAmount: discount,
        finalAmount: finalAmount,
        couponMessage: 'Coupon applied! You save ₹${discount.toStringAsFixed(0)}',
        clearCouponMessage: false,
      ));
    }
  }

  void _onCouponRemoved(
    CouponRemoved event,
    Emitter<CartState> emit,
  ) {
    if (state is CartLoaded) {
      final current = state as CartLoaded;
      emit(current.copyWith(
        clearCoupon: true,
        discountAmount: 0,
        finalAmount: current.totalAmount,
        couponMessage: 'Coupon removed',
        clearCouponMessage: false,
      ));
    }
  }

  void _onCouponError(
    CouponError event,
    Emitter<CartState> emit,
  ) {
    if (state is CartLoaded) {
      emit((state as CartLoaded).copyWith(
        couponMessage: event.message,
        clearCouponMessage: false,
      ));
    }
  }
}

class _CouponsLoaded extends CartEvent {
  final List<AppliedCoupon> coupons;
  const _CouponsLoaded(this.coupons);

  @override
  List<Object?> get props => [coupons];
}
