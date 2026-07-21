import 'dart:math';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';

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

    final progress = maxDuration > 0 ? currentPosition / maxDuration : 0.0;

    return Container(
      width: 220,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          GestureDetector(
            onTap: () async {
              if (_isPlaying) {
                await _audioPlayer.pause();
              } else {
                try {
                  await _audioPlayer.resume();
                } catch (e) {
                  try {
                    await _audioPlayer.play(UrlSource(widget.audioUrl));
                  } catch (webError) {
                    // silently fail
                  }
                }
              }
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: _isPlaying
                    ? const Color(0xFFEF4444)
                    : const Color(0xFFEF4444).withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(
                _isPlaying
                    ? Icons.pause_rounded
                    : Icons.play_arrow_rounded,
                color: _isPlaying ? Colors.white : const Color(0xFFEF4444),
                size: 18,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  height: 24,
                  child: CustomPaint(
                    size: const Size(double.infinity, 24),
                    painter: _WaveformPainter(
                      progress: progress,
                      isPlaying: _isPlaying,
                    ),
                  ),
                ),
                const SizedBox(height: 2),
                Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    _formatDuration(_position),
                    style: TextStyle(
                      color: const Color(0xFF64748B).withValues(alpha: 0.8),
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _WaveformPainter extends CustomPainter {
  final double progress;
  final bool isPlaying;

  _WaveformPainter({required this.progress, required this.isPlaying});

  @override
  void paint(Canvas canvas, Size size) {
    final barCount = 30;
    final barWidth = size.width / barCount;
    final paint = Paint()
      ..strokeWidth = barWidth * 0.6
      ..strokeCap = StrokeCap.round;

    for (int i = 0; i < barCount; i++) {
      final barProgress = (i + 1) / barCount;
      final height = 4 + (i.isEven ? 12 : 8) +
          (sin(i * 0.5 + DateTime.now().millisecondsSinceEpoch / 500) * 4);
      final clampedHeight = height.clamp(4.0, size.height - 2);

      final x = i * barWidth + barWidth * 0.2;
      final y = (size.height - clampedHeight) / 2;

      final isActive = barProgress <= progress;
      paint.color = isActive
          ? const Color(0xFFEF4444)
          : const Color(0xFFD1D5DB);
      paint.strokeWidth = barWidth * 0.5;

      canvas.drawLine(
        Offset(x, y),
        Offset(x, y + clampedHeight),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_WaveformPainter oldDelegate) => true;
}
