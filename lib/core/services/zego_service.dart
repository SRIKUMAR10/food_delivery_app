import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:zego_uikit_prebuilt_call/zego_uikit_prebuilt_call.dart'
    if (dart.library.html) 'zego_service_stub.dart';

class ZegoService {
  static const String _cloudFunctionUrl =
      'https://us-central1-food-delivery-app-cd4ca.cloudfunctions.net/generateZegoToken';

  /// Initializes ZegoCloud using credentials fetched securely from the
  /// `generateZegoToken` Cloud Function. Falls back to `.env` for non-web
  /// platforms when authentication is unavailable.
  static Future<void> init(String userId, String userName, {String roomId = 'default_room'}) async {
    if (kIsWeb) {
      return;
    }

    int? appId;
    String? appSign;

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final idToken = await user.getIdToken();
        final response = await http.post(
          Uri.parse(_cloudFunctionUrl),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $idToken',
          },
          body: jsonEncode({
            'userId': userId,
            'roomId': roomId,
          }),
        );

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body) as Map<String, dynamic>;
          appId = data['appId'] as int?;
          appSign = data['appSign'] as String?;
        }
      }
    } catch (e) {
      debugPrint('ZegoCloud CF init failed, falling back to .env: $e');
    }

    appId ??= int.tryParse(dotenv.maybeGet('ZEGO_APP_ID') ?? '');
    appSign ??= dotenv.maybeGet('ZEGO_APP_SIGN');

    if (appId == null || appSign == null || appSign.isEmpty) {
      debugPrint('ZegoCloud credentials not available');
      return;
    }

    ZegoUIKitPrebuiltCallInvitationService().init(
      appID: appId,
      appSign: appSign,
      userID: userId,
      userName: userName,
      plugins: [],
    );
  }

  static void deinit() {
    if (kIsWeb) return;
    ZegoUIKitPrebuiltCallInvitationService().uninit();
  }
}
