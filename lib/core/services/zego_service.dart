import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:zego_uikit_prebuilt_call/zego_uikit_prebuilt_call.dart'
    if (dart.library.html) 'zego_service_stub.dart';

class ZegoService {
  static Future<void> init(String userId, String userName) async {
    if (kIsWeb) {
      return;
    }

    final appIdStr = dotenv.env['ZEGO_APP_ID'];
    final appSign = dotenv.env['ZEGO_APP_SIGN'];

    if (appIdStr == null || appIdStr.isEmpty) {
      debugPrint('ZegoCloud AppID not found in .env');
      return;
    }

    if (appSign == null || appSign.isEmpty) {
      debugPrint('ZegoCloud AppSign not found in .env');
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
      plugins: [],
    );
  }

  static void deinit() {
    if (kIsWeb) return;
    ZegoUIKitPrebuiltCallInvitationService().uninit();
  }
}
