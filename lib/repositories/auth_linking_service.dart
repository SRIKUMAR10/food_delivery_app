import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';

class AuthLinkingService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Calls the `checkAuthExists` Cloud Function to verify if an email or phone
  /// is already registered in the specified role's collection. Returns a map with
  /// `exists` (bool) and `provider` (String?).
  Future<Map<String, dynamic>> checkAuthExists({
    String? email,
    String? phoneNumber,
    String? role,
  }) async {
    final callable =
        FirebaseFunctions.instance.httpsCallable('checkAuthExists');
    final result = await callable.call({
      if (email != null) 'email': email,
      if (phoneNumber != null) 'phoneNumber': phoneNumber,
      if (role != null) 'targetRole': role,
      if (role != null) 'role': role,
    });
    final data = result.data as Map<String, dynamic>;
    return {
      'exists': data['exists'] as bool? ?? false,
      'provider': data['provider'] as String?,
    };
  }

  /// Checks if a user with the given phone number exists in Firestore for the given role.
  /// If role is null, checks only the role-specific collections without cross-blocking.
  Future<bool> checkPhoneExists(String phoneNumber, {String? role}) async {
    try {
      final cleanPhone = phoneNumber.replaceAll(RegExp(r'\s+'), '').replaceAll('-', '');
      final digits = cleanPhone.replaceAll(RegExp(r'\D'), '');
      final variants = [phoneNumber, cleanPhone, '+91$digits', '+91 $digits', digits];

      if (role == null || role == 'buyer' || role == 'user') {
        final userQuery = await _firestore
            .collection('buyer_user')
            .where('phone', whereIn: variants)
            .limit(1)
            .get();

        if (userQuery.docs.isNotEmpty) {
          return true;
        }
        if (role == 'buyer' || role == 'user') return false;
      }

      if (role == 'seller') {
        final sellerQuery = await _firestore
            .collection('sellers')
            .where('contactNumber', whereIn: variants)
            .limit(1)
            .get();

        if (sellerQuery.docs.isNotEmpty) {
          return true;
        }
        return false;
      }

      if (role == 'delivery_partner' || role == 'delivery') {
        final dpQuery = await _firestore
            .collection('delivery_partners')
            .where('phoneNumber', whereIn: variants)
            .limit(1)
            .get();

        if (dpQuery.docs.isNotEmpty) {
          return true;
        }
        return false;
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
