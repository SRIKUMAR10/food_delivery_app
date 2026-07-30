abstract interface class IAuthService {
  String? get currentUserId;
  String? get currentUserDisplayName;
  String? get currentUserPhotoUrl;
  String? get currentUserEmail;
  Stream<String?> get authStateChanges;
  Future<void> signOut();
  Future<void> deleteAccount(String password);
}
