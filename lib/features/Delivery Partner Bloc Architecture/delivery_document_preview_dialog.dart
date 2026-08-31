import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../../core/theme/delivery_app_colors.dart';
import 'delivery_image_picker_helper.dart';

/// Senior-grade, interactive, zoomable KYC & Documentation Preview Dialog.
/// Allows delivery partners and administrators to click, zoom (1.0x to 5.0x), pan,
/// inspect, and re-upload KYC documents (Driving License, RC Book, Aadhaar, PAN, Selfie).
class DeliveryDocumentPreviewDialog extends StatelessWidget {
  final String title;
  final String? documentUrl;
  final Uint8List? documentBytes;
  final String? docType;
  final String? status;
  final VoidCallback? onReupload;

  const DeliveryDocumentPreviewDialog({
    super.key,
    required this.title,
    this.documentUrl,
    this.documentBytes,
    this.docType,
    this.status,
    this.onReupload,
  });

  /// Displays the interactive document preview dialog
  static Future<void> show({
    required BuildContext context,
    required String title,
    String? documentUrl,
    Uint8List? documentBytes,
    String? docType,
    String? status,
    VoidCallback? onReupload,
  }) {
    return showDialog<void>(
      context: context,
      barrierColor: Colors.black87,
      builder: (dialogCtx) => DeliveryDocumentPreviewDialog(
        title: title,
        documentUrl: documentUrl,
        documentBytes: documentBytes,
        docType: docType,
        status: status,
        onReupload: onReupload,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isPdf = (documentUrl ?? '').toLowerCase().contains('.pdf');
    final isVerified = status == 'verified' || status == 'approved';

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 680, maxHeight: 720),
          decoration: BoxDecoration(
            color: DeliveryAppColors.surface,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: DeliveryAppColors.border),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.4),
                blurRadius: 28,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Row
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: isVerified
                          ? DeliveryAppColors.success.withOpacity(0.15)
                          : DeliveryAppColors.primary.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      isPdf
                          ? Icons.picture_as_pdf_rounded
                          : (isVerified
                              ? Icons.verified_user_rounded
                              : Icons.description_rounded),
                      color: isVerified
                          ? DeliveryAppColors.success
                          : DeliveryAppColors.primary,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                            color: DeliveryAppColors.textPrimary,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 3),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: (isVerified
                                        ? DeliveryAppColors.success
                                        : DeliveryAppColors.warning)
                                    .withOpacity(0.12),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                isVerified
                                    ? 'VERIFIED KYC DOCUMENT'
                                    : 'OFFICIAL DOCUMENT PROOF',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  color: isVerified
                                      ? DeliveryAppColors.success
                                      : DeliveryAppColors.warning,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  if (onReupload != null)
                    TextButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        onReupload!();
                      },
                      icon: const Icon(Icons.refresh, size: 16),
                      label: const Text('Change',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      style: TextButton.styleFrom(
                        foregroundColor: DeliveryAppColors.primary,
                      ),
                    ),
                  IconButton(
                    tooltip: 'Close',
                    icon: const Icon(Icons.close,
                        color: DeliveryAppColors.textSecondary),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Divider(color: DeliveryAppColors.border, height: 1),
              const SizedBox(height: 16),

              // Interactive Zoomable Viewer Body
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    width: double.infinity,
                    color: const Color(0xFF070E14),
                    child: Stack(
                      children: [
                        InteractiveViewer(
                          minScale: 1.0,
                          maxScale: 5.0,
                          panEnabled: true,
                          scaleEnabled: true,
                          child: Center(
                            child: isPdf
                                ? Padding(
                                    padding: const EdgeInsets.all(24),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        const Icon(
                                          Icons.picture_as_pdf,
                                          size: 80,
                                          color: Colors.redAccent,
                                        ),
                                        const SizedBox(height: 16),
                                        Text(
                                          title,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                        const SizedBox(height: 8),
                                        const Text(
                                          'PDF Document Uploaded Successfully',
                                          style: TextStyle(
                                            color: DeliveryAppColors.textSecondary,
                                            fontSize: 13,
                                          ),
                                        ),
                                      ],
                                    ),
                                  )
                                : Center(
                                    child: DeliveryFastImage(
                                      imageUrl: documentUrl,
                                      imageBytes: documentBytes,
                                      fit: BoxFit.contain,
                                      placeholder: const Center(
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2.5,
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                                  DeliveryAppColors.primary),
                                        ),
                                      ),
                                      errorWidget: const Center(
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Icon(Icons.broken_image_outlined,
                                                size: 48,
                                                color: DeliveryAppColors.error),
                                            SizedBox(height: 10),
                                            Text(
                                              'Document image unavailable',
                                              style: TextStyle(
                                                  color: DeliveryAppColors
                                                      .textSecondary,
                                                  fontSize: 13),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                          ),
                        ),
                        // Zoom Instruction Helper Badge
                        Positioned(
                          bottom: 12,
                          right: 12,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.65),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.zoom_in,
                                    color: Colors.white70, size: 14),
                                SizedBox(width: 4),
                                Text(
                                  'Pinch to Zoom 1.0x - 5.0x',
                                  style: TextStyle(
                                      color: Colors.white70, fontSize: 11),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 14),

              // Footer with Storage Path Details & Security Guarantee
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: DeliveryAppColors.background,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: DeliveryAppColors.border),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.lock_outline,
                        color: DeliveryAppColors.success, size: 16),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text(
                        'Stored securely in Firebase Cloud Storage & Firestore with encrypted KYC protection.',
                        style: TextStyle(
                          color: DeliveryAppColors.textSecondary,
                          fontSize: 11.5,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: DeliveryAppColors.primary,
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 10),
                      ),
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Done',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
