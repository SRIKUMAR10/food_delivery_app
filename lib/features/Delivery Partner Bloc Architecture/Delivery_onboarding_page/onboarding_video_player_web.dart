import 'dart:html' as html;
import 'dart:ui_web' as ui_web;
import 'package:flutter/material.dart';

Widget buildVideoPlayerWidget(double height, ValueNotifier<bool> unmuteNotifier) {
  return WebVideoPlayer(height: height, unmuteNotifier: unmuteNotifier);
}

class WebVideoPlayer extends StatefulWidget {
  final double height;
  final ValueNotifier<bool> unmuteNotifier;

  const WebVideoPlayer({
    Key? key,
    required this.height,
    required this.unmuteNotifier,
  }) : super(key: key);

  @override
  State<WebVideoPlayer> createState() => _WebVideoPlayerState();
}

class _WebVideoPlayerState extends State<WebVideoPlayer> {
  late html.VideoElement _videoElement;
  final String _viewId = 'onboarding-video-element';
  static bool _viewRegistered = false;

  @override
  void initState() {
    super.initState();

    _videoElement = html.VideoElement()
      ..autoplay = true
      ..loop = true
      ..muted = true
      ..setAttribute('playsinline', 'true')
      ..style.width = '100%'
      ..style.height = '100%'
      ..style.objectFit = 'contain';

    // Support both transparent WebM and fall-back MP4
    final html.SourceElement webmSource = html.SourceElement()
      ..src = 'assets/videos/delivery_scooter1.webm'
      ..type = 'video/webm';

    final html.SourceElement mp4Source = html.SourceElement()
      ..src = 'assets/videos/delivery_scooter.mp4'
      ..type = 'video/mp4';

    _videoElement.append(webmSource);
    _videoElement.append(mp4Source);

    // Disabled screen blend mode because transparent WebM does not need it (preserves black parts):
    // _videoElement.style.mixBlendMode = 'screen';

    if (!_viewRegistered) {
      ui_web.platformViewRegistry.registerViewFactory(
        _viewId,
        (int viewId) => _videoElement,
      );
      _viewRegistered = true;
    }

    widget.unmuteNotifier.addListener(_handleUnmuteChange);
  }

  void _handleUnmuteChange() {
    if (widget.unmuteNotifier.value) {
      _videoElement.muted = false;
    } else {
      _videoElement.muted = true;
    }
  }

  @override
  void dispose() {
    widget.unmuteNotifier.removeListener(_handleUnmuteChange);
    _videoElement.pause();
    _videoElement.src = '';
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: widget.height,
      child: HtmlElementView(viewType: _viewId),
    );
  }
}
