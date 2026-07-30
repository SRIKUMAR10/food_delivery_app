import 'dart:math';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';

class AudioPlayerWidget extends StatefulWidget {
  final String audioUrl;
  final bool isMe;

  const AudioPlayerWidget({Key? key, required this.audioUrl, this.isMe = false}) : super(key: key);

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
    debugPrint('AudioPlayerWidget initialized with URL: ${widget.audioUrl}');
    
    _initAudio();

    _audioPlayer.onPlayerStateChanged.listen((state) {
      if (_isDisposed) return;
      debugPrint('4. [Playback] PlayerState changed: $state');
      if (mounted) setState(() => _isPlaying = state == PlayerState.playing);
    });

    _audioPlayer.onDurationChanged.listen((newDuration) {
      if (_isDisposed) return;
      debugPrint('4. [Playback] Duration changed: $newDuration');
      if (mounted) setState(() => _duration = newDuration);
    });

    _audioPlayer.onPositionChanged.listen((newPosition) {
      if (_isDisposed) return;
      if (mounted) setState(() => _position = newPosition);
    });
    
    _audioPlayer.onPlayerComplete.listen((event) {
      if (_isDisposed) return;
      debugPrint('4. [Playback] Player Complete');
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
    debugPrint('AudioPlayerWidget AppLifecycleState: $state');
    
    // Pause audio when app goes to background or is hidden
    if (state == AppLifecycleState.paused || 
        state == AppLifecycleState.hidden || 
        state == AppLifecycleState.inactive ||
        state == AppLifecycleState.detached) {
      if (_isPlaying) {
        _audioPlayer.pause().catchError((e) => debugPrint('Error pausing audio: $e'));
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
        debugPrint('AudioPlayer init error: $e');
      }
    }
  }

  @override
  void dispose() {
    _isDisposed = true;
    WidgetsBinding.instance.removeObserver(this);
    try {
      _audioPlayer.dispose();
    } catch (e) {
      debugPrint('AudioPlayer dispose error: $e');
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
    
    final bool isMe = widget.isMe;

    return Container(
      constraints: const BoxConstraints(maxWidth: 300, minWidth: 200),
      height: 56,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isMe 
            ? [Colors.white.withValues(alpha: 0.25), Colors.white.withValues(alpha: 0.15)]
            : [Colors.black.withValues(alpha: 0.08), Colors.black.withValues(alpha: 0.04)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(26),
        border: Border.all(
            color: isMe ? Colors.white.withValues(alpha: 0.3) : Colors.black.withValues(alpha: 0.1),
            width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
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
                    debugPrint('Audio playback resume failed: $webError');
                  }
                }
              }
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: isMe
                    ? (_isPlaying ? Colors.white : Colors.white.withValues(alpha: 0.25))
                    : (_isPlaying ? const Color(0xFF0F172A) : const Color(0xFF0F172A).withValues(alpha: 0.15)),
                shape: BoxShape.circle,
                boxShadow: _isPlaying ? [
                  BoxShadow(
                    color: (isMe ? Colors.white : const Color(0xFF0F172A)).withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ] : null,
              ),
              child: Icon(
                _isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                color: _isPlaying
                    ? (isMe ? const Color(0xFFEF4444) : Colors.white)
                    : (isMe ? Colors.white : const Color(0xFF0F172A)),
                size: 20,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(
                  height: 24,
                  child: CustomPaint(
                    size: const Size(double.infinity, 24),
                    painter: _WaveformPainter(
                      progress: progress,
                      isPlaying: _isPlaying,
                      isMe: isMe,
                    ),
                  ),
                ),
                const SizedBox(height: 2),
                Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    _formatDuration(_position),
                    style: TextStyle(
                      color: isMe 
                          ? Colors.white.withValues(alpha: 0.9) 
                          : const Color(0xFF64748B).withValues(alpha: 0.9),
                      fontSize: 10,
                      height: 1.1,
                      fontWeight: FontWeight.w600,
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
  final bool isMe;

  _WaveformPainter({required this.progress, required this.isPlaying, this.isMe = false});

  @override
  void paint(Canvas canvas, Size size) {
    final barCount = (size.width / 5).floor().clamp(20, 80);
    final barWidth = size.width / barCount;
    final paint = Paint()
      ..strokeWidth = barWidth * 0.6
      ..strokeCap = StrokeCap.round;

    for (int i = 0; i < barCount; i++) {
      final barProgress = (i + 1) / barCount;
      final height = 4 + (i.isEven ? 14 : 8) +
          (sin(i * 0.4 + DateTime.now().millisecondsSinceEpoch / 400) * 4);
      final clampedHeight = height.clamp(4.0, size.height - 2);

      final x = i * barWidth + barWidth * 0.2;
      final y = (size.height - clampedHeight) / 2;

      final isActive = barProgress <= progress;
      if (isMe) {
        paint.color = isActive ? Colors.white : Colors.white.withValues(alpha: 0.4);
      } else {
        paint.color = isActive ? const Color(0xFF0F172A) : const Color(0xFF94A3B8);
      }
      paint.strokeWidth = barWidth * 0.55;

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
