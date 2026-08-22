import 'package:flutter_test/flutter_test.dart';
import 'package:food_delivery_app/core/services/audio_notification_service.dart';

void main() {
  group('AudioNotificationService ringtone mapping', () {
    test('maps all four alert chimes to bundled assets', () {
      expect(AudioNotificationService.ringtoneAssets, {
        'Bell Chime': 'audio/bell_chime.wav',
        'Digital Siren': 'audio/digital_siren.wav',
        'Classic Phone Ring': 'audio/phone_ring.wav',
        'Kitchen Buzzer': 'audio/kitchen_buzzer.wav',
      });
    });

    test('assetForRingtone resolves each supported ringtone', () {
      expect(AudioNotificationService.assetForRingtone('Bell Chime'), 'audio/bell_chime.wav');
      expect(AudioNotificationService.assetForRingtone('Digital Siren'), 'audio/digital_siren.wav');
      expect(AudioNotificationService.assetForRingtone('Classic Phone Ring'), 'audio/phone_ring.wav');
      expect(AudioNotificationService.assetForRingtone('Kitchen Buzzer'), 'audio/kitchen_buzzer.wav');
    });

    test('assetForRingtone falls back to Bell Chime for unknown names', () {
      expect(AudioNotificationService.assetForRingtone('Unknown Siren'), 'audio/bell_chime.wav');
      expect(AudioNotificationService.assetForRingtone(''), 'audio/bell_chime.wav');
    });
  });

  group('AudioNotificationService playback lifecycle', () {
    test('playRingtone, stop and dispose are safe in test environment', () async {
      final service = AudioNotificationService();
      await service.playRingtone(ringtoneName: 'Digital Siren', volume: 0.5, loop: true);
      expect(service.isPreviewPlaying, isFalse);
      await service.stop();
      expect(service.isPreviewPlaying, isFalse);
      service.dispose();
      expect(service.isPreviewPlaying, isFalse);
    });

    test('playRingtone accepts volume bounds and all ringtones without throwing', () async {
      final service = AudioNotificationService();
      for (final name in AudioNotificationService.ringtoneAssets.keys) {
        await service.playRingtone(ringtoneName: name, volume: 0.0);
        await service.playRingtone(ringtoneName: name, volume: 1.0);
      }
      await service.stop();
      service.dispose();
    });

    test('onRingtoneComplete callback does not fire without playback in tests', () async {
      var completed = false;
      final service = AudioNotificationService(
        onRingtoneComplete: () => completed = true,
      );
      await service.playRingtone(ringtoneName: 'Bell Chime');
      await service.stop();
      expect(completed, isFalse);
      service.dispose();
    });

    test('playNewOrderSound runs safely with custom ringtone, volume, loop', () async {
      final service = AudioNotificationService();
      await service.playNewOrderSound(
        ringtoneName: 'Kitchen Buzzer',
        volume: 0.9,
        loop: true,
      );
      await service.stop();
      service.dispose();
    });

    test('setGlobalAudioConfig updates and retrieves global volume and ringtone', () {
      AudioNotificationService.setGlobalAudioConfig(volume: 0.4, ringtone: 'Digital Siren');
      expect(AudioNotificationService.globalVolume, equals(0.4));
      expect(AudioNotificationService.globalRingtone, equals('Digital Siren'));

      AudioNotificationService.setGlobalAudioConfig(volume: 1.5);
      expect(AudioNotificationService.globalVolume, equals(1.0));

      AudioNotificationService.setGlobalAudioConfig(volume: -0.2);
      expect(AudioNotificationService.globalVolume, equals(0.0));
    });
  });
}