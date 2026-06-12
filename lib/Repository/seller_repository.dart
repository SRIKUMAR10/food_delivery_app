import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../App Database Collections/seller_user_collection.dart';

class SellerRepository {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final SellerUserCollection _sellerCollection = SellerUserCollection();

  // Seller Auth மற்றும் தரவு சேமிப்பு செயல்பாடுகள்
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

      // Auth வெற்றிகரமாக முடிந்தால், விவரங்களை 'seller_users' collection-இல் சேமித்தல்
      if (credential.user != null) {
        await _sellerCollection.addSeller(credential.user!.uid, {
          'name': name,
          'email': email,
          'role': 'seller', // பயனர் வகை
          'createdAt': FieldValue.serverTimestamp(),
        });
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
}
