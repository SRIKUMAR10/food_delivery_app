import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:food_delivery_app/features/buyer_bloc_architecture/home_Page/seller_model.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:google_sign_in/google_sign_in.dart';

class SellerRepository {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  SellerRepository({FirebaseFirestore? firestore, FirebaseAuth? auth})
      : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  User? get currentUser => _auth.currentUser;

  Stream<Seller> getSellerById(String sellerId) {
    return _firestore
        .collection('sellers')
        .doc(sellerId)
        .snapshots()
        .map((snapshot) => Seller.fromFirestore(snapshot));
  }

  Future<Seller> fetchSeller(String sellerId) async {
    final doc = await _firestore.collection('sellers').doc(sellerId).get();
    if (doc.exists) {
      return Seller.fromFirestore(doc);
    }
    throw Exception('Seller not found');
  }

  Future<void> updateSeller(Seller seller) async {
    await _firestore.collection('sellers').doc(seller.id).set(seller.toFirestore(), SetOptions(merge: true));
  }

  Future<void> updateSellerData(String sellerId, Map<String, dynamic> data) async {
    await _firestore.collection('sellers').doc(sellerId).update(data);
  }

  Future<UserCredential> signIn(String emailOrPhone, String password) async {
    return await _auth.signInWithEmailAndPassword(email: emailOrPhone, password: password);
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  Future<void> sendPasswordResetEmail(String email) async {
    await _auth.sendPasswordResetEmail(email: email);
  }

  Future<UserCredential> signInWithGoogle() async {
    try {
      if (kIsWeb) {
        GoogleAuthProvider authProvider = GoogleAuthProvider();
        return await _auth.signInWithPopup(authProvider);
      } else {
        final GoogleSignIn googleSignIn = GoogleSignIn();
        final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
        
        if (googleUser == null) {
          throw Exception('Google Sign-In aborted by user');
        }
        
        final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
        final AuthCredential credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );
        
        return await _auth.signInWithCredential(credential);
      }
    } catch (e) {
      throw Exception('Google Sign-In failed: $e');
    }
  }

  Future<UserCredential> signInWithApple() async {
    // Placeholder implementation for Apple Sign-In
    throw UnimplementedError('Apple Sign-In is not fully implemented');
  }

  Future<void> requestPhoneLoginOtp(String phoneNumber) async {
    // Placeholder for requesting OTP via Firebase Auth
  }

  Future<bool> verifyPhoneLoginOtp(String otpCode, String phoneNumber) async {
    // Placeholder for verifying OTP
    return true;
  }

  Future<void> initiateSignUp({
    required String name,
    required String shopName,
    required String businessDetails,
    required String phoneNumber,
    required String email,
    required String password,
  }) async {
    // Placeholder implementation for initiating sign up
    UserCredential credential = await _auth.createUserWithEmailAndPassword(email: email, password: password);
    final seller = Seller(
      id: credential.user!.uid,
      sellerName: name,
      shopName: shopName,
      contactNumber: phoneNumber,
    );
    await updateSeller(seller);
  }

  Future<bool> confirmSignUpOtp({
    required String otpCode,
    required String phoneNumber,
    required String name,
    required String shopName,
    required String businessDetails,
    required String email,
    required String password,
  }) async {
    // Placeholder for OTP confirmation during sign up
    return true;
  }

  Future<void> sendOtp(String phoneNumber) async {
    // Placeholder for sending OTP
  }

  Future<bool> checkEmailVerified() async {
    await _auth.currentUser?.reload();
    return _auth.currentUser?.emailVerified ?? false;
  }
}
