import 'package:flutter/material.dart';
import 'package:zego_uikit_prebuilt_call/zego_uikit_prebuilt_call.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class VoiceCallPage extends StatelessWidget {
  final String callID;
  final String userID;
  final String userName;

  const VoiceCallPage({
    super.key,
    required this.callID,
    required this.userID,
    required this.userName,
  });

  @override
  Widget build(BuildContext context) {
    final int appID = int.tryParse(dotenv.maybeGet('ZEGO_APP_ID') ?? '0') ?? 0;
    final String token = dotenv.maybeGet('ZEGO_TOKEN') ?? '';

    final bool missingCredentials = appID == 0 || token.isEmpty;

    if (missingCredentials) {
      return Scaffold(
        appBar: AppBar(title: const Text('Voice Call Setup')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.mic_off, size: 64, color: Colors.red),
                const SizedBox(height: 16),
                const Text(
                  'Zego Credentials Missing',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                const Text(
                  'To use real-time voice calls on Web, you must enter your ZegoCloud ZEGO_APP_ID and ZEGO_TOKEN in .env.',
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
        appSign: '', // Not used on Web
        token: token,
        userID: userID,
        userName: userName,
        callID: callID,
        config: ZegoUIKitPrebuiltCallConfig.oneOnOneVoiceCall(),
      ),
    );
  }
}
