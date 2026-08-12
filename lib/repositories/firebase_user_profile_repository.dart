import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:food_delivery_app/core/repositories/i_user_profile_repository.dart';
import 'package:food_delivery_app/features/buyer_bloc_architecture/user_profile_image/user_profile_models.dart';

class FirebaseUserProfileRepository implements IUserProfileRepository {
  final FirebaseFirestore firestore;
  final FirebaseStorage storage;

  FirebaseUserProfileRepository({
    FirebaseFirestore? firestore,
    FirebaseStorage? storage,
  })  : firestore = firestore ?? FirebaseFirestore.instance,
        storage = storage ?? FirebaseStorage.instance;

  @override
  Future<UserProfile?> loadProfile(String userId) async {
    try {
      final doc = await firestore.collection('buyer_user').doc(userId).get();
      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        return UserProfile(
          name: data['name'] ?? '',
          email: data['email'] ?? '',
          phone: data['phone'] ?? '',
          address: data['address'] ?? '',
          homeAddress: data['homeAddress'] ?? '',
          workAddress: data['workAddress'] ?? '',
          otherAddress: data['otherAddress'] ?? '',
          selectedAddressType: data['selectedAddressType'] ?? 'Home',
          imageUrl: data['imageUrl'],
        );
      }
      return null;
    } catch (e) {
      debugPrint('Error loading profile: $e');
      rethrow;
    }
  }

  @override
  Future<void> saveProfile(String userId, UserProfile profile) async {
    try {
      await firestore.collection('buyer_user').doc(userId).set({
        'name': profile.name.trim(),
        'email': profile.email.trim(),
        'phone': profile.phone.trim(),
        'address': profile.address.trim(),
        'homeAddress': profile.homeAddress.trim(),
        'workAddress': profile.workAddress.trim(),
        'otherAddress': profile.otherAddress.trim(),
        'selectedAddressType': profile.selectedAddressType,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      debugPrint('Error saving profile: $e');
      rethrow;
    }
  }

  @override
  Future<String> uploadProfileImage({
    required String userId,
    required String fileName,
    required Uint8List imageBytes,
    required String contentType,
  }) async {
    final Reference ref = storage.ref('user/image/$userId.jpg');
    final UploadTask uploadTask = ref.putData(
      imageBytes,
      SettableMetadata(contentType: contentType),
    );

    await uploadTask;
    return ref.getDownloadURL();
  }

  @override
  Future<void> updateProfileImageUrl(String userId, String imageUrl) async {
    try {
      await firestore.collection('buyer_user').doc(userId).set({
        'imageUrl': imageUrl,
      }, SetOptions(merge: true));
    } catch (e) {
      debugPrint('Error updating profile image URL: $e');
      rethrow;
    }
  }

  @override
  Stream<UserProfile?> watchProfile(String userId) {
    return firestore
        .collection('buyer_user')
        .doc(userId)
        .snapshots()
        .map((snapshot) {
      if (!snapshot.exists) return null;
      final data = snapshot.data();
      if (data == null) return null;
      return UserProfile(
        name: data['name'] ?? '',
        email: data['email'] ?? '',
        phone: data['phone'] ?? '',
        address: data['address'] ?? '',
        homeAddress: data['homeAddress'] ?? '',
        workAddress: data['workAddress'] ?? '',
        otherAddress: data['otherAddress'] ?? '',
        selectedAddressType: data['selectedAddressType'] ?? 'Home',
        imageUrl: data['imageUrl'],
      );
    });
  }

  @override
  Stream<String?> watchProfileImageUrl(String userId) {
    return firestore
        .collection('buyer_user')
        .doc(userId)
        .snapshots()
        .map((snapshot) {
      if (!snapshot.exists) return null;
      final data = snapshot.data();
      return data?['imageUrl'] as String?;
    });
  }

  @override
  Stream<List<Map<String, dynamic>>> watchTransactions(String userId) {
    return firestore
        .collection('buyer_user')
        .doc(userId)
        .collection('transactions')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) {
              final data = doc.data();
              if (data['createdAt'] is Timestamp) {
                data['createdAt'] =
                    (data['createdAt'] as Timestamp).toDate();
              }
              if (data['timestamp'] is Timestamp) {
                data['timestamp'] =
                    (data['timestamp'] as Timestamp).toDate();
              }
              return data;
            }).toList());
  }
}
