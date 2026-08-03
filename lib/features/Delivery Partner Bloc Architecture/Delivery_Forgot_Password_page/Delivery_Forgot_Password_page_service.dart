import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';

abstract class DeliveryForgotPasswordServiceBase {
  Future<bool> checkNetworkConnectivity();
  String? validateEmail(String email);
}

class DeliveryForgotPasswordService
    implements DeliveryForgotPasswordServiceBase {
  static final RegExp _emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

  @override
  Future<bool> checkNetworkConnectivity() async {
    if (kIsWeb) {
      return true;
    }
    try {
      final result = await InternetAddress.lookup('google.com')
          .timeout(const Duration(seconds: 5));
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } on SocketException {
      return false;
    } on TimeoutException {
      return false;
    } catch (_) {
      return false;
    }
  }

  @override
  String? validateEmail(String email) {
    if (email.trim().isEmpty) {
      return 'Please enter your email address';
    }
    if (!_emailRegex.hasMatch(email.trim())) {
      return 'Please enter a valid email address';
    }
    return null;
  }
}
