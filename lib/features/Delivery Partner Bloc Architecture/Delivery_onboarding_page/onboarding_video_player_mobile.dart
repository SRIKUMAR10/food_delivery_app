import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

Widget buildVideoPlayerWidget(double height, ValueNotifier<bool> unmuteNotifier) {
  return MobileVideoPlayer(height: height, unmuteNotifier: unmuteNotifier);
}

class MobileVideoPlayer extends StatefulWidget {
  final double height;
  final ValueNotifier<bool> unmuteNotifier;

  const MobileVideoPlayer({
    Key? key,
    required this.height,
    required this.unmuteNotifier,
  }) : super(key: key);

  @override
  State<MobileVideoPlayer> createState() => _MobileVideoPlayerState();
}

class _MobileVideoPlayerState extends State<MobileVideoPlayer> {
  VideoPlayerController? _videoController;

  @override
  void initState() {
    super.initState();
    _initVideo();
    widget.unmuteNotifier.addListener(_handleUnmuteChange);
  }

  void _initVideo() {
    _videoController = VideoPlayerController.asset('assets/videos/delivery_scooter.mp4')
      ..initialize().then((_) {
        _videoController!.setLooping(true);
        _videoController!.setVolume(0.0); // Start muted to guarantee autoplay
        _videoController!.play();
        if (mounted) setState(() {});
      });
  }

  void _handleUnmuteChange() {
    if (_videoController != null && _videoController!.value.isInitialized) {
      if (widget.unmuteNotifier.value) {
        _videoController!.setVolume(1.0);
      } else {
        _videoController!.setVolume(0.0);
      }
    }
  }

  @override
  void dispose() {
    widget.unmuteNotifier.removeListener(_handleUnmuteChange);
    _videoController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_videoController == null || !_videoController!.value.isInitialized) {
      return SizedBox(height: widget.height);
    }
    return SizedBox(
      height: widget.height,
      child: FittedBox(
        fit: BoxFit.contain,
        child: SizedBox(
          width: _videoController!.value.size.width,
          height: _videoController!.value.size.height,
          child: VideoPlayer(_videoController!),
        ),
      ),
    );
  }
}
