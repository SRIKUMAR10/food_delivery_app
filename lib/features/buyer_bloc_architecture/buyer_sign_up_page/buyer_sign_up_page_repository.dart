import 'buyer_sign_up_page_service.dart';

class BuyerSignUpRepository {
  final BuyerSignUpService _service;

  BuyerSignUpRepository({BuyerSignUpService? service})
      : _service = service ?? BuyerSignUpService();

  Future<bool> isPhoneRegistered({required String mobileNumber}) async {
    return await _service.isPhoneRegistered(mobileNumber: mobileNumber);
  }

  Future<String> sendOtp({required String mobileNumber}) async {
    return await _service.sendOtp(mobileNumber: mobileNumber);
  }
}
