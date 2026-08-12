import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../core/repositories/i_favorites_repository.dart';
import '../features/buyer_bloc_architecture/Favorites_Page/favorites_models.dart';

class FirebaseFavoritesRepository implements IFavoritesRepository {
  final FirebaseFirestore firestore;

  FirebaseFavoritesRepository({FirebaseFirestore? firestore})
      : firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Stream<List<FavoriteItem>> getFavoritesStream(String userId) {
    if (userId.isEmpty) return Stream.value([]);
    return firestore
        .collection('buyer_user')
        .doc(userId)
        .collection('favorites')
        .orderBy('addedAt', descending: true)
        .snapshots(includeMetadataChanges: true)
        .map((snapshot) =>
            snapshot.docs.map((doc) => FavoriteItem.fromFirestore(doc)).toList())
        .handleError((_) => <FavoriteItem>[]);
  }

  @override
  Future<bool> isFavorite(String userId, String itemId) async {
    final doc = await firestore
        .collection('buyer_user')
        .doc(userId)
        .collection('favorites')
        .doc(itemId)
        .get();
    return doc.exists;
  }

  @override
  Future<void> toggleFavorite(String userId, FavoriteItem item) async {
    final docRef = firestore
        .collection('buyer_user')
        .doc(userId)
        .collection('favorites')
        .doc(item.id);

    final docSnapshot = await docRef.get();

    if (docSnapshot.exists) {
      await docRef.delete();
    } else {
      final data = item.toMap();
      await docRef.set(data);
    }
  }
}
