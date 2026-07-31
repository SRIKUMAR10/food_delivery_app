import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';

abstract class DeliveryLoginServiceBase {
  Future<bool> checkNetworkConnectivity();
}

class DeliveryLoginService implements DeliveryLoginServiceBase {
  @override
  Future<bool> checkNetworkConnectivity() async {
    if (kIsWeb) {
      return true;
    }
    try {
      final result = await InternetAddress.lookup('google.com')
          .timeout(const Duration(seconds: 5));
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } on SocketException catch (_) {
      return false;
    } on TimeoutException catch (_) {
      return false;
    } catch (_) {
      return false;
    }
  }
}
