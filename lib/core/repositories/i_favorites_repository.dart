import '../../features/buyer_bloc_architecture/Favorites_Page/favorites_models.dart';

abstract interface class IFavoritesRepository {
  Stream<List<FavoriteItem>> getFavoritesStream(String userId);
  Future<bool> isFavorite(String userId, String itemId);
  Future<void> toggleFavorite(String userId, FavoriteItem item);
}
