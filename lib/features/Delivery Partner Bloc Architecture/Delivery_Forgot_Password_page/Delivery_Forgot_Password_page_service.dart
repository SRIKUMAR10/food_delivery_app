import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';

abstract class DeliveryForgotPasswordServiceBase {
  Future<bool> checkNetworkConnectivity();
  String? validatePhone(String phone);
  String? validateOtp(String otp);
  String? validatePassword(String password);
  String? validateConfirmPassword(String password, String confirmPassword);
}

class DeliveryForgotPasswordService
    implements DeliveryForgotPasswordServiceBase {
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
  String? validatePhone(String phone) {
    final cleaned = phone.replaceAll(RegExp(r'\s+'), '').replaceAll('-', '');
    if (cleaned.isEmpty) {
      return 'Please enter your phone number';
    }
    if (cleaned.length < 10) {
      return 'Please enter a valid 10-digit phone number';
    }
    return null;
  }

  @override
  String? validateOtp(String otp) {
    if (otp.trim().isEmpty) {
      return 'Please enter the OTP';
    }
    if (otp.trim().length != 6) {
      return 'OTP must be 6 digits';
    }
    return null;
  }

  @override
  String? validatePassword(String password) {
    if (password.isEmpty) {
      return 'Please enter your password';
    }
    if (password.length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }

  @override
  String? validateConfirmPassword(String password, String confirmPassword) {
    if (confirmPassword.isEmpty) {
      return 'Please confirm your password';
    }
    if (password != confirmPassword) {
      return 'Passwords do not match';
    }
    return null;
  }
}
