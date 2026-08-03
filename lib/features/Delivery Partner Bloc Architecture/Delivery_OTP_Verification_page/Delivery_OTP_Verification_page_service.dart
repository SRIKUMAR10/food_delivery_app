import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';

abstract class DeliveryOtpVerificationServiceBase {
  Future<bool> checkNetworkConnectivity();
  Future<bool> requestSmsPermission();
  String formatPhoneNumber(String phone);
}

class DeliveryOtpVerificationService
    implements DeliveryOtpVerificationServiceBase {
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
  Future<bool> requestSmsPermission() async {
    return true;
  }

  @override
  String formatPhoneNumber(String phone) {
    final formatted = phone.replaceAll(RegExp(r'\s+'), '').replaceAll('-', '');
    return formatted.startsWith('+') ? formatted : '+91$formatted';
  }
}
