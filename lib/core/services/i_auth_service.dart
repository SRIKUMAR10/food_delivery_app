import 'package:firebase_auth/firebase_auth.dart';

abstract interface class IAuthService {
  String? get currentUserId;
  String? get currentUserDisplayName;
  String? get currentUserPhotoUrl;
  String? get currentUserEmail;
  Stream<String?> get authStateChanges;
  Future<void> signOut();
  Future<void> deleteAccount(String password);

  /// Ensures the Firebase ID token is refreshed and propagated before
  /// opening Firestore listeners. Prevents [cloud_firestore/permission-denied]
  /// race conditions that occur when the Firestore WebChannel opens before
  /// the auth token is fully applied.
  Future<void> ensureTokenReady();

  /// Sends a password reset email using specified or default [ActionCodeSettings].
  Future<void> sendPasswordResetEmail(String email, {ActionCodeSettings? actionCodeSettings});

  /// Sends an email verification link to the current user using specified or default [ActionCodeSettings].
  Future<void> sendEmailVerification({ActionCodeSettings? actionCodeSettings});

  /// Sends an email sign-in link to the specified email using [ActionCodeSettings].
  Future<void> sendSignInLinkToEmail(String email, {ActionCodeSettings? actionCodeSettings});

  /// Checks if an incoming link is a valid Firebase email sign-in link.
  bool isSignInWithEmailLink(String emailLink);

  /// Completes sign-in with an email link.
  Future<UserCredential> signInWithEmailLink({required String email, required String emailLink});
}

