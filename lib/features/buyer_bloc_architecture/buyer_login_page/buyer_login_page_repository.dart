import 'buyer_login_page_service.dart';

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

}
