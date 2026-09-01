import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../core/theme/delivery_app_colors.dart';

/// Senior-grade, cross-platform image picker & file explorer utility.
/// Supports Mobile (Android/iOS Camera & Gallery), Desktop (Windows/macOS/Linux File Explorer),
/// Tablet, and Web with instant memory byte extraction and optimization.
class DeliveryImagePickerHelper {
  DeliveryImagePickerHelper._();

  static final ImagePicker _imagePicker = ImagePicker();

  /// Opens an adaptive, cross-platform picker sheet or dialog.
  /// - Mobile: Shows Camera, Photo Gallery, and System Folder/File Explorer options.
  /// - Desktop / Web / Tablet: Directly opens the native OS File Explorer or modal options.
  static Future<void> showPicker({
    required BuildContext context,
    required String title,
    required Function(Uint8List bytes, String fileName) onImagePicked,
    bool allowPdf = false,
    bool enableCamera = true,
  }) async {
    final isMobile = !kIsWeb &&
        (defaultTargetPlatform == TargetPlatform.android ||
            defaultTargetPlatform == TargetPlatform.iOS);

    if (isMobile) {
      await showModalBottomSheet<void>(
        context: context,
        backgroundColor: DeliveryAppColors.surface,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        builder: (sheetCtx) => SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Upload $title',
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: DeliveryAppColors.textPrimary,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close,
                            color: DeliveryAppColors.textSecondary, size: 20),
                        onPressed: () => Navigator.pop(sheetCtx),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                if (enableCamera)
                  ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: DeliveryAppColors.primary.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.camera_alt_outlined,
                          color: DeliveryAppColors.primary, size: 22),
                    ),
                    title: const Text('Take Live Photo (Camera)',
                        style: TextStyle(
                            color: DeliveryAppColors.textPrimary,
                            fontWeight: FontWeight.w600,
                            fontSize: 14)),
                    subtitle: const Text('Capture photo directly with device camera',
                        style: TextStyle(
                            color: DeliveryAppColors.textSecondary,
                            fontSize: 12)),
                    onTap: () async {
                      Navigator.pop(sheetCtx);
                      await pickFromCamera(
                          context: context, onImagePicked: onImagePicked);
                    },
                  ),
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: DeliveryAppColors.success.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.photo_library_outlined,
                        color: DeliveryAppColors.success, size: 22),
                  ),
                  title: const Text('Photo Gallery',
                      style: TextStyle(
                          color: DeliveryAppColors.textPrimary,
                          fontWeight: FontWeight.w600,
                          fontSize: 14)),
                  subtitle: const Text('Choose image from device photo albums',
                      style: TextStyle(
                          color: DeliveryAppColors.textSecondary,
                          fontSize: 12)),
                  onTap: () async {
                    Navigator.pop(sheetCtx);
                    await pickFromGallery(
                        context: context, onImagePicked: onImagePicked);
                  },
                ),
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.blueAccent.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.folder_open_outlined,
                        color: Colors.blueAccent, size: 22),
                  ),
                  title: const Text('Browse Folders & Files (Explorer)',
                      style: TextStyle(
                          color: DeliveryAppColors.textPrimary,
                          fontWeight: FontWeight.w600,
                          fontSize: 14)),
                  subtitle: const Text('Browse local document folders & file manager',
                      style: TextStyle(
                          color: DeliveryAppColors.textSecondary,
                          fontSize: 12)),
                  onTap: () async {
                    Navigator.pop(sheetCtx);
                    await pickFromFileExplorer(
                      context: context,
                      onImagePicked: onImagePicked,
                      allowPdf: allowPdf,
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      );
    } else {
      // Desktop / Web / Tablet Dialog with Camera + File Explorer
      await showDialog<void>(
        context: context,
        builder: (dialogCtx) => Dialog(
          backgroundColor: DeliveryAppColors.surface,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 440),
            child: Padding(
              padding: const EdgeInsets.all(22),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Upload $title',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: DeliveryAppColors.textPrimary,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close,
                            color: DeliveryAppColors.textSecondary, size: 20),
                        onPressed: () => Navigator.pop(dialogCtx),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  ListTile(
                    tileColor: DeliveryAppColors.background,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                    leading: const Icon(Icons.folder_open,
                        color: DeliveryAppColors.primary, size: 26),
                    title: const Text('Browse Desktop Files / Folder',
                        style: TextStyle(
                            color: DeliveryAppColors.textPrimary,
                            fontWeight: FontWeight.bold,
                            fontSize: 14)),
                    subtitle: const Text('Open Windows / macOS file explorer',
                        style: TextStyle(
                            color: DeliveryAppColors.textSecondary,
                            fontSize: 12)),
                    onTap: () async {
                      Navigator.pop(dialogCtx);
                      await pickFromFileExplorer(
                        context: context,
                        onImagePicked: onImagePicked,
                        allowPdf: allowPdf,
                      );
                    },
                  ),
                  if (enableCamera) ...[
                    const SizedBox(height: 10),
                    ListTile(
                      tileColor: DeliveryAppColors.background,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                      leading: const Icon(Icons.camera_alt,
                          color: DeliveryAppColors.success, size: 26),
                      title: const Text('Capture with Webcam / Camera',
                          style: TextStyle(
                              color: DeliveryAppColors.textPrimary,
                              fontWeight: FontWeight.bold,
                              fontSize: 14)),
                      subtitle: const Text('Take instant photo from webcam',
                          style: TextStyle(
                              color: DeliveryAppColors.textSecondary,
                              fontSize: 12)),
                      onTap: () async {
                        Navigator.pop(dialogCtx);
                        await pickFromCamera(
                            context: context, onImagePicked: onImagePicked);
                      },
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      );
    }
  }

  /// Picks directly from Camera
  static Future<void> pickFromCamera({
    required BuildContext context,
    required Function(Uint8List bytes, String fileName) onImagePicked,
  }) async {
    try {
      final XFile? file = await _imagePicker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1600,
        maxHeight: 1600,
        imageQuality: 85,
      );
      if (file != null) {
        final bytes = await file.readAsBytes();
        onImagePicked(bytes, file.name);
      }
    } catch (e) {
      _showError(context, 'Camera capture error: $e');
    }
  }

  /// Picks directly from Photo Gallery
  static Future<void> pickFromGallery({
    required BuildContext context,
    required Function(Uint8List bytes, String fileName) onImagePicked,
  }) async {
    try {
      final XFile? file = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1600,
        maxHeight: 1600,
        imageQuality: 85,
      );
      if (file != null) {
        final bytes = await file.readAsBytes();
        onImagePicked(bytes, file.name);
      }
    } catch (e) {
      _showError(context, 'Gallery selection error: $e');
    }
  }

  /// Picks directly from OS File Explorer / Folder (Windows / macOS / Linux / Android / iOS / Web)
  static Future<void> pickFromFileExplorer({
    required BuildContext context,
    required Function(Uint8List bytes, String fileName) onImagePicked,
    bool allowPdf = false,
  }) async {
    try {
      final allowed = ['jpg', 'jpeg', 'png', 'webp', 'heic'];
      if (allowPdf) allowed.add('pdf');

      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: allowed,
        withData: true,
      );

      if (result != null && result.files.isNotEmpty) {
        final platformFile = result.files.first;
        Uint8List? bytes = platformFile.bytes;
        if (bytes == null && platformFile.path != null && !kIsWeb) {
          final file = File(platformFile.path!);
          if (await file.exists()) {
            bytes = await file.readAsBytes();
          }
        }

        if (bytes != null && bytes.isNotEmpty) {
          onImagePicked(bytes, platformFile.name);
        } else {
          _showError(context, 'Selected file could not be read.');
        }
      }
    } catch (e) {
      _showError(context, 'File explorer error: $e');
    }
  }

  static void _showError(BuildContext context, String msg) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(msg),
          backgroundColor: DeliveryAppColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }
}

/// High-Performance Cached & Lazy Loaded Image Widget for Delivery Partner UI.
/// Supports Memory Bytes (Instant rendering without decode lag), Network URLs (with memory caching & shimmer),
/// and error fallbacks.
class DeliveryFastImage extends StatelessWidget {
  final String? imageUrl;
  final Uint8List? imageBytes;
  final double? width;
  final double? height;
  final BoxFit fit;
  final double borderRadius;
  final bool isCircle;
  final Widget? placeholder;
  final Widget? errorWidget;

  const DeliveryFastImage({
    super.key,
    this.imageUrl,
    this.imageBytes,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius = 12.0,
    this.isCircle = false,
    this.placeholder,
    this.errorWidget,
  });

  @override
  Widget build(BuildContext context) {
    Widget content;

    final int? safeCacheWidth = (width != null && width!.isFinite && width! > 0 && width! < 4000)
        ? (width! * 2).toInt()
        : null;
    final int? safeCacheHeight = (height != null && height!.isFinite && height! > 0 && height! < 4000)
        ? (height! * 2).toInt()
        : null;

    if (imageBytes != null && imageBytes!.isNotEmpty) {
      content = Image.memory(
        imageBytes!,
        key: ValueKey<int>(imageBytes.hashCode),
        width: width,
        height: height,
        fit: fit,
        gaplessPlayback: true,
        filterQuality: FilterQuality.medium,
        cacheWidth: safeCacheWidth,
        cacheHeight: safeCacheHeight,
        errorBuilder: (_, __, ___) =>
            errorWidget ?? _buildDefaultError(),
      );
    } else if (imageUrl != null && imageUrl!.trim().isNotEmpty) {
      final cleanUrl = imageUrl!.trim();
      if (cleanUrl.startsWith('data:image')) {
        try {
          final base64String = cleanUrl.split(',').last;
          final decodedBytes = base64Decode(base64String);
          content = Image.memory(
            decodedBytes,
            width: width,
            height: height,
            fit: fit,
            gaplessPlayback: true,
            errorBuilder: (_, __, ___) =>
                errorWidget ?? _buildDefaultError(),
          );
        } catch (_) {
          content = errorWidget ?? _buildDefaultError();
        }
      } else if (cleanUrl.startsWith('http://') ||
          cleanUrl.startsWith('https://') ||
          cleanUrl.startsWith('blob:')) {
        content = CachedNetworkImage(
          key: ValueKey<String>(cleanUrl),
          imageUrl: cleanUrl,
          width: width,
          height: height,
          fit: fit,
          memCacheWidth: safeCacheWidth,
          memCacheHeight: safeCacheHeight,
          fadeInDuration: const Duration(milliseconds: 200),
          placeholder: (ctx, url) =>
              placeholder ?? _buildDefaultShimmer(),
          errorWidget: (ctx, url, error) {
            return Image.network(
              cleanUrl,
              width: width,
              height: height,
              fit: fit,
              errorBuilder: (_, __, ___) =>
                  errorWidget ?? _buildDefaultError(),
            );
          },
        );
      } else {
        if (!kIsWeb) {
          content = Image.file(
            File(cleanUrl),
            key: ValueKey<String>(cleanUrl),
            width: width,
            height: height,
            fit: fit,
            gaplessPlayback: true,
            errorBuilder: (_, __, ___) =>
                errorWidget ?? _buildDefaultError(),
          );
        } else {
          content = Image.network(
            cleanUrl,
            width: width,
            height: height,
            fit: fit,
            errorBuilder: (_, __, ___) =>
                errorWidget ?? _buildDefaultError(),
          );
        }
      }
    } else {
      content = placeholder ?? _buildDefaultPlaceholder();
    }

    if (isCircle) {
      return ClipOval(child: content);
    }

    if (borderRadius > 0) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: content,
      );
    }

    return content;
  }

  Widget _buildDefaultShimmer() {
    return Container(
      width: width,
      height: height,
      color: DeliveryAppColors.surface,
      child: const Center(
        child: SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(DeliveryAppColors.primary),
          ),
        ),
      ),
    );
  }

  Widget _buildDefaultError() {
    return Container(
      width: width,
      height: height,
      color: DeliveryAppColors.surface,
      child: const Center(
        child: Icon(
          Icons.broken_image_outlined,
          color: DeliveryAppColors.textSecondary,
          size: 24,
        ),
      ),
    );
  }

  Widget _buildDefaultPlaceholder() {
    return Container(
      width: width,
      height: height,
      color: DeliveryAppColors.surface,
      child: const Center(
        child: Icon(
          Icons.image_outlined,
          color: DeliveryAppColors.textSecondary,
          size: 24,
        ),
      ),
    );
  }
}
