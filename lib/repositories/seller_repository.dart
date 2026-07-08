import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:food_delivery_app/app_data_collection/seller_collections/seller_collection.dart';
import 'package:food_delivery_app/core/models/seller_model.dart';

/// Central repository for all seller authentication and Firestore operations.
/// Sign-Up flow uses a "pending_sellers" staging pattern for safe OTP-gated
/// account creation. Login supports Email/Password, Phone-OTP, Google & Apple.
class SellerRepository {
  static final SellerRepository _instance = SellerRepository._internal();
  factory SellerRepository() => _instance;
  SellerRepository._internal();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final SellerCollection _sellerCollection = SellerCollection();

  // Holds the Web phone-auth confirmation result between sendOtp / verifyOtp calls
  ConfirmationResult? _confirmationResult;

  // ──────────────────────────────────────────────────────────────────────────
  // Current user accessor
  // ──────────────────────────────────────────────────────────────────────────

  User? get currentUser {
    try {
      return _auth.currentUser;
    } catch (_) {
      return null;
    }
  }

  // ──────────────────────────────────────────────────────────────────────────
  // Duplicate-check helpers
  // ──────────────────────────────────────────────────────────────────────────

  /// Returns true if [phoneNumber] already belongs to a seller document.
  Future<bool> checkPhoneExists(String phoneNumber) async {
    try {
      final callable = FirebaseFunctions.instance.httpsCallable('checkAuthExists');
      final result = await callable.call({'phoneNumber': phoneNumber});
      return result.data['exists'] == true;
    } catch (_) {
      return false;
    }
  }

  /// Returns true if [email] already belongs to a seller document.
  Future<bool> checkEmailExists(String email) async {
    try {
      final callable = FirebaseFunctions.instance.httpsCallable('checkAuthExists');
      final result = await callable.call({'email': email});
      return result.data['exists'] == true;
    } catch (_) {
      return false;
    }
  }

  /// Returns the `authProvider` field for a given email, or null if not found.
  Future<String?> getAuthProviderForEmail(String email) async {
    try {
      final callable = FirebaseFunctions.instance.httpsCallable('checkAuthExists');
      final result = await callable.call({'email': email});
      if (result.data['exists'] == true) {
        return result.data['provider'] as String?;
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  // ──────────────────────────────────────────────────────────────────────────
  // SIGN-UP  (pending_sellers → OTP → confirm → create seller)
  // ──────────────────────────────────────────────────────────────────────────

  /// Step 1 of sign-up: validate duplicates, store data temporarily, send OTP.
  /// Throws descriptive [Exception] on any conflict or error.
  Future<void> initiateSignUp({
    required String name,
    required String shopName,
    required String businessDetails,
    required String phoneNumber, // e.g. "+919876543210"
    required String email,
    required String password,
  }) async {
    // --- Duplicate checks ---
    final phoneExists = await checkPhoneExists(phoneNumber);
    if (phoneExists) {
      throw Exception(
          'This Phone Number is already registered. Please Login.');
    }

    final emailProvider = await getAuthProviderForEmail(email);
    if (emailProvider != null) {
      if (emailProvider == 'google.com') {
        throw Exception('GOOGLE_ACCOUNT_EXISTS');
      } else if (emailProvider == 'apple.com') {
        throw Exception('APPLE_ACCOUNT_EXISTS');
      } else {
        throw Exception(
            'This Email is already registered. Please Login.');
      }
    }

    // --- Send OTP ---
    await sendOtp(phoneNumber);
  }

  /// Step 2 of sign-up: verify OTP, create the seller account, clean up pending doc.
  /// Returns true on success.
  Future<bool> confirmSignUpOtp({
    required String otpCode,
    required String phoneNumber,
    required String name,
    required String shopName,
    required String businessDetails,
    required String email,
    required String password,
  }) async {
    if (_confirmationResult == null) {
      throw Exception('OTP not sent. Please try again.');
    }

    try {
      final userCredential = await _confirmationResult!.confirm(otpCode);
      final user = userCredential.user;
      
      if (user == null || user.uid.isEmpty) {
        throw Exception('Authentication failed. User is null.');
      }

      // Double check currentUser per requirements
      final currentUser = _auth.currentUser;
      if (currentUser == null || currentUser.uid != user.uid) {
        throw Exception('Authentication mismatch or currentUser is null.');
      }

      print('DEBUG: Authentication successful.');
      print('DEBUG: Current User UID: ${currentUser.uid}');
      print('DEBUG: Email: $email');
      print('DEBUG: Phone Number: $phoneNumber');
      print('DEBUG: Firestore Collection: sellers');
      print('DEBUG: Document ID: ${currentUser.uid}');

      // Create Firebase Auth email/password credential and link it
      // (phone auth already signed in; we now also create email credentials)
      try {
        final emailCredential = EmailAuthProvider.credential(
          email: email,
          password: password,
        );
        await currentUser.linkWithCredential(emailCredential);

        if (!currentUser.emailVerified) {
          await currentUser.sendEmailVerification();
        }
      } on FirebaseAuthException catch (e) {
        // If already linked or credential issue, continue – phone auth is enough
        if (e.code != 'provider-already-linked' &&
            e.code != 'email-already-in-use') {
          print('DEBUG: Link credential failed: ${e.message}');
        }
      }

      // Create Firestore seller document ONLY after auth succeeds
      await createSeller(SellerModel(
        id: currentUser.uid,
        name: name.isNotEmpty ? name : 'Seller',
        email: email,
        role: 'seller',
        shopName: shopName,
        businessDetails: businessDetails,
        phoneNumber: phoneNumber,
        authProvider: 'phone',
        isVerified: true,
        createdAt: DateTime.now(),
      ));

      return true;
    } on FirebaseAuthException catch (e) {
      throw Exception('Invalid OTP: ${e.message}');
    } catch (e) {
      throw Exception('OTP verification failed: $e');
    }
  }

  // ──────────────────────────────────────────────────────────────────────────
  // SIGN-IN  (Email/Password)
  // ──────────────────────────────────────────────────────────────────────────

  Future<UserCredential> signIn(String email, String password) async {
    try {
      final provider = await getAuthProviderForEmail(email);

      if (provider == null) {
        throw Exception('No Account found for this Email. Please Sign Up.');
      }
      if (provider == 'google.com') {
        throw Exception('GOOGLE_ACCOUNT_EXISTS');
      }
      if (provider == 'apple.com') {
        throw Exception('APPLE_ACCOUNT_EXISTS');
      }

      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user != null && !credential.user!.emailVerified) {
        await _auth.signOut();
        throw Exception('Please verify your email before logging in.');
      }

      return credential;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'wrong-password' || e.code == 'invalid-credential') {
        throw Exception('Invalid password. Please try again.');
      }
      if (e.code == 'user-not-found') {
        throw Exception('No Account found. Please Sign Up.');
      }
      if (e.code == 'too-many-requests') {
        throw Exception('Too many attempts. Please try again in a few minutes.');
      }
      throw Exception('Login failed: ${e.message}');
    } catch (e) {
      if (e.toString().contains('Exception:')) rethrow;
      throw Exception('Login failed: $e');
    }
  }

  // ──────────────────────────────────────────────────────────────────────────
  // PHONE LOGIN  (Request OTP → Verify)
  // ──────────────────────────────────────────────────────────────────────────

  /// Checks phone registration, then sends OTP.
  Future<void> requestPhoneLoginOtp(String phoneNumber) async {
    final exists = await checkPhoneExists(phoneNumber);
    if (!exists) {
      throw Exception('PHONE_NOT_REGISTERED');
    }
    await sendOtp(phoneNumber);
  }

  /// Verifies OTP for phone login. Returns true on success.
  Future<bool> verifyPhoneLoginOtp(
      String otpCode, String phoneNumber) async {
    if (_confirmationResult == null) {
      throw Exception('OTP not sent. Please try again.');
    }

    try {
      final userCredential = await _confirmationResult!.confirm(otpCode);
      final user = userCredential.user;
      if (user == null) return false;

      // Update last login
      await updateSeller(user.uid, {
        'lastLoginAt': FieldValue.serverTimestamp(),
      });

      return true;
    } on FirebaseAuthException catch (e) {
      throw Exception('Invalid OTP: ${e.message}');
    } catch (e) {
      throw Exception('OTP verification failed: $e');
    }
  }

  // ──────────────────────────────────────────────────────────────────────────
  // GOOGLE / APPLE SIGN-IN
  // ──────────────────────────────────────────────────────────────────────────

  Future<UserCredential> signInWithGoogle() async {
    try {
      final googleProvider = GoogleAuthProvider();
      final userCredential = await _auth.signInWithPopup(googleProvider);
      await _handleSocialSignIn(userCredential, 'google.com');
      return userCredential;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'account-exists-with-different-credential') {
        throw Exception(
            'This email is registered with a different method. Please login using that method.');
      }
      throw Exception('Google Login failed: ${e.message}');
    } catch (e) {
      if (e.toString().contains('Exception:')) rethrow;
      throw Exception('Google Login failed: $e');
    }
  }

  Future<UserCredential> signInWithApple() async {
    try {
      final appleProvider = AppleAuthProvider();
      final userCredential = await _auth.signInWithPopup(appleProvider);
      await _handleSocialSignIn(userCredential, 'apple.com');
      return userCredential;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'account-exists-with-different-credential') {
        throw Exception(
            'This email is registered with a different method. Please login using that method.');
      }
      throw Exception('Apple Login failed: ${e.message}');
    } catch (e) {
      if (e.toString().contains('Exception:')) rethrow;
      throw Exception('Apple Login failed: $e');
    }
  }

  /// Shared post-social-auth logic: create seller doc if new, update if existing.
  Future<void> _handleSocialSignIn(
      UserCredential credential, String provider) async {
    final user = credential.user;
    if (user == null) return;

    final existingSeller = await fetchSeller(user.uid);
    if (existingSeller == null) {
      // Check if email already exists under a different UID (conflict)
      final emailProvider = await getAuthProviderForEmail(user.email ?? '');
      if (emailProvider != null) {
        // Conflict: clean up the dangling Auth user and throw
        await user.delete();
        throw Exception(
            'This email is already registered with a different method. Please login using that method.');
      }

      try {
        await createSeller(SellerModel(
          id: user.uid,
          name: user.displayName ?? 'Seller',
          email: user.email ?? '',
          role: 'seller',
          authProvider: provider,
          isVerified: true,
          createdAt: DateTime.now(),
        ));
      } catch (_) {
        await user.delete();
        throw Exception('Failed to save Seller data. Please try again.');
      }
    } else {
      // Existing seller – update last login
      await updateSeller(user.uid, {
        'lastLoginAt': FieldValue.serverTimestamp(),
      });
    }
  }

  // ──────────────────────────────────────────────────────────────────────────
  // FORGOT PASSWORD
  // ──────────────────────────────────────────────────────────────────────────

  Future<void> sendPasswordResetEmail(String email) async {
    final provider = await getAuthProviderForEmail(email);

    if (provider == null) {
      throw Exception('No Account found for this Email.');
    }
    if (provider == 'google.com') {
      throw Exception('GOOGLE_ACCOUNT_EXISTS');
    }
    if (provider == 'apple.com') {
      throw Exception('APPLE_ACCOUNT_EXISTS');
    }

    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw Exception('Failed to send reset email: ${e.message}');
    } catch (e) {
      throw Exception('Failed to send reset email: $e');
    }
  }

  // ──────────────────────────────────────────────────────────────────────────
  // SIGN-OUT & VERIFICATION
  // ──────────────────────────────────────────────────────────────────────────

  Future<bool> checkEmailVerified() async {
    final user = _auth.currentUser;
    if (user != null) {
      await user.reload();
      return user.emailVerified;
    }
    return false;
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  // ──────────────────────────────────────────────────────────────────────────
  // OTP (Web — signInWithPhoneNumber)
  // ──────────────────────────────────────────────────────────────────────────

  Future<void> sendOtp(String phoneNumber) async {
    try {
      _confirmationResult = await _auth.signInWithPhoneNumber(phoneNumber);
    } on FirebaseAuthException catch (e) {
      throw Exception('Failed to send OTP [${e.code}]: ${e.message}');
    } catch (e) {
      throw Exception('Failed to send OTP: $e');
    }
  }

  // ──────────────────────────────────────────────────────────────────────────
  // Firestore CRUD (SellerCollection abstraction)
  // ──────────────────────────────────────────────────────────────────────────

  Future<void> createSeller(SellerModel seller) async {
    await _sellerCollection.addSeller(seller);
  }

  Future<SellerModel?> fetchSeller(String sellerId) async {
    return await _sellerCollection.getSeller(sellerId);
  }

  Future<void> updateSeller(String sellerId, Map<String, dynamic> data) async {
    await _sellerCollection.updateSeller(sellerId, data);
  }

  Future<void> deleteSeller(String sellerId) async {
    await _sellerCollection.deleteSeller(sellerId);
  }

  Stream<QuerySnapshot<SellerModel>> getSellersStream() {
    return _sellerCollection.getSellersStream();
  }
}
