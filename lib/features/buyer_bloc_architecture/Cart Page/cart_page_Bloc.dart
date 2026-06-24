// lib/Buyer Bloc Architecture/Cart Page/cart_page_Bloc.dart
//
// The Business Logic Component (BLoC) for the Cart.
// Handles adding, removing, updating items, and calculating totals.

import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'cart_models.dart';

part 'cart_page_Event.dart';
part 'cart_page_State.dart';

class CartBloc extends Bloc<CartEvent, CartState> {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  StreamSubscription<User?>? _authSubscription;

  CartBloc({FirebaseFirestore? firestore, FirebaseAuth? auth})
    : _firestore = firestore ?? FirebaseFirestore.instance,
      _auth = auth ?? FirebaseAuth.instance,
      super(const CartLoading()) {
    _authSubscription = _auth.authStateChanges().listen((user) {
      add(const LoadCartStarted());
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

  /// Helper to get the current user's cart collection reference.
  CollectionReference<Map<String, dynamic>>? get _cartCollection {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return null;
    return _firestore.collection('users').doc(uid).collection('cart');
  }

  /// Initializes the cart state by streaming from Firestore.
  Future<void> _onLoadCartStarted(
    LoadCartStarted event,
    Emitter<CartState> emit,
  ) async {
    emit(const CartLoading());
    try {
      final cartRef = _cartCollection;
      if (cartRef == null) {
        emit(const CartLoaded(items: [], totalAmount: 0, totalCount: 0));
        return;
      }

      await emit.forEach<QuerySnapshot>(
        cartRef.snapshots(),
        onData: (snapshot) {
          final items = snapshot.docs
              .map((doc) => CartItem.fromFirestore(doc))
              .toList();

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
    } on FirebaseException catch (_) {
      emit(const CartLoaded(items: [], totalAmount: 0, totalCount: 0));
    } catch (_) {
      emit(const CartLoaded(items: [], totalAmount: 0, totalCount: 0));
    }
  }

  /// Adds a new item to the cart, or increments its quantity in Firestore.
  Future<void> _onCartItemAdded(
    CartItemAdded event,
    Emitter<CartState> emit,
  ) async {
    try {
      final cartRef = _cartCollection;
      if (cartRef == null) return;

      final docRef = cartRef.doc(event.item.id);

      await _firestore.runTransaction((transaction) async {
        final docSnapshot = await transaction.get(docRef);

        if (docSnapshot.exists) {
          final currentQuantity =
              (docSnapshot.data()?['quantity'] as num?)?.toInt() ?? 0;
          transaction.update(docRef, {
            'quantity': currentQuantity + event.item.quantity,
          });
        } else {
          transaction.set(docRef, event.item.toMap());
        }
      });
    } catch (e) {
      // Emit error or log
    }
  }

  /// Removes an item from the cart entirely.
  Future<void> _onCartItemRemoved(
    CartItemRemoved event,
    Emitter<CartState> emit,
  ) async {
    try {
      final cartRef = _cartCollection;
      if (cartRef == null) return;

      await cartRef.doc(event.id).delete();
    } catch (e) {
      // Emit error or log
    }
  }

  /// Updates the quantity of an item by a specific delta (e.g., +1 or -1).
  Future<void> _onCartItemQuantityUpdated(
    CartItemQuantityUpdated event,
    Emitter<CartState> emit,
  ) async {
    try {
      final cartRef = _cartCollection;
      if (cartRef == null) return;

      final docRef = cartRef.doc(event.id);

      await _firestore.runTransaction((transaction) async {
        final docSnapshot = await transaction.get(docRef);

        if (docSnapshot.exists) {
          final currentQuantity =
              (docSnapshot.data()?['quantity'] as num?)?.toInt() ?? 0;
          final newQuantity = currentQuantity + event.delta;

          if (newQuantity <= 0) {
            transaction.delete(docRef);
          } else {
            transaction.update(docRef, {'quantity': newQuantity});
          }
        }
      });
    } catch (e) {
      // Handle error
    }
  }

  /// Toggles the selection state of an item.
  Future<void> _onCartItemSelectionToggled(
    CartItemSelectionToggled event,
    Emitter<CartState> emit,
  ) async {
    try {
      final cartRef = _cartCollection;
      if (cartRef == null) return;

      final docRef = cartRef.doc(event.id);
      await docRef.update({'isSelected': event.isSelected});
    } catch (e) {
      // Handle error
    }
  }

  /// Clears all items from the cart.
  Future<void> _onCartCleared(
    CartCleared event,
    Emitter<CartState> emit,
  ) async {
    try {
      final cartRef = _cartCollection;
      if (cartRef == null) return;

      final snapshots = await cartRef.get();
      final batch = _firestore.batch();

      for (var doc in snapshots.docs) {
        batch.delete(doc.reference);
      }

      await batch.commit();
    } catch (e) {
      // Handle error
    }
  }

  /// Processes the checkout: creates an order in Firestore and clears the cart.
  Future<void> _onCartCheckoutRequested(
    CartCheckoutRequested event,
    Emitter<CartState> emit,
  ) async {
    try {
      final cartRef = _cartCollection;
      final uid = _auth.currentUser?.uid;
      if (cartRef == null || uid == null) return;

      final snapshots = await cartRef.get();
      if (snapshots.docs.isEmpty) return; // Empty cart

      final items = snapshots.docs
          .map((doc) => CartItem.fromFirestore(doc))
          .toList();
      final selectedItems = items.where((item) => item.isSelected).toList();

      if (selectedItems.isEmpty) return; // Nothing selected to checkout

      double totalAmount = 0.0;
      for (final item in selectedItems) {
        totalAmount += (item.price * item.quantity);
      }

      // Check user's wallet before proceeding
      final userRef = _firestore.collection('users').doc(uid);
      final userDoc = await userRef.get();
      double currentWallet =
          (userDoc.data()?['wallet'] as num?)?.toDouble() ?? 0.0;

      if (currentWallet < totalAmount) {
        if (event.onInsufficientBalance != null) {
          event.onInsufficientBalance!();
        }
        return;
      }

      // Create a new order in Firestore
      final orderRef = _firestore
          .collection('users')
          .doc(uid)
          .collection('orders')
          .doc();

      final orderData = {
        'status': 'Pending',
        'totalAmount': totalAmount,
        'date': FieldValue.serverTimestamp(),
        'items': selectedItems.map((item) => item.toMap()).toList(),
      };

      final batch = _firestore.batch();
      batch.set(orderRef, orderData);

      // Deduct from user's wallet
      batch.set(userRef, {
        'wallet': FieldValue.increment(-totalAmount),
      }, SetOptions(merge: true));

      // Record the debit transaction for the wallet history
      final transactionRef = userRef.collection('transactions').doc();
      batch.set(transactionRef, {
        'amount': totalAmount,
        'title': 'Order Payment',
        'isCredit': false,
        'status': 'success',
        'orderId': orderRef.id,
        'createdAt': FieldValue.serverTimestamp(),
        'timestamp': FieldValue.serverTimestamp(),
      });

      // Delete cart items
      for (var item in selectedItems) {
        batch.delete(cartRef.doc(item.id));
      }

      await batch.commit();

      if (event.onSuccess != null) {
        event.onSuccess!();
      }
    } catch (e) {
      // Handle error
    }
  }
}
