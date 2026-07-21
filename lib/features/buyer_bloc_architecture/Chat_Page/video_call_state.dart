abstract class VideoCallState {}

class VideoCallInitial extends VideoCallState {}

class VideoCallCheckingPermissions extends VideoCallState {}

class VideoCallReady extends VideoCallState {}

class VideoCallActive extends VideoCallState {}

class VideoCallDenied extends VideoCallState {
  final bool permanentlyDenied;
  VideoCallDenied(this.permanentlyDenied);
}

class VideoCallError extends VideoCallState {
  final String message;
  VideoCallError(this.message);
}
