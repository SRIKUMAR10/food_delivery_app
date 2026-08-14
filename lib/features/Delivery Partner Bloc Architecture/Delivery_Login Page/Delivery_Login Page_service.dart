import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

abstract class DeliveryLoginServiceBase {
  Future<bool> checkNetworkConnectivity();
}

class DeliveryLoginService implements DeliveryLoginServiceBase {
  @override
  Future<bool> checkNetworkConnectivity() async {
    try {
      if (kIsWeb) {
        final response = await http
            .get(Uri.parse('https://www.google.com'))
            .timeout(const Duration(seconds: 4));
        return response.statusCode >= 200 && response.statusCode < 400;
      } else {
        final result = await InternetAddress.lookup('google.com')
            .timeout(const Duration(seconds: 4));
        if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
          return true;
        }
      }
    } catch (_) {
      try {
        final response = await http
            .get(Uri.parse('https://www.google.com'))
            .timeout(const Duration(seconds: 4));
        return response.statusCode >= 200 && response.statusCode < 400;
      } catch (_) {
        return false;
      }
    }
    return false;
  }
}

