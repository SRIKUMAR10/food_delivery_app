import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/services/i_auth_service.dart';
import '../../../core/services/seller_status_service.dart';
import '../../../core/repositories/i_cart_repository.dart';
import '../../../core/repositories/i_coupon_repository.dart';
import '../../../core/repositories/i_product_repository.dart';
import 'cart_models.dart';

part 'cart_page_Event.dart';
part 'cart_page_State.dart';

class CartBloc extends Bloc<CartEvent, CartState> {
  final ICartRepository _cartRepository;
  final ICouponRepository _couponRepository;
  final IProductRepository _productRepository;
  final IAuthService _authService;
  final SellerStatusService _sellerStatusService;

  StreamSubscription<String?>? _authSubscription;
  StreamSubscription<List<AppliedCoupon>>? _couponSubscription;

  CartBloc({
    required ICartRepository cartRepository,
    required ICouponRepository couponRepository,
    required IProductRepository productRepository,
    required IAuthService authService,
    SellerStatusService? sellerStatusService,
  })  : _cartRepository = cartRepository,
        _couponRepository = couponRepository,
        _productRepository = productRepository,
        _authService = authService,
        _sellerStatusService = sellerStatusService ?? SellerStatusService(),
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

          final currentState = state;
          if (currentState is CartLoaded) {
            double discountAmount = 0.0;
            double finalAmount = totalAmount;
            
            if (currentState.appliedCoupon != null) {
              final coupon = currentState.appliedCoupon!;
              discountAmount = coupon.isPercentage
                  ? (totalAmount * coupon.discountAmount / 100).clamp(0, totalAmount) as double
                  : coupon.discountAmount.clamp(0, totalAmount) as double;
              finalAmount = totalAmount - discountAmount;
            }

            return currentState.copyWith(
              items: items,
              totalAmount: totalAmount,
              totalCount: totalCount,
              discountAmount: discountAmount,
              finalAmount: finalAmount,
            );
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
      final currentState = state;
      if (currentState is CartLoaded && event.item.quantity > 0) {
        final product = await _productRepository.getProduct(event.item.id, event.item.sellerId);
        if (product != null) {
          if (!product.isActive || product.isArchived) {
            emit(_cartErrorWithPrevious(currentState, '${event.item.name} is currently unavailable.'));
            return;
          }
          if (product.availableStock < event.item.quantity) {
            emit(_cartErrorWithPrevious(currentState, '${event.item.name} only has ${product.availableStock} in stock.'));
            return;
          }
        }
      }
      await _cartRepository.addItem(uid, event.item);
    } catch (e) {
      if (state is CartLoaded) {
        emit(_cartErrorWithPrevious(state as CartLoaded, 'Failed to add item to cart.'));
      }
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
      if (state is CartLoaded) {
        emit(_cartErrorWithPrevious(state as CartLoaded, 'Failed to remove item.'));
      }
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
      if (state is CartLoaded) {
        emit(_cartErrorWithPrevious(state as CartLoaded, 'Failed to update quantity.'));
      }
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
      if (state is CartLoaded) {
        emit(_cartErrorWithPrevious(state as CartLoaded, 'Failed to update selection.'));
      }
    }
  }

  CartError _cartErrorWithPrevious(CartLoaded previous, String message) {
    return CartError(message, previousState: previous);
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
      if (state is CartLoaded) {
        emit(_cartErrorWithPrevious(state as CartLoaded, 'Failed to clear cart.'));
      }
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
      if (currentState is! CartLoaded) return;

      final selectedItems = currentState.items.where((i) => i.isSelected).toList();
      if (selectedItems.isEmpty) return;

      final sellerIds = selectedItems.map((i) => i.sellerId).toSet().toList();
      for (final sellerId in sellerIds) {
        final availability = await _sellerStatusService.checkAvailability(sellerId);
        if (!availability.isAvailable) {
          final msg = !availability.isOnline
              ? 'Store is currently offline.'
              : (availability.message ?? 'Store is currently closed.');
          emit(currentState.copyWith(
            couponMessage: msg,
            clearCouponMessage: false,
          ));
          if (event.onInsufficientBalance != null) {
            event.onInsufficientBalance!(msg);
          }
          return;
        }
      }

      List<String> validationErrors = [];
      for (final item in selectedItems) {
        final product = await _productRepository.getProduct(item.id, item.sellerId);
        if (product == null) {
          validationErrors.add('${item.name} is no longer available.');
          continue;
        }
        if (!product.isActive || product.isArchived) {
          validationErrors.add('${item.name} is currently disabled.');
          continue;
        }
        if (product.availableStock < item.quantity) {
          validationErrors.add('${item.name} only has ${product.availableStock} in stock (you requested ${item.quantity}).');
          continue;
        }
        if (product.effectivePrice != item.price) {
          await _cartRepository.updateItemPrice(uid, item.id, product.effectivePrice);
          validationErrors.add('${item.name} price has been automatically updated from ₹${item.price.toStringAsFixed(0)} to ₹${product.effectivePrice.toStringAsFixed(0)}.');
          continue;
        }
      }

      if (validationErrors.isNotEmpty) {
        final msg = validationErrors.join('\n');
        emit(currentState.copyWith(
          couponMessage: msg,
          clearCouponMessage: false,
        ));
        if (event.onInsufficientBalance != null) {
          event.onInsufficientBalance!(msg);
        }
        return;
      }

      await _cartRepository.checkoutCart(
        uid, selectedItems, 'Customer',
        appliedCoupon: currentState.appliedCoupon,
      );

      if (event.onSuccess != null) {
        event.onSuccess!(null);
      }
    } catch (e) {
      debugPrint("Checkout Error: $e");
      if (state is CartLoaded) {
        emit((state as CartLoaded).copyWith(
          couponMessage: 'Checkout failed. Please try again.',
          clearCouponMessage: false,
        ));
      }
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
