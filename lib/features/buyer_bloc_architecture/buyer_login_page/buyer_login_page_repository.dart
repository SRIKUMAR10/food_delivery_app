import 'buyer_login_page_service.dart';
import 'buyer_login_page_state.dart';

class BuyerLoginRepository {
  final BuyerLoginService _service;

  BuyerLoginRepository({BuyerLoginService? service})
      : _service = service ?? BuyerLoginService();

  Future<bool> checkNetworkConnectivity() async {
    return await _service.checkNetworkConnectivity();
  }

  Future<String> login({
    required String phone,
    required String password,
  }) async {
    return await _service.loginWithPhoneOrEmail(
      phone: phone,
      password: password,
    );
  }

  Future<String?> loginWithGoogle() async {
    return await _service.signInWithGoogle();
  }

  Future<String?> loginWithApple() async {
    return await _service.signInWithApple();
  }

  Future<BuyerAuthProfileStatus> checkKycAndOnboardingStatus(String userId) async {
    return await _service.checkKycAndOnboardingStatus(userId);
  }
}
