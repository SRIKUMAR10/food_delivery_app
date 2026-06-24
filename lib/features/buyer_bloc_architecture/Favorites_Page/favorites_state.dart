import 'package:equatable/equatable.dart';
import 'favorites_models.dart';

abstract class FavoritesState extends Equatable {
  const FavoritesState();

  @override
  List<Object?> get props => [];
}

class FavoritesLoading extends FavoritesState {
  const FavoritesLoading();
}

class FavoritesLoaded extends FavoritesState {
  final List<FavoriteItem> items;
  final Set<String> favoriteIds;
  
  const FavoritesLoaded({required this.items, required this.favoriteIds});

  @override
  List<Object?> get props => [items, favoriteIds];
}

class FavoritesError extends FavoritesState {
  final String message;
  const FavoritesError(this.message);

  @override
  List<Object?> get props => [message];
}
