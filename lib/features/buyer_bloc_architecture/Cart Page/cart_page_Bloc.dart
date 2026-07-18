// lib/Buyer Bloc Architecture/Cart Page/cart_page_Bloc.dart
//
// The Business Logic Component (BLoC) for the Cart.
// Handles adding, removing, updating items, and calculating totals.

import 'dart:async';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/services/i_auth_service.dart';
import '../../../core/repositories/i_cart_repository.dart';
import 'cart_models.dart';

part 'cart_page_Event.dart';
part 'cart_page_State.dart';

class CartBloc extends Bloc<CartEvent, CartState> {
  final ICartRepository _cartRepository;
  final IAuthService _authService;

  StreamSubscription<String?>? _authSubscription;

  CartBloc({
    required ICartRepository cartRepository,
    required IAuthService authService,
  })  : _cartRepository = cartRepository,
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
  }

  @override
  Future<void> close() {
    _authSubscription?.cancel();
    return super.close();
  }

  String? get _currentUserId => _authService.currentUserId;

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
      // Note: customerName could be retrieved via another service or usecase.
      // For now, passing a placeholder or getting it if the state holds it.
      // We will pass 'Customer' since the old code did a firestore read here.
      // Alternatively, the UI should provide it, but to match existing behavior:
      
      final currentState = state;
      if (currentState is CartLoaded) {
        final selectedItems = currentState.items.where((i) => i.isSelected).toList();
        if (selectedItems.isEmpty) return;

        await _cartRepository.checkoutCart(uid, selectedItems, 'Customer');
        
        if (event.onSuccess != null) {
          event.onSuccess!();
        }
      }
    } catch (e) {
      print("Checkout Error: $e");
    }
  }
}
