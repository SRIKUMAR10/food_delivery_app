import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_auth_config.dart';
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

  /// Forces the Firebase ID token to be refreshed and awaited so that
  /// Firestore's WebChannel is guaranteed to have a valid auth credential
  /// before any real-time listener is opened. Without this, a race condition
  /// between the auth state change callback and Firestore's internal token
  /// propagation causes [cloud_firestore/permission-denied].
  @override
  Future<void> ensureTokenReady() async {
    final user = _auth.currentUser;
    if (user != null) {
      // forceRefresh: false reuses the cached token if still valid,
      // but guarantees the token object exists and is applied to the
      // Firestore WebChannel before we return.
      await user.getIdToken(false);
    }
  }

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

  @override
  Future<void> sendPasswordResetEmail(String email, {ActionCodeSettings? actionCodeSettings}) async {
    final settings = actionCodeSettings ?? FirebaseAuthConfig.defaultActionCodeSettings;
    await _auth.sendPasswordResetEmail(
      email: email,
      actionCodeSettings: settings,
    );
  }

  @override
  Future<void> sendEmailVerification({ActionCodeSettings? actionCodeSettings}) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('No user currently signed in.');
    final settings = actionCodeSettings ?? FirebaseAuthConfig.defaultActionCodeSettings;
    await user.sendEmailVerification(settings);
  }

  @override
  Future<void> sendSignInLinkToEmail(String email, {ActionCodeSettings? actionCodeSettings}) async {
    final settings = actionCodeSettings ?? FirebaseAuthConfig.defaultActionCodeSettings;
    await _auth.sendSignInLinkToEmail(
      email: email,
      actionCodeSettings: settings,
    );
  }

  @override
  bool isSignInWithEmailLink(String emailLink) {
    return _auth.isSignInWithEmailLink(emailLink);
  }

  @override
  Future<UserCredential> signInWithEmailLink({required String email, required String emailLink}) async {
    return await _auth.signInWithEmailLink(
      email: email,
      emailLink: emailLink,
    );
  }
}

