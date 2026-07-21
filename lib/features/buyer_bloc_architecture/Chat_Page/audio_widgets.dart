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

class _AudioPlayerWidgetState extends State<AudioPlayerWidget> with WidgetsBindingObserver {
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isPlaying = false;
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;
  bool _isDisposed = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    print('AudioPlayerWidget initialized with URL: ${widget.audioUrl}');
    
    _initAudio();

    _audioPlayer.onPlayerStateChanged.listen((state) {
      if (_isDisposed) return;
      print('4. [Playback] PlayerState changed: $state');
      if (mounted) setState(() => _isPlaying = state == PlayerState.playing);
    });

    _audioPlayer.onDurationChanged.listen((newDuration) {
      if (_isDisposed) return;
      print('4. [Playback] Duration changed: $newDuration');
      if (mounted) setState(() => _duration = newDuration);
    });

    _audioPlayer.onPositionChanged.listen((newPosition) {
      if (_isDisposed) return;
      if (mounted) setState(() => _position = newPosition);
    });
    
    _audioPlayer.onPlayerComplete.listen((event) {
      if (_isDisposed) return;
      print('4. [Playback] Player Complete');
      if (mounted) {
        setState(() {
          _isPlaying = false;
          _position = Duration.zero;
        });
      }
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (_isDisposed) return;
    print('AudioPlayerWidget AppLifecycleState: $state');
    
    // Pause audio when app goes to background or is hidden
    if (state == AppLifecycleState.paused || 
        state == AppLifecycleState.hidden || 
        state == AppLifecycleState.inactive ||
        state == AppLifecycleState.detached) {
      if (_isPlaying) {
        _audioPlayer.pause().catchError((e) => print('Error pausing audio: $e'));
      }
    }
  }

  Future<void> _initAudio() async {
    try {
      // Set volume to maximum allowed by standard Web browsers (1.0)
      await _audioPlayer.setVolume(1.0);
      if (!_isDisposed) {
        await _audioPlayer.setSource(UrlSource(widget.audioUrl));
      }
    } catch (e) {
      if (!_isDisposed) {
        print('AudioPlayer init error: $e');
      }
    }
  }

  @override
  void dispose() {
    _isDisposed = true;
    WidgetsBinding.instance.removeObserver(this);
    try {
      _audioPlayer.stop().then((_) {
        _audioPlayer.dispose();
      }).catchError((e) {
        _audioPlayer.dispose();
      });
    } catch (e) {
      print('AudioPlayer dispose error: $e');
    }
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
