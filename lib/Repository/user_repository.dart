import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../App Database Collections/user_collection.dart';

class UserRepository {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final UserCollection _userCollection = UserCollection();

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

      // Store user details in Firestore after successful Auth
      if (credential.user != null) {
        await _userCollection.addUser(credential.user!.uid, {
          'name': name,
          'email': email,
          'createdAt': FieldValue.serverTimestamp(),
        });
      }
      return credential;
    } catch (e) {
      throw Exception('SignUp failed: $e');
    }
  }

  Future<UserCredential> signIn(String email, String password) async {
    try {
      return await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
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
