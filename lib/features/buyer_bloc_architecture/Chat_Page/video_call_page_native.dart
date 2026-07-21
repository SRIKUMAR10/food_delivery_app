import 'package:flutter/material.dart';
import 'package:zego_uikit_prebuilt_call/zego_uikit_prebuilt_call.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../../../core/services/permission_service.dart';

class VideoCallPage extends StatefulWidget {
  final String callID;
  final String userID;
  final String userName;

  const VideoCallPage({
    super.key,
    required this.callID,
    required this.userID,
    required this.userName,
  });

  @override
  State<VideoCallPage> createState() => _VideoCallPageState();
}

class _VideoCallPageState extends State<VideoCallPage> {
  bool _permissionsGranted = false;
  bool _checkingPermissions = true;
  bool _permanentlyDenied = false;

  @override
  void initState() {
    super.initState();
    _checkPermissions();
  }

  Future<void> _checkPermissions() async {
    if (kIsWeb) {
      setState(() {
        _permissionsGranted = true;
        _checkingPermissions = false;
      });
      return;
    }

    final granted = await PermissionService.requestCameraAndMicrophone();
    if (!mounted) return;

    if (granted) {
      setState(() {
        _permissionsGranted = true;
        _checkingPermissions = false;
      });
    } else {
      final cameraDenied = PermissionService.isPermanentlyDenied(
        await PermissionService.getCameraStatus(),
      );
      final micDenied = PermissionService.isPermanentlyDenied(
        await PermissionService.getMicrophoneStatus(),
      );
      setState(() {
        _permissionsGranted = false;
        _checkingPermissions = false;
        _permanentlyDenied = cameraDenied || micDenied;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final int appID = int.tryParse(dotenv.env['ZEGO_APP_ID'] ?? '0') ?? 0;
    final String appSign = dotenv.env['ZEGO_APP_SIGN'] ?? '';
    final String token = dotenv.env['ZEGO_TOKEN'] ?? '';

    final bool missingCredentials = kIsWeb
        ? (appID == 0 || token.isEmpty)
        : (appID == 0 || appSign.isEmpty);

    if (_checkingPermissions) {
      return Scaffold(
        appBar: AppBar(title: const Text('Video Call')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (!_permissionsGranted) {
      return Scaffold(
        appBar: AppBar(title: const Text('Video Call')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.videocam_off, size: 64, color: Colors.red),
                const SizedBox(height: 16),
                const Text(
                  'Camera & Microphone Access Required',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                Text(
                  _permanentlyDenied
                      ? 'Camera and microphone permissions were permanently denied. Please enable them in your device settings.'
                      : 'Camera and microphone permissions are required for video calls.',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                if (_permanentlyDenied)
                  ElevatedButton(
                    onPressed: () => PermissionService.requestCameraAndMicrophone(),
                    child: const Text('Open Settings'),
                  )
                else
                  ElevatedButton(
                    onPressed: () {
                      setState(() => _checkingPermissions = true);
                      _checkPermissions();
                    },
                    child: const Text('Try Again'),
                  ),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Go Back'),
                ),
              ],
            ),
          ),
        ),
      );
    }

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
        userID: widget.userID,
        userName: widget.userName,
        callID: widget.callID,
        config: ZegoUIKitPrebuiltCallConfig.oneOnOneVideoCall(),
      ),
    );
  }
}
