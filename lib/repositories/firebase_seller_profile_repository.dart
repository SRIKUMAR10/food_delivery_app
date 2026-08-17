import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../app_data_collection/seller_collections/seller_collection.dart';
import '../core/models/seller_model.dart';
import '../core/repositories/i_seller_profile_repository.dart';

class FirebaseSellerProfileRepository implements ISellerProfileRepository {
  final FirebaseFirestore firestore;
  final FirebaseStorage storage;
  final SellerCollection _sellerCollection = SellerCollection();

  FirebaseSellerProfileRepository({
    FirebaseFirestore? firestore,
    FirebaseStorage? storage,
  })  : firestore = firestore ?? FirebaseFirestore.instance,
        storage = storage ?? FirebaseStorage.instance;

  @override
  Future<Map<String, dynamic>> loadProfile(String sellerId) async {
    final seller = await _sellerCollection.getSeller(sellerId);
    if (seller != null) {
      return {
        'seller': seller,
      };
    }
    return {};
  }

  @override
  Stream<Map<String, dynamic>> watchProfile(String sellerId) {
    return FirebaseFirestore.instance
        .collection('sellers')
        .doc(sellerId)
        .snapshots()
        .map((snapshot) {
      if (!snapshot.exists) return {};
      final seller = SellerModel.fromFirestore(snapshot);
      return {
        'seller': seller,
      };
    });
  }

  @override
  Future<void> updateProfile(String sellerId, Map<String, dynamic> data) async {
    await _sellerCollection.updateSeller(sellerId, data);
  }

  @override
  Future<String> uploadProfileImage({
    required String sellerId,
    required String fileName,
    required List<int> imageBytes,
  }) async {
    final String path = 'profile_images/$sellerId/$fileName';
    final Reference ref = storage.ref().child(path);
    final String contentType = _getContentType(fileName);
    final UploadTask uploadTask = ref.putData(
      Uint8List.fromList(imageBytes),
      SettableMetadata(contentType: contentType),
    );
    final TaskSnapshot snapshot = await uploadTask;
    return snapshot.ref.getDownloadURL();
  }

  @override
  Future<String> uploadCoverImage({
    required String sellerId,
    required String fileName,
    required List<int> imageBytes,
  }) async {
    final String path = 'profile_images/$sellerId/cover_$fileName';
    final Reference ref = storage.ref().child(path);
    final String contentType = _getContentType(fileName);
    final UploadTask uploadTask = ref.putData(
      Uint8List.fromList(imageBytes),
      SettableMetadata(contentType: contentType),
    );
    final TaskSnapshot snapshot = await uploadTask;
    return snapshot.ref.getDownloadURL();
  }

  @override
  Future<void> updateOperationalStatus(
    String sellerId, {
    bool? isOpen,
    bool? isAcceptingOrders,
    bool? isOnline,
  }) async {
    final Map<String, dynamic> updates = {};
    if (isOpen != null) updates['isOpen'] = isOpen;
    if (isAcceptingOrders != null) updates['isAcceptingOrders'] = isAcceptingOrders;
    if (isOnline != null) updates['isOnline'] = isOnline;

    if (updates.isNotEmpty) {
      await _sellerCollection.updateSeller(sellerId, updates);
    }
  }

  String _getContentType(String fileName) {
    final lower = fileName.toLowerCase();
    if (lower.endsWith('.png')) return 'image/png';
    if (lower.endsWith('.jpg') || lower.endsWith('.jpeg')) return 'image/jpeg';
    if (lower.endsWith('.webp')) return 'image/webp';
    if (lower.endsWith('.gif')) return 'image/gif';
    return 'image/jpeg';
  }
}

