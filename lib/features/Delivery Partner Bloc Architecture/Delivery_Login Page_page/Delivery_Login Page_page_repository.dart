import 'package:shared_preferences/shared_preferences.dart';

abstract class DeliveryLoginRepositoryBase {
  Future<bool> loginWithPhone(String phone, String password);
  Future<bool> loginWithGoogle();
  Future<bool> loginWithApple();
  Future<void> saveSelectedLanguage(String languageCode);
  Future<String> getSelectedLanguage();
  Future<void> saveSavedPhone(String phone);
  Future<String?> getSavedPhone();
}

class DeliveryLoginRepository implements DeliveryLoginRepositoryBase {
  final SharedPreferences? sharedPreferences;

  DeliveryLoginRepository({this.sharedPreferences});

  @override
  Future<bool> loginWithPhone(String phone, String password) async {
    await Future.delayed(const Duration(milliseconds: 500));
    if (phone.isNotEmpty && password.length >= 6) {
      return true;
    }
    throw Exception('Invalid phone number or password');
  }

  @override
  Future<bool> loginWithGoogle() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return true;
  }

  @override
  Future<bool> loginWithApple() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return true;
  }

  @override
  Future<void> saveSelectedLanguage(String languageCode) async {
    final prefs = sharedPreferences ?? await SharedPreferences.getInstance();
    await prefs.setString('delivery_login_lang', languageCode);
  }

  @override
  Future<String> getSelectedLanguage() async {
    final prefs = sharedPreferences ?? await SharedPreferences.getInstance();
    return prefs.getString('delivery_login_lang') ?? 'en';
  }

  @override
  Future<void> saveSavedPhone(String phone) async {
    final prefs = sharedPreferences ?? await SharedPreferences.getInstance();
    await prefs.setString('delivery_login_saved_phone', phone);
  }

  @override
  Future<String?> getSavedPhone() async {
    final prefs = sharedPreferences ?? await SharedPreferences.getInstance();
    return prefs.getString('delivery_login_saved_phone');
  }
}
