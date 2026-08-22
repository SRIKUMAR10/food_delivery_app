import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'favorites_event.dart';
import 'favorites_state.dart';
import 'favorites_models.dart';
import '../../../core/services/i_auth_service.dart';
import '../../../core/repositories/i_favorites_repository.dart';
import '../../../core/utils/app_exception_formatter.dart';

class FavoritesBloc extends Bloc<FavoritesEvent, FavoritesState> {
  final IFavoritesRepository _favoritesRepository;
  final IAuthService _authService;
  StreamSubscription<String?>? _authSubscription;

  FavoritesBloc({
    required IFavoritesRepository favoritesRepository,
    required IAuthService authService,
  })  : _favoritesRepository = favoritesRepository,
        _authService = authService,
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
    await _authService.ensureTokenReady();

    await emit.forEach<List<FavoriteItem>>(
      _favoritesRepository.getFavoritesStream(uid),
      onData: (items) {
        final favoriteIds = items.map((item) => item.id).toSet();
        return FavoritesLoaded(items: items, favoriteIds: favoriteIds);
      },
      onError: (error, stackTrace) => FavoritesError(
        (error is FirebaseException && error.code == 'permission-denied')
            ? error.toString()
            : AppExceptionFormatter.toUserFriendlyMessage(error),
      ),
    );
  }

  Future<void> _onFavoritesToggleRequested(
    FavoritesToggleRequested event,
    Emitter<FavoritesState> emit,
  ) async {
    final uid = _authService.currentUserId;
    if (uid == null) return;

    try {
      await _favoritesRepository.toggleFavorite(uid, event.item);
    } catch (e) {
      if (state is FavoritesLoaded) {
        emit(FavoritesError(
          'Failed to update favorite: ${AppExceptionFormatter.toUserFriendlyMessage(e)}',
        ));
        emit(state);
      }
    }
  }
}
