// lib/Buyer Bloc Architecture/Cart Page/cart_page_Bloc.dart
//
// The Business Logic Component (BLoC) for the Cart.
// Handles adding, removing, updating items, and calculating totals.

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

  CartBloc({FirebaseFirestore? firestore, FirebaseAuth? auth}) 
      : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance,
        super(const CartLoading()) {
    on<LoadCartStarted>(_onLoadCartStarted);
    on<CartItemAdded>(_onCartItemAdded);
    on<CartItemRemoved>(_onCartItemRemoved);
    on<CartItemQuantityUpdated>(_onCartItemQuantityUpdated);
    on<CartCleared>(_onCartCleared);
    on<CartCheckoutRequested>(_onCartCheckoutRequested);
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
    final cartRef = _cartCollection;
    if (cartRef == null) {
      // If no user is logged in, we emit an empty cart
      emit(const CartLoaded(items: [], totalAmount: 0, totalCount: 0));
      return;
    }

    emit(const CartLoading());

    await emit.forEach<QuerySnapshot>(
      cartRef.snapshots(),
      onData: (snapshot) {
        final items = snapshot.docs.map((doc) => CartItem.fromFirestore(doc)).toList();
        
        double totalAmount = 0.0;
        int totalCount = 0;
        for (final item in items) {
          totalAmount += (item.price * item.quantity);
          totalCount += item.quantity;
        }

        return CartLoaded(
          items: items,
          totalAmount: totalAmount,
          totalCount: totalCount,
        );
      },
      onError: (error, stackTrace) => const CartLoaded(items: [], totalAmount: 0, totalCount: 0),
    );
  }

  /// Adds a new item to the cart, or increments its quantity in Firestore.
  Future<void> _onCartItemAdded(
    CartItemAdded event,
    Emitter<CartState> emit,
  ) async {
    final cartRef = _cartCollection;
    if (cartRef == null) return;

    final docRef = cartRef.doc(event.item.id);
    
    await _firestore.runTransaction((transaction) async {
      final docSnapshot = await transaction.get(docRef);

      if (docSnapshot.exists) {
        final currentQuantity = (docSnapshot.data()?['quantity'] as num?)?.toInt() ?? 0;
        transaction.update(docRef, {'quantity': currentQuantity + event.item.quantity});
      } else {
        transaction.set(docRef, event.item.toMap());
      }
    });
  }

  /// Removes an item from the cart entirely.
  Future<void> _onCartItemRemoved(
    CartItemRemoved event,
    Emitter<CartState> emit,
  ) async {
    final cartRef = _cartCollection;
    if (cartRef == null) return;

    await cartRef.doc(event.id).delete();
  }

  /// Updates the quantity of an item by a specific delta (e.g., +1 or -1).
  Future<void> _onCartItemQuantityUpdated(
    CartItemQuantityUpdated event,
    Emitter<CartState> emit,
  ) async {
    final cartRef = _cartCollection;
    if (cartRef == null) return;

    final docRef = cartRef.doc(event.id);

    await _firestore.runTransaction((transaction) async {
      final docSnapshot = await transaction.get(docRef);

      if (docSnapshot.exists) {
        final currentQuantity = (docSnapshot.data()?['quantity'] as num?)?.toInt() ?? 0;
        final newQuantity = currentQuantity + event.delta;

        if (newQuantity <= 0) {
          transaction.delete(docRef);
        } else {
          transaction.update(docRef, {'quantity': newQuantity});
        }
      }
    });
  }

  /// Clears all items from the cart.
  Future<void> _onCartCleared(
    CartCleared event,
    Emitter<CartState> emit,
  ) async {
    final cartRef = _cartCollection;
    if (cartRef == null) return;

    final snapshots = await cartRef.get();
    final batch = _firestore.batch();

    for (var doc in snapshots.docs) {
      batch.delete(doc.reference);
    }

    await batch.commit();
  }

  /// Processes the checkout: creates an order in Firestore and clears the cart.
  Future<void> _onCartCheckoutRequested(
    CartCheckoutRequested event,
    Emitter<CartState> emit,
  ) async {
    final cartRef = _cartCollection;
    final uid = _auth.currentUser?.uid;
    if (cartRef == null || uid == null) return;

    final snapshots = await cartRef.get();
    if (snapshots.docs.isEmpty) return; // Empty cart

    final items = snapshots.docs.map((doc) => CartItem.fromFirestore(doc)).toList();
    
    double totalAmount = 0.0;
    for (final item in items) {
      totalAmount += (item.price * item.quantity);
    }

    // Check user's wallet before proceeding
    final userRef = _firestore.collection('users').doc(uid);
    final userDoc = await userRef.get();
    double currentWallet = (userDoc.data()?['wallet'] as num?)?.toDouble() ?? 0.0;
    
    if (currentWallet < totalAmount) {
      if (event.onInsufficientBalance != null) {
        event.onInsufficientBalance!();
      }
      return;
    }

    // Create a new order in Firestore
    final orderRef = _firestore.collection('users').doc(uid).collection('orders').doc();
    
    final orderData = {
      'status': 'Pending',
      'totalAmount': totalAmount,
      'date': FieldValue.serverTimestamp(),
      'items': items.map((item) => item.toMap()).toList(),
    };

    final batch = _firestore.batch();
    batch.set(orderRef, orderData);

    // Deduct from user's wallet
    batch.set(userRef, {'wallet': FieldValue.increment(-totalAmount)}, SetOptions(merge: true));

    // Delete cart items
    for (var doc in snapshots.docs) {
      batch.delete(doc.reference);
    }

    await batch.commit();

    if (event.onSuccess != null) {
      event.onSuccess!();
    }
  }
}
