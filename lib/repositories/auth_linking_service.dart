import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';

class AuthLinkingService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Calls the `checkAuthExists` Cloud Function to verify if an email or phone
  /// is already registered in the sellers collection. Returns a map with
  /// `exists` (bool) and `provider` (String?).
  Future<Map<String, dynamic>> checkAuthExists({
    String? email,
    String? phoneNumber,
  }) async {
    final callable =
        FirebaseFunctions.instance.httpsCallable('checkAuthExists');
    final result = await callable.call({
      if (email != null) 'email': email,
      if (phoneNumber != null) 'phoneNumber': phoneNumber,
    });
    final data = result.data as Map<String, dynamic>;
    return {
      'exists': data['exists'] as bool? ?? false,
      'provider': data['provider'] as String?,
    };
  }

  /// Checks if a user or seller with the given phone number exists in Firestore.
  /// Returns true if it exists, otherwise false.
  Future<bool> checkPhoneExists(String phoneNumber) async {
    try {
      // Check in users collection
      final userQuery = await _firestore
          .collection('users')
          .where('phoneNumber', isEqualTo: phoneNumber)
          .limit(1)
          .get();

      if (userQuery.docs.isNotEmpty) {
        return true;
      }

      // Check in sellers collection
      final sellerQuery = await _firestore
          .collection('sellers')
          .where('phoneNumber', isEqualTo: phoneNumber)
          .limit(1)
          .get();

      if (sellerQuery.docs.isNotEmpty) {
        return true;
      }

      return false;
    } catch (e) {
      debugPrint('Error checking phone existence: $e');
      return false;
    }
  }

  /// Links an [AuthCredential] to the currently signed-in user.
  Future<UserCredential> linkCredential(AuthCredential credential) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('No user is currently signed in to link credentials.');
    }
    
    try {
      return await user.linkWithCredential(credential);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'provider-already-linked') {
        throw Exception('This credential is already linked to your account.');
      } else if (e.code == 'credential-already-in-use') {
        throw Exception('This credential is already associated with a different user account.');
      }
      throw Exception('Failed to link credential: ${e.message}');
    } catch (e) {
      throw Exception('An unexpected error occurred during linking: $e');
    }
  }
}
