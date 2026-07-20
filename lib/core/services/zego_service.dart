import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:zego_uikit_prebuilt_call/zego_uikit_prebuilt_call.dart';

class ZegoService {
  static Future<void> init(String userId, String userName) async {
    final appIdStr = dotenv.env['ZEGO_APP_ID'];
    final appSign = dotenv.env['ZEGO_APP_SIGN'];

    if (appIdStr == null || appSign == null || appIdStr.isEmpty || appSign.isEmpty) {
      debugPrint('ZegoCloud AppID or AppSign not found in .env');
      return;
    }

    final appId = int.tryParse(appIdStr);
    if (appId == null) {
      debugPrint('ZegoCloud AppID must be an integer');
      return;
    }

    ZegoUIKitPrebuiltCallInvitationService().init(
      appID: appId,
      appSign: appSign,
      userID: userId,
      userName: userName,
      plugins: [], // Add ZegoUIKitSignalingPlugin() here if you add the zego_uikit_signaling_plugin package
    );
  }

  static void deinit() {
    ZegoUIKitPrebuiltCallInvitationService().uninit();
  }
}
