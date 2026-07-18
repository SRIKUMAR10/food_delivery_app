abstract interface class IAuthService {
  String? get currentUserId;
  Stream<String?> get authStateChanges;
}
