import 'package:permission_handler/permission_handler.dart';

class PermissionService {
  static Future<bool> requestCameraAndMicrophone() async {
    final cameraStatus = await Permission.camera.request();
    final micStatus = await Permission.microphone.request();
    return cameraStatus.isGranted && micStatus.isGranted;
  }

  static Future<bool> requestCameraOnly() async {
    final cameraStatus = await Permission.camera.request();
    return cameraStatus.isGranted;
  }

  static Future<bool> requestMicrophoneOnly() async {
    final micStatus = await Permission.microphone.request();
    return micStatus.isGranted;
  }

  static Future<PermissionStatus> getCameraStatus() async {
    return await Permission.camera.status;
  }

  static Future<PermissionStatus> getMicrophoneStatus() async {
    return await Permission.microphone.status;
  }

  static Future<bool> hasCameraAndMicrophone() async {
    final cameraStatus = await Permission.camera.status;
    final micStatus = await Permission.microphone.status;
    return cameraStatus.isGranted && micStatus.isGranted;
  }

  static bool isPermanentlyDenied(PermissionStatus status) {
    return status.isPermanentlyDenied;
  }
}
