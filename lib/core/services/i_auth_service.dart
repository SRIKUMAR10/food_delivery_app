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
}
