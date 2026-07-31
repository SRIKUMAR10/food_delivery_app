import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';

abstract class DeliverySignUpServiceBase {
  Future<bool> checkNetworkConnectivity();
}

class DeliverySignUpService implements DeliverySignUpServiceBase {
  @override
  Future<bool> checkNetworkConnectivity() async {
    if (kIsWeb) {
      return true;
    }
    try {
      final result = await InternetAddress.lookup('google.com')
          .timeout(const Duration(seconds: 5));
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } catch (_) {
      return false;
    }
  }
}
