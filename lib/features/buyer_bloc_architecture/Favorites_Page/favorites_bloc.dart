import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'favorites_event.dart';
import 'favorites_state.dart';
import 'favorites_models.dart';

import 'dart:async';

class FavoritesBloc extends Bloc<FavoritesEvent, FavoritesState> {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;
  StreamSubscription<User?>? _authSubscription;

  FavoritesBloc({FirebaseFirestore? firestore, FirebaseAuth? auth})
      : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance,
        super(const FavoritesLoading()) {
    on<LoadFavoritesStarted>(_onLoadFavoritesStarted);
    on<FavoritesToggleRequested>(_onFavoritesToggleRequested);

    _authSubscription = _auth.authStateChanges().listen((user) {
      add(const LoadFavoritesStarted());
    });
  }

  @override
  Future<void> close() {
    _authSubscription?.cancel();
    return super.close();
  }

  Future<void> _onLoadFavoritesStarted(
    LoadFavoritesStarted event,
    Emitter<FavoritesState> emit,
  ) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) {
      emit(const FavoritesLoaded(items: [], favoriteIds: {}));
      return;
    }

    emit(const FavoritesLoading());

    await emit.forEach<QuerySnapshot>(
      _firestore
          .collection('users')
          .doc(uid)
          .collection('favorites')
          .orderBy('addedAt', descending: true)
          .snapshots(),
      onData: (snapshot) {
        final items = snapshot.docs.map((doc) => FavoriteItem.fromFirestore(doc)).toList();
        final favoriteIds = items.map((item) => item.id).toSet();
        return FavoritesLoaded(items: items, favoriteIds: favoriteIds);
      },
      onError: (error, stackTrace) => FavoritesError(error.toString()),
    );
  }

  Future<void> _onFavoritesToggleRequested(
    FavoritesToggleRequested event,
    Emitter<FavoritesState> emit,
  ) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;

    final docRef = _firestore
        .collection('users')
        .doc(uid)
        .collection('favorites')
        .doc(event.item.id);

    final docSnapshot = await docRef.get();

    if (docSnapshot.exists) {
      // Remove from favorites
      await docRef.delete();
    } else {
      // Add to favorites
      await docRef.set(event.item.toMap());
    }
  }
}
