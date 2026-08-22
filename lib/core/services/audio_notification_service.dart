import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show VoidCallback, kIsWeb;
import 'package:audioplayers/audioplayers.dart';
import 'package:logger/logger.dart';

/// Plays local alert chime assets for new orders and ringtone previews.
/// Safe across Web, Android, iOS, Windows, macOS and Linux.
class AudioNotificationService {
  static const Map<String, String> ringtoneAssets = {
    'Bell Chime': 'audio/bell_chime.wav',
    'Digital Siren': 'audio/digital_siren.wav',
    'Classic Phone Ring': 'audio/phone_ring.wav',
    'Kitchen Buzzer': 'audio/kitchen_buzzer.wav',
  };

  static const String defaultRingtone = 'Bell Chime';

  static double _globalVolume = 0.8;
  static String _globalRingtone = defaultRingtone;

  /// Updates global audio preferences so all callers automatically use the saved volume and ringtone.
  static void setGlobalAudioConfig({double? volume, String? ringtone}) {
    if (volume != null) _globalVolume = volume.clamp(0.0, 1.0);
    if (ringtone != null && ringtone.isNotEmpty) _globalRingtone = ringtone;
  }

  static double get globalVolume => _globalVolume;
  static String get globalRingtone => _globalRingtone;

  AudioPlayer? _audioPlayer;
  final Logger _logger = Logger();
  bool _isPreviewPlaying = false;

  /// Invoked when a ringtone preview finishes naturally.
  VoidCallback? onRingtoneComplete;

  AudioNotificationService({this.onRingtoneComplete}) {
    if (!kIsWeb && Platform.environment.containsKey('FLUTTER_TEST')) return;
    try {
      _audioPlayer = AudioPlayer();
      _audioPlayer!.onPlayerComplete.listen((_) {
        _isPreviewPlaying = false;
        onRingtoneComplete?.call();
      });
    } catch (e) {
      _logger.e('Failed to initialize AudioPlayer: $e');
    }
  }

  bool get isPreviewPlaying => _isPreviewPlaying;

  /// Maps a ringtone display name to its bundled asset path.
  /// Falls back to the standard bell chime for unknown names.
  static String assetForRingtone(String ringtoneName) {
    return ringtoneAssets[ringtoneName] ?? ringtoneAssets[defaultRingtone]!;
  }

  /// Plays the selected alert ringtone at the given volume.
  /// When [loop] is true the tone repeats until [stop] is called.
  Future<void> playRingtone({
    required String ringtoneName,
    double? volume,
    bool loop = false,
  }) async {
    final effectiveVolume = (volume ?? _globalVolume).clamp(0.0, 1.0);
    _globalVolume = effectiveVolume;
    _globalRingtone = ringtoneName;

    try {
      final player = _audioPlayer;
      if (player == null) return;
      await player.stop();
      await player.setVolume(effectiveVolume);
      await player.setReleaseMode(loop ? ReleaseMode.loop : ReleaseMode.stop);
      _isPreviewPlaying = true;
      await player.play(AssetSource(assetForRingtone(ringtoneName)));
      await player.setVolume(effectiveVolume);
      _logger.i('Played ringtone: $ringtoneName at volume $effectiveVolume (loop: $loop)');
    } catch (e) {
      _logger.e('Error playing ringtone $ringtoneName: $e');
      _isPreviewPlaying = false;
    }
  }

  /// Halts any active playback or looping preview.
  Future<void> stop() async {
    _isPreviewPlaying = false;
    try {
      final player = _audioPlayer;
      if (player != null) {
        await player.stop();
        await player.setReleaseMode(ReleaseMode.stop);
      }
    } catch (e) {
      _logger.e('Error stopping audio: $e');
    }
  }

  Future<void> playNewOrderSound({
    String? ringtoneName,
    double? volume,
    bool loop = false,
  }) async {
    final targetRingtone = ringtoneName ?? _globalRingtone;
    final targetVolume = (volume ?? _globalVolume).clamp(0.0, 1.0);
    try {
      if (_audioPlayer == null) return;
      await playRingtone(
        ringtoneName: targetRingtone,
        volume: targetVolume,
        loop: loop,
      );
      _logger.i('Played new order sound: $targetRingtone (vol: $targetVolume, loop: $loop)');
    } catch (e) {
      _logger.e('Error playing new order sound: $e');
    }
  }

  void dispose() {
    _isPreviewPlaying = false;
    _audioPlayer?.dispose();
  }
}