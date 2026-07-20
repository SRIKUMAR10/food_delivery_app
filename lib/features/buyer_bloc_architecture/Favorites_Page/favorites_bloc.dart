import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'favorites_event.dart';
import 'favorites_state.dart';
import 'favorites_models.dart';
import '../../../core/services/i_auth_service.dart';
import '../../../core/services/auth_service.dart';

import 'dart:async';

class FavoritesBloc extends Bloc<FavoritesEvent, FavoritesState> {
  final FirebaseFirestore _firestore;
  final IAuthService _authService;
  StreamSubscription<String?>? _authSubscription;

  FavoritesBloc({FirebaseFirestore? firestore, IAuthService? authService})
      : _firestore = firestore ?? FirebaseFirestore.instance,
        _authService = authService ?? FirebaseAuthService(),
        super(const FavoritesLoading()) {
    on<LoadFavoritesStarted>(_onLoadFavoritesStarted);
    on<FavoritesToggleRequested>(_onFavoritesToggleRequested);

    _authSubscription = _authService.authStateChanges.listen((userId) {
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
    final uid = _authService.currentUserId;
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
    final uid = _authService.currentUserId;
    if (uid == null) return;

    final docRef = _firestore
        .collection('users')
        .doc(uid)
        .collection('favorites')
        .doc(event.item.id);

    final docSnapshot = await docRef.get();

    if (docSnapshot.exists) {
      await docRef.delete();
    } else {
      await docRef.set(event.item.toMap());
    }
  }
}
