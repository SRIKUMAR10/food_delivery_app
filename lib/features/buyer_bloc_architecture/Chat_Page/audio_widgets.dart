import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';
import 'package:food_delivery_app/core/theme/buyer_app_colors.dart';

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

class AudioRecorderWidget extends StatefulWidget {
  final VoidCallback onCancel;
  final void Function(String filePath, Duration duration) onSend;

  const AudioRecorderWidget({
    Key? key,
    required this.onCancel,
    required this.onSend,
  }) : super(key: key);

  @override
  State<AudioRecorderWidget> createState() => _AudioRecorderWidgetState();
}

class _AudioRecorderWidgetState extends State<AudioRecorderWidget>
    with SingleTickerProviderStateMixin {
  final AudioRecorder _recorder = AudioRecorder();
  bool _isRecording = false;
  Duration _elapsed = Duration.zero;
  Timer? _timer;
  late AnimationController _waveController;

  @override
  void initState() {
    super.initState();
    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..repeat(reverse: true);
    _startRecording();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _waveController.dispose();
    _recorder.dispose();
    super.dispose();
  }

  Future<void> _startRecording() async {
    if (await _recorder.hasPermission()) {
      String path;
      if (kIsWeb) {
        path = '';
      } else {
        final dir = await getApplicationDocumentsDirectory();
        path =
            '${dir.path}/audio_${DateTime.now().millisecondsSinceEpoch}.m4a';
      }
      await _recorder.start(
        const RecordConfig(encoder: AudioEncoder.aacLc),
        path: path,
      );
      setState(() => _isRecording = true);
      _elapsed = Duration.zero;
      _timer = Timer.periodic(const Duration(seconds: 1), (_) {
        if (mounted) setState(() => _elapsed += const Duration(seconds: 1));
      });
    }
  }

  Future<void> _stopRecording() async {
    _timer?.cancel();
    final path = await _recorder.stop();
    if (path != null && mounted) {
      widget.onSend(path, _elapsed);
    }
  }

  void _cancelRecording() {
    _timer?.cancel();
    _recorder.stop();
    widget.onCancel();
  }

  String _formatDuration(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFF8F9FB),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.close_rounded, color: Color(0xFF64748B)),
            onPressed: _cancelRecording,
          ),
          const SizedBox(width: 8),
          AnimatedBuilder(
            animation: _waveController,
            builder: (context, _) {
              final amplitude = _isRecording ? _waveController.value : 0.0;
              return CustomPaint(
                size: const Size(32, 24),
                painter: _RecordingWavePainter(amplitude: amplitude),
              );
            },
          ),
          const SizedBox(width: 8),
          Text(
            _formatDuration(_elapsed),
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1C1C1C),
            ),
          ),
          const Spacer(),
          GestureDetector(
            onTap: _stopRecording,
            child: Container(
              width: 44,
              height: 44,
              decoration: const BoxDecoration(
                color: BuyerAppColors.primaryDeep,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.stop_rounded, color: Colors.white, size: 26),
            ),
          ),
        ],
      ),
    );
  }
}

class _RecordingWavePainter extends CustomPainter {
  final double amplitude;
  _RecordingWavePainter({required this.amplitude});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = BuyerAppColors.primaryDeep
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;

    final centerY = size.height / 2;
    final barCount = 5;
    final spacing = size.width / (barCount + 1);

    for (int i = 0; i < barCount; i++) {
      final x = spacing * (i + 1);
      final halfHeight = (3.0 + amplitude * 6.0 * (1 - (i - 2).abs() / 2))
          .clamp(2.0, size.height / 2 - 1);
      canvas.drawLine(
        Offset(x, centerY - halfHeight),
        Offset(x, centerY + halfHeight),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_RecordingWavePainter old) => old.amplitude != amplitude;
}
