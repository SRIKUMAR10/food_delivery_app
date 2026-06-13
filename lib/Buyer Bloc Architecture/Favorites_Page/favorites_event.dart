import 'package:equatable/equatable.dart';
import 'favorites_models.dart';

abstract class FavoritesEvent extends Equatable {
  const FavoritesEvent();

  @override
  List<Object?> get props => [];
}

class LoadFavoritesStarted extends FavoritesEvent {
  const LoadFavoritesStarted();
}

class FavoritesToggleRequested extends FavoritesEvent {
  final FavoriteItem item;
  const FavoritesToggleRequested(this.item);

  @override
  List<Object?> get props => [item];
}
