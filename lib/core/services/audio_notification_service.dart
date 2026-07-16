import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:audioplayers/audioplayers.dart';
import 'package:logger/logger.dart';

class AudioNotificationService {
  AudioPlayer? _audioPlayer;
  final Logger _logger = Logger();

  AudioNotificationService() {
    if (!kIsWeb && Platform.environment.containsKey('FLUTTER_TEST')) return;
    try {
      _audioPlayer = AudioPlayer();
    } catch (e) {
      _logger.e('Failed to initialize AudioPlayer: $e');
    }
  }

  Future<void> playNewOrderSound() async {
    try {
      if (_audioPlayer == null) return;
      // Assuming an audio file exists in assets/audio/new_order.mp3
      // Make sure to add this path to pubspec.yaml assets section when the file is added.
      await _audioPlayer!.play(AssetSource('audio/new_order.mp3'));
      _logger.i('Played new order sound');
    } catch (e) {
      _logger.e('Error playing new order sound: $e');
    }
  }

  void dispose() {
    _audioPlayer?.dispose();
  }
}
