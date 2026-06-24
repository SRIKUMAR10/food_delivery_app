import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:food_delivery_app/app_data_collection/seller_collections/seller_collection.dart';
import 'package:food_delivery_app/core/models/seller_model.dart';

class SellerRepository {
  static final SellerRepository _instance = SellerRepository._internal();
  factory SellerRepository() => _instance;
  SellerRepository._internal();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final SellerCollection _sellerCollection = SellerCollection();

  // State for Phone Auth (Web primarily)
  ConfirmationResult? _confirmationResult;

  User? get currentUser {
    try {
      return _auth.currentUser;
    } catch (_) {
      return null;
    }
  }

  // ==========================================
  // Auth Operations
  // ==========================================

  Future<UserCredential> signUp(
    String email,
    String password,
    String name,
  ) async {
    try {
      UserCredential credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user != null) {
        await createSeller(
          SellerModel(
            id: credential.user!.uid,
            name: name,
            email: email,
            role: 'seller',
            createdAt: DateTime.now(),
          ),
        );
      }
      return credential;
    } catch (e) {
      throw Exception('Seller SignUp failed: $e');
    }
  }

  Future<UserCredential> signIn(String email, String password) async {
    try {
      return await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      throw Exception('Seller SignIn failed: $e');
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  Future<UserCredential> signInWithGoogle() async {
    try {
      final GoogleAuthProvider googleProvider = GoogleAuthProvider();
      final UserCredential userCredential = await _auth.signInWithPopup(
        googleProvider,
      );

      final User? user = userCredential.user;
      if (user != null) {
        // Ensure we create/update the seller document
        await createSeller(
          SellerModel(
            id: user.uid,
            name: user.displayName ?? 'Unknown',
            email: user.email ?? 'No Email',
            role: 'seller',
            createdAt: DateTime.now(),
          ),
        );
      }
      return userCredential;
    } catch (e) {
      throw Exception('Google SignIn failed: $e');
    }
  }

  Future<UserCredential> signInWithApple() async {
    try {
      final AppleAuthProvider appleProvider = AppleAuthProvider();
      final UserCredential userCredential = await _auth.signInWithPopup(
        appleProvider,
      );

      final User? user = userCredential.user;
      if (user != null) {
        await createSeller(
          SellerModel(
            id: user.uid,
            name: user.displayName ?? 'Unknown',
            email: user.email ?? 'No Email',
            role: 'seller',
            createdAt: DateTime.now(),
          ),
        );
      }
      return userCredential;
    } catch (e) {
      throw Exception('Apple SignIn failed: $e');
    }
  }

  // ==========================================
  // OTP Operations
  // ==========================================

  Future<void> sendOtp(String phoneNumber) async {
    try {
      _confirmationResult = await _auth.signInWithPhoneNumber(phoneNumber);
    } on FirebaseAuthException catch (e) {
      print('Firebase Error Code: ${e.code}');
      print('Firebase Error Message: ${e.message}');
      throw Exception('Firebase Error [${e.code}]: ${e.message}');
    } catch (e) {
      print('Unexpected Error: $e');
      throw Exception('An unexpected error occurred while sending OTP: $e');
    }
  }

  Future<bool> verifyOtp(String phoneNumber, String otpCode) async {
    if (_confirmationResult == null) {
      throw Exception('Please request an OTP first.');
    }

    try {
      UserCredential userCredential = await _confirmationResult!.confirm(
        otpCode,
      );
      final User? user = userCredential.user;

      if (user != null) {
        // Update seller status upon successful OTP verification
        await updateSeller(user.uid, {
          'phoneNumber': phoneNumber,
          'isVerified': true,
          'verifiedAt': FieldValue.serverTimestamp(),
          'role': 'seller',
        });
        return true;
      }
      return false;
    } on FirebaseAuthException catch (e) {
      throw Exception('Invalid OTP: ${e.message}');
    } catch (e) {
      throw Exception('Failed to verify OTP: $e');
    }
  }

  // ==========================================
  // Firestore Abstraction Operations
  // ==========================================

  /// Creates or overwrites a seller document
  Future<void> createSeller(SellerModel seller) async {
    await _sellerCollection.addSeller(seller);
  }

  /// Fetches a seller document
  Future<SellerModel?> fetchSeller(String sellerId) async {
    return await _sellerCollection.getSeller(sellerId);
  }

  /// Updates specific fields in a seller document
  Future<void> updateSeller(String sellerId, Map<String, dynamic> data) async {
    await _sellerCollection.updateSeller(sellerId, data);
  }

  /// Deletes a seller document
  Future<void> deleteSeller(String sellerId) async {
    await _sellerCollection.deleteSeller(sellerId);
  }

  /// Gets a real-time stream of sellers
  Stream<QuerySnapshot<SellerModel>> getSellersStream() {
    return _sellerCollection.getSellersStream();
  }
}
