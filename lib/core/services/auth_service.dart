import 'package:firebase_auth/firebase_auth.dart';

import 'i_auth_service.dart';
class FirebaseAuthService implements IAuthService {
  final FirebaseAuth _auth;

  FirebaseAuthService({FirebaseAuth? auth}) : _auth = auth ?? FirebaseAuth.instance;

  @override
  String? get currentUserId => _auth.currentUser?.uid;

  @override
  Stream<String?> get authStateChanges => _auth.authStateChanges().map((user) => user?.uid);
}
