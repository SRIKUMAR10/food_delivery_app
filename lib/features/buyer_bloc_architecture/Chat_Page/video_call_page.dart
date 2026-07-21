import 'package:flutter/material.dart';
import 'package:zego_uikit_prebuilt_call/zego_uikit_prebuilt_call.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
class VideoCallPage extends StatelessWidget {
  final String callID;
  final String userID;
  final String userName;

  const VideoCallPage({
    Key? key,
    required this.callID,
    required this.userID,
    required this.userName,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final int appID = int.tryParse(dotenv.env['ZEGO_APP_ID'] ?? '0') ?? 0;
    final String appSign = dotenv.env['ZEGO_APP_SIGN'] ?? '';
    final String token = dotenv.env['ZEGO_TOKEN'] ?? '';

    final bool missingCredentials = kIsWeb 
        ? (appID == 0 || token.isEmpty) 
        : (appID == 0 || appSign.isEmpty);

    if (missingCredentials) {
      return Scaffold(
        appBar: AppBar(title: const Text('Video Call Setup')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.videocam_off, size: 64, color: Colors.red),
                const SizedBox(height: 16),
                const Text(
                  'Zego Credentials Missing',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                const Text(
                  'To use real-time video calls, you must enter your ZegoCloud credentials in .env.',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Go Back'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return SafeArea(
      child: ZegoUIKitPrebuiltCall(
        appID: appID,
        appSign: kIsWeb ? '' : appSign,
        token: kIsWeb ? token : '',
        userID: kIsWeb ? 'buyer_123' : userID,
        userName: userName,
        callID: callID,
        config: ZegoUIKitPrebuiltCallConfig.oneOnOneVideoCall(),
      ),
    );
  }
}
