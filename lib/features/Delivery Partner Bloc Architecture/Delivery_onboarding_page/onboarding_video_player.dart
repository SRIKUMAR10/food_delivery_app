import 'package:flutter/material.dart';
import 'onboarding_video_player_stub.dart'
    if (dart.library.html) 'onboarding_video_player_web.dart'
    if (dart.library.io) 'onboarding_video_player_mobile.dart';

Widget getOnboardingVideoPlayer(double height, ValueNotifier<bool> unmuteNotifier) {
  return buildVideoPlayerWidget(height, unmuteNotifier);
}
