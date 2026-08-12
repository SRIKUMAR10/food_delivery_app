import 'package:food_delivery_app/app_data_collection/buyer%20collection/user_collection.dart';
import 'package:food_delivery_app/repositories/user_repository.dart';

class BuyerSignUpService {
  final UserCollection _userCollection;
  final UserRepository _userRepository;

  BuyerSignUpService({
    UserCollection? userCollection,
    UserRepository? userRepository,
  })  : _userCollection = userCollection ?? UserCollection(),
        _userRepository = userRepository ?? UserRepository();

  /// Checks if mobile number already exists specifically in the buyer_user collection in Firestore
  Future<bool> isPhoneRegistered({required String mobileNumber}) async {
    return await _userCollection.isPhoneInBuyerCollection(mobileNumber);
  }

  /// Sends OTP via Firebase Phone Auth with ReCAPTCHA support
  Future<String> sendOtp({required String mobileNumber}) async {
    return await _userRepository.initiatePhoneAuth(mobileNumber);
  }
}

