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
    double volume = 1.0,
    bool loop = false,
  }) async {
    try {
      final player = _audioPlayer;
      if (player == null) return;
      await player.stop();
      await player.setVolume(volume.clamp(0.0, 1.0));
      await player.setReleaseMode(loop ? ReleaseMode.loop : ReleaseMode.stop);
      _isPreviewPlaying = true;
      await player.play(AssetSource(assetForRingtone(ringtoneName)));
      _logger.i('Played ringtone: $ringtoneName at volume $volume');
    } catch (e) {
      _logger.e('Error playing ringtone $ringtoneName: $e');
      _isPreviewPlaying = false;
    }
  }

  /// Halts any active playback or looping preview.
  Future<void> stop() async {
    _isPreviewPlaying = false;
    try {
      await _audioPlayer?.stop();
    } catch (e) {
      _logger.e('Error stopping audio: $e');
    }
  }

  Future<void> playNewOrderSound() async {
    try {
      if (_audioPlayer == null) return;
      await _audioPlayer!.play(AssetSource('audio/new_order.wav'));
      _logger.i('Played new order sound');
    } catch (e) {
      _logger.e('Error playing new order sound: $e');
    }
  }

  void dispose() {
    _isPreviewPlaying = false;
    _audioPlayer?.dispose();
  }
}