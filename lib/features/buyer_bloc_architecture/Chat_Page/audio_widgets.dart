import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class AudioPlayerWidget extends StatefulWidget {
  final String audioUrl;

  const AudioPlayerWidget({Key? key, required this.audioUrl}) : super(key: key);

  @override
  State<AudioPlayerWidget> createState() => _AudioPlayerWidgetState();
}

class _AudioPlayerWidgetState extends State<AudioPlayerWidget> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isPlaying = false;
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;

  @override
  void initState() {
    super.initState();
    print('AudioPlayerWidget initialized with URL: ${widget.audioUrl}');
    
    // Do not preload immediately using setSourceUrl to avoid WebM stream errors
    _initAudio();

    _audioPlayer.onPlayerStateChanged.listen((state) {
      print('4. [Playback] PlayerState changed: $state');
      if (mounted) setState(() => _isPlaying = state == PlayerState.playing);
    });

    _audioPlayer.onDurationChanged.listen((newDuration) {
      print('4. [Playback] Duration changed: $newDuration');
      if (mounted) setState(() => _duration = newDuration);
    });

    _audioPlayer.onPositionChanged.listen((newPosition) {
      if (newPosition.inSeconds % 5 == 0) {
        print('4. [Playback] Position changed: $newPosition');
      }
      if (mounted) setState(() => _position = newPosition);
    });
    
    _audioPlayer.onPlayerComplete.listen((event) {
      print('4. [Playback] Player Complete');
    });
  }

  Future<void> _initAudio() async {
    try {
      await _audioPlayer.setSource(UrlSource(widget.audioUrl));
    } catch (e) {
      print('AudioPlayer init error: $e');
    }
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  String _formatDuration(Duration d) {
    String minutes = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    String seconds = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    double maxDuration = _duration.inSeconds.toDouble() > 0 ? _duration.inSeconds.toDouble() : 1.0;
    double currentPosition = _position.inSeconds.toDouble();
    if (currentPosition > maxDuration) {
      currentPosition = maxDuration;
    }
    if (currentPosition < 0) currentPosition = 0;

    return Container(
      width: 200,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.black12,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: Icon(
              _isPlaying ? Icons.pause_circle_filled : Icons.play_circle_filled,
              color: Colors.white,
            ),
            onPressed: () async {
              if (_isPlaying) {
                await _audioPlayer.pause();
              } else {
                try {
                  print('4. [Playback] Attempting to resume audio: ${widget.audioUrl}');
                  await _audioPlayer.resume();
                  print('4. [Playback] Resume succeeded.');
                } catch (e) {
                  print('🚨 4. [Playback] Resume failed: $e');
                  try {
                    print('4. [Playback] Attempting to play URL: ${widget.audioUrl}');
                    await _audioPlayer.play(UrlSource(widget.audioUrl));
                    print('4. [Playback] Play() succeeded.');
                  } catch (webError) {
                    print('🚨 4. [Playback] Fallback play failed: $webError');
                  }
                }
              }
            },
          ),
          Expanded(
            child: Slider(
              min: 0,
              max: maxDuration,
              value: currentPosition,
              activeColor: Colors.white,
              inactiveColor: Colors.white54,
              onChanged: (value) async {
                final position = Duration(seconds: value.toInt());
                await _audioPlayer.seek(position);
              },
            ),
          ),
          Text(
            _formatDuration(_position),
            style: const TextStyle(color: Colors.white, fontSize: 12),
          ),
        ],
      ),
    );
  }
}
