import 'package:flutter_bloc/flutter_bloc.dart';
import 'video_call_event.dart';
import 'video_call_state.dart';
import '../../../core/services/permission_service.dart';

class VideoCallBloc extends Bloc<VideoCallEvent, VideoCallState> {
  VideoCallBloc() : super(VideoCallInitial()) {
    on<StartVideoCall>(_onStartVideoCall);
    on<EndVideoCall>(_onEndVideoCall);
    on<VideoCallPermissionDenied>(_onPermissionDenied);
    on<VideoCallPermissionGranted>(_onPermissionGranted);
    on<VideoCallCredentialsMissing>(_onCredentialsMissing);
  }

  Future<void> _onStartVideoCall(StartVideoCall event, Emitter<VideoCallState> emit) async {
    emit(VideoCallCheckingPermissions());
    final granted = await PermissionService.requestCameraAndMicrophone();
    if (granted) {
      emit(VideoCallReady());
    } else {
      emit(VideoCallDenied(false));
    }
  }

  void _onEndVideoCall(EndVideoCall event, Emitter<VideoCallState> emit) {
    emit(VideoCallInitial());
  }

  void _onPermissionDenied(VideoCallPermissionDenied event, Emitter<VideoCallState> emit) {
    emit(VideoCallDenied(event.permanentlyDenied));
  }

  void _onPermissionGranted(VideoCallPermissionGranted event, Emitter<VideoCallState> emit) {
    emit(VideoCallReady());
  }

  void _onCredentialsMissing(VideoCallCredentialsMissing event, Emitter<VideoCallState> emit) {
    emit(VideoCallError('Zego credentials are missing. Please check your .env configuration.'));
  }
}
