import 'package:food_delivery_app/repositories/user_repository.dart';

class BuyerLoginService {
  final UserRepository _userRepository;

  BuyerLoginService({UserRepository? userRepository})
      : _userRepository = userRepository ?? UserRepository();

  Future<String> loginWithPhoneOrEmail({
    required String phone,
    required String password,
  }) async {
    if (phone.trim().isEmpty) {
      throw Exception('Please enter your phone number or email.');
    }
    if (password.trim().isEmpty) {
      throw Exception('Please enter your password.');
    }

    final credential = await _userRepository.signInWithPhoneOrEmail(
      identifier: phone.trim(),
      password: password,
    );

    final user = credential.user;
    if (user == null) {
      throw Exception('Login failed: Authentication returned null user.');
    }

    return user.uid;
  }

  Future<String?> signInWithGoogle() async {
    final credential = await _userRepository.signInWithGoogle();
    return credential.user?.uid;
  }
}


