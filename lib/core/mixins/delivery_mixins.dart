import 'package:flutter/material.dart';

mixin AnimationLifecycleMixin<T extends StatefulWidget> on State<T> {
  final List<AnimationController> _controllers = [];

  void registerAnimationController(AnimationController controller) {
    _controllers.add(controller);
  }

  void unregisterAnimationController(AnimationController controller) {
    _controllers.remove(controller);
  }

  void pauseAllAnimations() {
    for (final c in _controllers) {
      if (c.isAnimating) c.stop();
    }
  }

  void resumeAllAnimations() {
    for (final c in _controllers) {
      if (c.isCompleted || c.isDismissed) {
        c.repeat(reverse: c.status == AnimationStatus.completed);
      }
    }
  }

  void didChangeTabVisibility(bool visible) {
    if (visible) {
      resumeAllAnimations();
    } else {
      pauseAllAnimations();
    }
  }
}

mixin BatteryAwareMixin<T extends StatefulWidget> on State<T> {
  bool _lowPowerMode = false;

  bool get isLowPowerMode => _lowPowerMode;

  void setLowPowerMode(bool low) {
    if (low == _lowPowerMode) return;
    _lowPowerMode = low;
    onLowPowerChanged(low);
  }

  void onLowPowerChanged(bool low) {}

  double get animationDurationMultiplier => _lowPowerMode ? 0.3 : 1.0;
  bool get shouldDisableAnimations => _lowPowerMode;
}

mixin VisibilityReportingMixin<T extends StatefulWidget> on State<T> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      onScreenVisible();
    });
  }

  void onScreenVisible() {}

  void onScreenHidden() {}
}
