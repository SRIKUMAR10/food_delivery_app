import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';
import 'route_polyline_service.dart';
import 'audio_notification_service.dart';
import 'voice_speech_helper.dart';

/// Real voice & audio guidance service for Turn-by-Turn Navigation.
/// Uses verified real-road steps to announce maneuvers at 200m, 50m, and upon arrival.
/// Supports Web Speech API (Chrome, Edge, Firefox, Safari) and Native Audio Engine (Android, iOS).
class VoiceNavigationService {
  static VoiceNavigationService? _instance;
  static VoiceNavigationService get instance =>
      _instance ??= VoiceNavigationService();

  final Logger _logger = Logger();
  final AudioNotificationService _audioService = AudioNotificationService();

  final ValueNotifier<bool> _isMutedNotifier = ValueNotifier<bool>(false);
  ValueListenable<bool> get isMutedListenable => _isMutedNotifier;
  bool get isMuted => _isMutedNotifier.value;

  String? _lastAnnouncedInstruction;
  DateTime? _lastAnnouncementTime;
  int _lastAnnouncedStepIndex = -1;
  int _lastDistanceBracket = -1; // 200, 50, 0

  void setMuted(bool muted) {
    _isMutedNotifier.value = muted;
    _logger.i('Voice Navigation Muted: $muted');
  }

  void toggleMute() {
    setMuted(!isMuted);
  }

  /// Announces a verified navigation maneuver step based on current distance to the turn.
  Future<void> announceManeuver({
    required RouteStepInfo step,
    required double distanceToStepMeters,
    int stepIndex = 0,
  }) async {
    if (isMuted) return;

    // Determine distance bracket (200m, 50m, 15m)
    int bracket = -1;
    if (distanceToStepMeters <= 20) {
      bracket = 0;
    } else if (distanceToStepMeters <= 70) {
      bracket = 50;
    } else if (distanceToStepMeters <= 250) {
      bracket = 200;
    }

    if (bracket == -1) return;

    // Check if already announced this bracket for this step
    if (_lastAnnouncedStepIndex == stepIndex &&
        _lastDistanceBracket == bracket) {
      return;
    }

    final now = DateTime.now();
    if (_lastAnnouncementTime != null &&
        now.difference(_lastAnnouncementTime!).inSeconds < 3 &&
        bracket != 0) {
      return; // Debounce fast consecutive announcements
    }

    String speechText = '';
    if (bracket == 0) {
      if (step.maneuver == RouteManeuver.arrive) {
        speechText = 'You have arrived at your destination.';
      } else {
        speechText = step.instruction;
      }
    } else if (bracket == 50) {
      speechText = 'In 50 meters, ${step.instruction}';
    } else if (bracket == 200) {
      speechText = 'In 200 meters, ${step.instruction}';
    }

    if (speechText.isNotEmpty) {
      _lastAnnouncedInstruction = speechText;
      _lastAnnouncementTime = now;
      _lastAnnouncedStepIndex = stepIndex;
      _lastDistanceBracket = bracket;

      await speak(speechText);
    }
  }

  /// Plays arrival chime and voice cue upon reaching restaurant or customer
  Future<void> announceArrival({bool isStore = false}) async {
    if (isMuted) return;

    try {
      await _audioService.playRingtone(
        ringtoneName: 'Bell Chime',
        volume: 1.0,
      );
    } catch (_) {}

    final text = isStore
        ? 'You have arrived at the restaurant pickup location.'
        : 'You have arrived at the delivery address.';
    await speak(text);
  }

  /// Synthesizes speech text or plays audio alert cue across Web and Native
  Future<void> speak(String text) async {
    if (isMuted || text.trim().isEmpty) return;

    _logger.i('[Voice Navigation]: $text');

    if (kIsWeb) {
      speakWebText(text, lang: 'en-US', rate: 1.0);
    } else {
      try {
        await _audioService.playRingtone(
          ringtoneName: 'Bell Chime',
          volume: 0.85,
        );
      } catch (_) {}
    }
  }

  /// Resets state for a new route navigation session
  void resetSession() {
    _lastAnnouncedInstruction = null;
    _lastAnnouncementTime = null;
    _lastAnnouncedStepIndex = -1;
    _lastDistanceBracket = -1;
  }
}
