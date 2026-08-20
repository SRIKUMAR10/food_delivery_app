import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:audioplayers/audioplayers.dart';

/// Centralized, production-grade arrival detection, audio chime, and haptic feedback service.
/// Features a strict one-shot guard per order to prevent repeated alerts,
/// multi-platform haptic vibration, safe audio synthesizer/chime, and in-app arrival banner.
class ArrivalAlertService {
  ArrivalAlertService._internal();
  static final ArrivalAlertService _instance = ArrivalAlertService._internal();
  static ArrivalAlertService get instance => _instance;

  final Set<String> _alertedOrders = {};
  AudioPlayer? _audioPlayer;

  AudioPlayer get _player => _audioPlayer ??= AudioPlayer();

  /// Checks if an arrival alert has already been fired for this order.
  bool hasAlerted(String orderId) => _alertedOrders.contains(orderId);

  /// Resets the alert guard for an order (e.g. when tracking restarts).
  void resetAlert(String orderId) => _alertedOrders.remove(orderId);

  /// Clears all alerted orders from memory.
  void clearAll() => _alertedOrders.clear();

  /// Triggers the full arrival alert sequence (Haptics + Audio Chime + Floating Banner).
  /// Safe to call repeatedly because it guarantees exact one-time execution per orderId.
  Future<bool> triggerArrivalAlert({
    BuildContext? context,
    required String orderId,
    String? partnerName,
    bool isTamil = false,
  }) async {
    if (orderId.isEmpty || _alertedOrders.contains(orderId)) {
      return false;
    }

    // Mark order as alerted to satisfy strict one-shot guard
    _alertedOrders.add(orderId);

    // 1. Multi-stage Haptic Vibration Sequence
    try {
      await HapticFeedback.heavyImpact();
      await Future.delayed(const Duration(milliseconds: 140));
      await HapticFeedback.vibrate();
      await Future.delayed(const Duration(milliseconds: 140));
      await HapticFeedback.heavyImpact();
    } catch (e) {
      debugPrint('ArrivalAlertService Haptic error: $e');
    }

    // 2. Multi-platform Audio Chime
    try {
      await SystemSound.play(SystemSoundType.alert);
    } catch (_) {}

    try {
      // High-pitch pleasant double chime audio using online CDN / safe asset fallback
      await _player.setVolume(1.0);
      await _player.play(
        UrlSource('https://assets.mixkit.co/active_storage/sfx/2869/2869-preview.mp3'),
        mode: PlayerMode.lowLatency,
      );
    } catch (e) {
      debugPrint('ArrivalAlertService Audio chime error: $e');
    }

    // 3. Floating In-App Arrival Banner
    if (context != null && context.mounted) {
      final name = (partnerName != null && partnerName.trim().isNotEmpty)
          ? partnerName.trim()
          : (isTamil ? 'டெலிவரி பார்ட்னர்' : 'Your Delivery Partner');

      final title = isTamil
          ? '⚡ $name உங்கள் வாசலை அடைந்துவிட்டார்!'
          : '⚡ Ding Dong! $name is at your doorstep!';

      final subtitle = isTamil
          ? 'தயவுசெய்து உங்கள் ஆர்டரைப் பெற்றுக்கொள்ளவும்.'
          : 'Please collect your delicious food order.';

      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: const BoxDecoration(
                    color: Color(0xFFF59E0B),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.notifications_active_rounded,
                    color: Colors.white,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: const TextStyle(
                          fontSize: 11.5,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            backgroundColor: const Color(0xFF0F172A),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: const BorderSide(color: Color(0xFFF59E0B), width: 1.5),
            ),
            duration: const Duration(seconds: 5),
            margin: const EdgeInsets.only(bottom: 24, left: 16, right: 16),
          ),
        );
    }

    return true;
  }

  void dispose() {
    _audioPlayer?.dispose();
    _audioPlayer = null;
  }
}
