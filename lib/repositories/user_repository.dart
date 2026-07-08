import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:food_delivery_app/app_data_collection/buyer%20collection/user_collection.dart';
import 'package:food_delivery_app/repositories/auth_linking_service.dart';

class UserRepository {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final UserCollection _userCollection = UserCollection();
  final AuthLinkingService _authLinkingService = AuthLinkingService();

  // Centralized Auth operations
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
        await _userCollection.addUser(credential.user!.uid, {
          'name': name,
          'email': email,
          'wallet': 0.0,
          'createdAt': FieldValue.serverTimestamp(),
        });
        
        // Send email verification link
        if (!credential.user!.emailVerified) {
          await credential.user!.sendEmailVerification();
        }
      }
      return credential;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use' || e.code == 'account-exists-with-different-credential') {
        throw Exception(
            'An account with this email already exists. Please sign in using your existing method (e.g., Google or Password) to link this credential.');
      }
      throw Exception('SignUp failed: ${e.message}');
    } catch (e) {
      throw Exception('SignUp failed: $e');
    }
  }

  Future<UserCredential> signIn(String email, String password) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      // Check for email verification (optional strict enforcement)
      // if (credential.user != null && !credential.user!.emailVerified) {
      //   await _auth.signOut();
      //   throw Exception('Please verify your email before logging in.');
      // }
      
      return credential;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'account-exists-with-different-credential') {
         throw Exception(
            'An account with this email exists but uses a different sign-in method. Please sign in with that method to link your account.');
      }
      throw Exception('SignIn failed: ${e.message}');
    } catch (e) {
      throw Exception('SignIn failed: $e');
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  // Centralized Firestore operations
  Future<void> updateUserInfo(String uid, Map<String, dynamic> data) async {
    return await _userCollection.updateUser(uid, data);
  }

  Future<Map<String, dynamic>?> getUserData(String uid) async {
    final doc = await _userCollection.getUser(uid);
    if (doc.exists) {
      return doc.data() as Map<String, dynamic>?;
    }
    return null;
  }
}
