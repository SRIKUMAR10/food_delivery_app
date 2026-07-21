class VideoCallEvent {}

class StartVideoCall extends VideoCallEvent {
  final String callID;
  final String userID;
  final String userName;
  StartVideoCall({required this.callID, required this.userID, required this.userName});
}

class EndVideoCall extends VideoCallEvent {}

class VideoCallPermissionDenied extends VideoCallEvent {
  final bool permanentlyDenied;
  VideoCallPermissionDenied(this.permanentlyDenied);
}

class VideoCallPermissionGranted extends VideoCallEvent {}

class VideoCallCredentialsMissing extends VideoCallEvent {}
