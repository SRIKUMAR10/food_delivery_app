import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../app_data_collection/seller_collections/seller_collection.dart';
import '../core/models/seller_model.dart';
import '../core/repositories/i_seller_profile_repository.dart';

class FirebaseSellerProfileRepository implements ISellerProfileRepository {
  final FirebaseFirestore firestore;
  final FirebaseAuth auth;
  final FirebaseStorage storage;
  final SellerCollection _sellerCollection;

  FirebaseSellerProfileRepository({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
    FirebaseStorage? storage,
    SellerCollection? sellerCollection,
  })  : firestore = firestore ?? FirebaseFirestore.instance,
        auth = auth ?? FirebaseAuth.instance,
        storage = storage ?? FirebaseStorage.instance,
        _sellerCollection = sellerCollection ?? SellerCollection(firestore: firestore);

  @override
  Future<Map<String, dynamic>> loadProfile(String sellerId) async {
    SellerModel? seller = await _sellerCollection.getSeller(sellerId);

    // Check fallback from users collection or FirebaseAuth if details are missing
    String fallbackName = '';
    String fallbackEmail = '';
    String fallbackPhone = '';
    String fallbackPhoto = '';

    try {
      final userDoc = await firestore.collection('users').doc(sellerId).get();
      if (userDoc.exists && userDoc.data() != null) {
        final userData = userDoc.data()!;
        fallbackName = (userData['name'] ?? userData['displayName'] ?? userData['shopName'] ?? '').toString();
        fallbackEmail = (userData['email'] ?? '').toString();
        fallbackPhone = (userData['phone'] ?? userData['phoneNumber'] ?? '').toString();
        fallbackPhoto = (userData['avatarUrl'] ?? userData['photoUrl'] ?? userData['profileImageUrl'] ?? '').toString();
      }
    } catch (_) {}

    final authUser = auth.currentUser;
    if (authUser != null && authUser.uid == sellerId) {
      if (fallbackName.isEmpty) fallbackName = authUser.displayName?.trim() ?? '';
      if (fallbackEmail.isEmpty) fallbackEmail = authUser.email?.trim() ?? '';
      if (fallbackPhone.isEmpty) fallbackPhone = authUser.phoneNumber?.trim() ?? '';
      if (fallbackPhoto.isEmpty) fallbackPhoto = authUser.photoURL?.trim() ?? '';
    }

    if (seller != null) {
      final currentName = seller.name.trim().isNotEmpty ? seller.name : (seller.shopName ?? '');
      final resolvedName = currentName.isNotEmpty ? currentName : fallbackName;
      final enrichedSeller = seller.copyWith(
        name: resolvedName,
        shopName: resolvedName,
        email: seller.email.trim().isNotEmpty ? seller.email : fallbackEmail,
        phoneNumber: (seller.phoneNumber != null && seller.phoneNumber!.trim().isNotEmpty)
            ? seller.phoneNumber
            : fallbackPhone,
        profileImageUrl: (seller.profileImageUrl != null && seller.profileImageUrl!.trim().isNotEmpty)
            ? seller.profileImageUrl
            : fallbackPhoto,
      );
      return {'seller': enrichedSeller};
    } else if (fallbackName.isNotEmpty || fallbackEmail.isNotEmpty || fallbackPhone.isNotEmpty) {
      final defaultSeller = SellerModel(
        id: sellerId,
        name: fallbackName,
        shopName: fallbackName,
        email: fallbackEmail,
        phoneNumber: fallbackPhone,
        profileImageUrl: fallbackPhoto,
        role: 'seller',
        createdAt: DateTime.now(),
        isVerified: false,
        verificationStatus: 'pending',
        isOpen: true,
        isAcceptingOrders: true,
        isActive: true,
        kycStatus: 'pending',
      );
      return {'seller': defaultSeller};
    }

    return {};
  }

  @override
  Stream<Map<String, dynamic>> watchProfile(String sellerId) {
    return firestore
        .collection('sellers')
        .doc(sellerId)
        .snapshots()
        .map((snapshot) {
      if (!snapshot.exists) {
        final authUser = auth.currentUser;
        if (authUser != null && authUser.uid == sellerId) {
          final fallbackSeller = SellerModel(
            id: sellerId,
            name: authUser.displayName ?? '',
            shopName: authUser.displayName ?? '',
            email: authUser.email ?? '',
            phoneNumber: authUser.phoneNumber ?? '',
            profileImageUrl: authUser.photoURL ?? '',
            role: 'seller',
            createdAt: DateTime.now(),
            isVerified: false,
            verificationStatus: 'pending',
            isOpen: true,
            isAcceptingOrders: true,
            isActive: true,
            kycStatus: 'pending',
          );
          return {'seller': fallbackSeller};
        }
        return {};
      }
      final seller = SellerModel.fromFirestore(snapshot);
      final authUser = auth.currentUser;
      if (authUser != null && authUser.uid == sellerId) {
        final currentName = seller.name.trim().isNotEmpty ? seller.name : (seller.shopName ?? '');
        final resolvedName = currentName.isNotEmpty ? currentName : (authUser.displayName ?? '');
        final enriched = seller.copyWith(
          name: resolvedName,
          shopName: resolvedName,
          email: seller.email.trim().isNotEmpty ? seller.email : (authUser.email ?? ''),
          phoneNumber: (seller.phoneNumber != null && seller.phoneNumber!.trim().isNotEmpty)
              ? seller.phoneNumber
              : (authUser.phoneNumber ?? ''),
        );
        return {'seller': enriched};
      }
      return {
        'seller': seller,
      };
    });
  }

  @override
  Future<void> saveDraftState(String sellerId, Map<String, dynamic> draftData) async {
    try {
      await firestore.collection('sellers').doc(sellerId).set({
        ...draftData,
        'draftUpdatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (_) {}
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

  @override
  Future<Map<String, dynamic>> loadKycDocuments(String sellerId) async {
    try {
      final doc = await _sellerCollection.getKycDocument(sellerId);
      if (doc.exists && doc.data() != null) {
        return Map<String, dynamic>.from(doc.data() as Map);
      }
      return {};
    } catch (e) {
      return {};
    }
  }

  @override
  Stream<Map<String, dynamic>> watchKycDocuments(String sellerId) {
    return _sellerCollection.watchKycDocument(sellerId).map((snapshot) {
      if (!snapshot.exists || snapshot.data() == null) {
        return <String, dynamic>{};
      }
      return Map<String, dynamic>.from(snapshot.data() as Map);
    });
  }

  @override
  Future<void> updateKycDocuments(String sellerId, Map<String, dynamic> data) async {
    await _sellerCollection.updateKycDocument(sellerId, data);
  }

  @override
  Future<String> uploadKycDocumentFile({
    required String sellerId,
    required String docType,
    required String fileName,
    required List<int> fileBytes,
  }) async {
    final String sanitizedDocType = docType.toLowerCase().replaceAll(' ', '_');
    final String path = 'seller_kyc_documents/$sellerId/${sanitizedDocType}_$fileName';
    final Reference ref = storage.ref().child(path);
    final String contentType = _getContentType(fileName);
    final UploadTask uploadTask = ref.putData(
      Uint8List.fromList(fileBytes),
      SettableMetadata(contentType: contentType),
    );
    final TaskSnapshot snapshot = await uploadTask;
    return snapshot.ref.getDownloadURL();
  }

  String _getContentType(String fileName) {
    final lower = fileName.toLowerCase();
    if (lower.endsWith('.png')) return 'image/png';
    if (lower.endsWith('.jpg') || lower.endsWith('.jpeg')) return 'image/jpeg';
    if (lower.endsWith('.webp')) return 'image/webp';
    if (lower.endsWith('.gif')) return 'image/gif';
    if (lower.endsWith('.pdf')) return 'application/pdf';
    return 'image/jpeg';
  }
}

