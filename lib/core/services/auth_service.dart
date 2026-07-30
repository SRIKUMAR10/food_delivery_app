import 'package:firebase_auth/firebase_auth.dart';

import 'i_auth_service.dart';
class FirebaseAuthService implements IAuthService {
  final FirebaseAuth _auth;

  FirebaseAuthService({FirebaseAuth? auth}) : _auth = auth ?? FirebaseAuth.instance;

  @override
  String? get currentUserId => _auth.currentUser?.uid;

  @override
  String? get currentUserDisplayName => _auth.currentUser?.displayName;

  @override
  String? get currentUserPhotoUrl => _auth.currentUser?.photoURL;

  @override
  String? get currentUserEmail => _auth.currentUser?.email;

  @override
  Stream<String?> get authStateChanges => _auth.authStateChanges().map((user) => user?.uid);

  @override
  Future<void> signOut() async {
    await _auth.signOut();
  }

  @override
  Future<void> deleteAccount(String password) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    if (user.email != null && password.isNotEmpty) {
      final credential = EmailAuthProvider.credential(
        email: user.email!,
        password: password,
      );
      await user.reauthenticateWithCredential(credential);
    }

    await user.delete();
  }
}
