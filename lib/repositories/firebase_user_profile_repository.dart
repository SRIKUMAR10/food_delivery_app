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
        final String address = (data['address'] ?? data['deliveryAddress'] ?? data['fullAddress'] ?? '').toString().trim();
        String home = (data['homeAddress'] ?? '').toString().trim();
        String work = (data['workAddress'] ?? '').toString().trim();
        String other = (data['otherAddress'] ?? '').toString().trim();
        String selectedType = (data['selectedAddressType'] ?? 'Home').toString().trim();
        if (selectedType.isEmpty) selectedType = 'Home';

        if (home.isEmpty && work.isEmpty && other.isEmpty && address.isNotEmpty) {
          home = address;
        }

        return UserProfile(
          name: (data['name'] ?? data['fullName'] ?? data['displayName'] ?? '').toString().trim(),
          email: (data['email'] ?? data['emailAddress'] ?? '').toString().trim(),
          phone: (data['phone'] ?? data['phoneNumber'] ?? data['mobile'] ?? data['contact'] ?? '').toString().trim(),
          address: address,
          homeAddress: home,
          workAddress: work,
          otherAddress: other,
          selectedAddressType: selectedType,
          imageUrl: (data['imageUrl'] ?? data['photoUrl'] ?? data['profilePic']) as String?,
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
      final selectedString = profile.selectedAddressType.toLowerCase() == 'home'
          ? (profile.homeAddress.isNotEmpty ? profile.homeAddress : profile.address)
          : profile.selectedAddressType.toLowerCase() == 'work'
              ? (profile.workAddress.isNotEmpty ? profile.workAddress : profile.address)
              : (profile.otherAddress.isNotEmpty ? profile.otherAddress : profile.address);

      final cleanAddress = (selectedString.isNotEmpty ? selectedString : profile.address).trim();

      await firestore.collection('buyer_user').doc(userId).set({
        'name': profile.name.trim(),
        'email': profile.email.trim(),
        'phone': profile.phone.trim(),
        'phoneNumber': profile.phone.trim(),
        'address': cleanAddress,
        'deliveryAddress': cleanAddress,
        'homeAddress': profile.homeAddress.trim(),
        'workAddress': profile.workAddress.trim(),
        'otherAddress': profile.otherAddress.trim(),
        'selectedAddressType': profile.selectedAddressType.trim().isNotEmpty ? profile.selectedAddressType.trim() : 'Home',
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
      final String address = (data['address'] ?? data['deliveryAddress'] ?? data['fullAddress'] ?? '').toString().trim();
      String home = (data['homeAddress'] ?? '').toString().trim();
      String work = (data['workAddress'] ?? '').toString().trim();
      String other = (data['otherAddress'] ?? '').toString().trim();
      String selectedType = (data['selectedAddressType'] ?? 'Home').toString().trim();
      if (selectedType.isEmpty) selectedType = 'Home';

      if (home.isEmpty && work.isEmpty && other.isEmpty && address.isNotEmpty) {
        home = address;
      }

      return UserProfile(
        name: (data['name'] ?? data['fullName'] ?? data['displayName'] ?? '').toString().trim(),
        email: (data['email'] ?? data['emailAddress'] ?? '').toString().trim(),
        phone: (data['phone'] ?? data['phoneNumber'] ?? data['mobile'] ?? data['contact'] ?? '').toString().trim(),
        address: address,
        homeAddress: home,
        workAddress: work,
        otherAddress: other,
        selectedAddressType: selectedType,
        imageUrl: (data['imageUrl'] ?? data['photoUrl'] ?? data['profilePic']) as String?,
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

  @override
  Stream<double?> watchWalletBalance(String userId) {
    return firestore.collection('buyer_user').doc(userId).snapshots().map(
        (snapshot) {
      if (!snapshot.exists) return null;
      final data = snapshot.data();
      return (data?['wallet'] as num?)?.toDouble();
    });
  }

  @override
  Future<double?> loadWalletBalance(String userId) async {
    try {
      final doc = await firestore.collection('buyer_user').doc(userId).get();
      if (doc.exists) {
        final data = doc.data();
        if (data == null) return null;
        return (data['wallet'] as num?)?.toDouble();
      }
    } catch (e) {
      debugPrint('Error loading wallet balance: $e');
    }
    return null;
  }

  @override
  Future<void> addWalletTransaction({
    required String userId,
    required double amount,
    required String title,
    required bool isCredit,
    String? paymentId,
    String? orderId,
    String status = 'success',
  }) async {
    final userRef = firestore.collection('buyer_user').doc(userId);

    await firestore.runTransaction((transaction) async {
      DocumentSnapshot snapshot = await transaction.get(userRef);
      final data = snapshot.data() as Map<String, dynamic>?;
      double currentBalance =
          ((data?['wallet'] as num?)?.toDouble()) ??
          0.0;

      transaction.set(userRef, {
        'wallet': isCredit ? currentBalance + amount : currentBalance - amount,
      }, SetOptions(merge: true));

      transaction.set(userRef.collection('transactions').doc(), {
        'amount': amount,
        'title': title,
        'isCredit': isCredit,
        'status': status,
        if (paymentId != null) 'paymentId': paymentId,
        if (orderId != null) 'orderId': orderId,
        'createdAt': FieldValue.serverTimestamp(),
        'timestamp':
            FieldValue.serverTimestamp(),
      });
    });
  }
}
