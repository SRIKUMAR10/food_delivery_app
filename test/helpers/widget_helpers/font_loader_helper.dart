import 'dart:io';
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

void overrideFontAssetLoading() {
  // Disable runtime fetching so google_fonts only looks in assets
  GoogleFonts.config.allowRuntimeFetching = false;

  final fontFile = File(
    'build/unit_test_assets/packages/golden_toolkit/fonts/Roboto-Regular.ttf',
  );
  if (!fontFile.existsSync()) return;
  final bytes = fontFile.readAsBytesSync();

  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMessageHandler('flutter/assets', (ByteData? message) async {
        if (message == null) return null;

        final String assetKey = utf8.decode(
          message.buffer.asUint8List(
            message.offsetInBytes,
            message.lengthInBytes,
          ),
        );

        if (assetKey == 'AssetManifest.bin') {
          Map<dynamic, dynamic> manifestMap = {};

          // Load and decode original manifest if it exists
          final originalPath = 'build/unit_test_assets/AssetManifest.bin';
          final originalFile = File(originalPath);
          if (originalFile.existsSync()) {
            final originalBytes = originalFile.readAsBytesSync();
            final decoded = const StandardMessageCodec().decodeMessage(
              ByteData.sublistView(originalBytes),
            );
            if (decoded is Map) {
              manifestMap = Map<dynamic, dynamic>.from(decoded);
            }
          }

          // Merge Google Fonts into the binary manifest map
          final fonts = [
            "google_fonts/PlusJakartaSans-Regular.ttf",
            "google_fonts/PlusJakartaSans-Medium.ttf",
            "google_fonts/PlusJakartaSans-SemiBold.ttf",
            "google_fonts/PlusJakartaSans-Bold.ttf",
            "google_fonts/PlusJakartaSans-ExtraBold.ttf",
            "google_fonts/PlusJakartaSans-Light.ttf",
            "google_fonts/PlusJakartaSans-Italic.ttf",
            "google_fonts/Inter-Regular.ttf",
            "google_fonts/Inter-Medium.ttf",
            "google_fonts/Inter-SemiBold.ttf",
            "google_fonts/Inter-Bold.ttf",
            "google_fonts/Outfit-Regular.ttf",
            "google_fonts/Outfit-Bold.ttf",
          ];
          for (final font in fonts) {
            manifestMap[font] = [
              {"asset": font},
            ];
          }

          return const StandardMessageCodec().encodeMessage(manifestMap);
        }

        if (assetKey.contains('google_fonts/')) {
          return ByteData.sublistView(bytes).buffer.asByteData();
        }

        // Try to load original file from disk if it exists in common build locations
        final pathsToTry = [
          assetKey,
          'build/unit_test_assets/$assetKey',
          'build/flutter_assets/$assetKey',
        ];
        for (final path in pathsToTry) {
          final file = File(path);
          if (file.existsSync()) {
            final fileBytes = file.readAsBytesSync();
            return ByteData.sublistView(fileBytes).buffer.asByteData();
          }
        }

        return null;
      });
}
