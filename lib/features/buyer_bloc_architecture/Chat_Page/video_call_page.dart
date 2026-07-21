import 'package:flutter/material.dart';
import 'package:zego_uikit_prebuilt_call/zego_uikit_prebuilt_call.dart';

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
    // Note: ZegoUIKit requires valid appID and appSign.
    // For a real-time production app, these must be replaced with real credentials from ZegoCloud Console.
    const int dummyAppID = 0; 
    const String dummyAppSign = '';

    if (dummyAppID == 0 || dummyAppSign.isEmpty) {
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
                  'To use real-time video calls, you must enter your ZegoCloud AppID and AppSign in video_call_page.dart. The call cannot connect with dummy credentials.',
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
        appID: dummyAppID,
        appSign: dummyAppSign,
        userID: userID,
        userName: userName,
        callID: callID,
        config: ZegoUIKitPrebuiltCallConfig.oneOnOneVideoCall(),
      ),
    );
  }
}
