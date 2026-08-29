import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'seller_ui_tokens.dart';

/// Centralized modern dialog for the entire Seller BLoC Architecture.
///
/// Ensures 100% uniform design, border radius (20px), typography,
/// button heights, and hover/active states across all 10 seller pages.
class SellerUnifiedDialog extends StatelessWidget {
  final IconData? icon;
  final Color? iconColor;
  final Color? iconBackgroundColor;
  final String title;
  final String? message;
  final Widget? content;
  final String cancelLabel;
  final String confirmLabel;
  final bool isDanger;
  final bool isLoading;
  final bool showCancel;
  final VoidCallback? onCancel;
  final VoidCallback? onConfirm;
  final List<Widget>? customActions;

  const SellerUnifiedDialog({
    super.key,
    this.icon,
    this.iconColor,
    this.iconBackgroundColor,
    required this.title,
    this.message,
    this.content,
    this.cancelLabel = 'Cancel',
    this.confirmLabel = 'Confirm',
    this.isDanger = false,
    this.isLoading = false,
    this.showCancel = true,
    this.onCancel,
    this.onConfirm,
    this.customActions,
  });

  /// Displays a standardized confirmation dialog returning `true` on confirm and `false` on cancel.
  static Future<bool> showConfirmation(
    BuildContext context, {
    IconData icon = Icons.help_outline_rounded,
    Color? iconColor,
    Color? iconBackgroundColor,
    required String title,
    String? message,
    Widget? content,
    String cancelLabel = 'Cancel',
    String confirmLabel = 'Confirm',
    bool isDanger = false,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (dialogContext) => SellerUnifiedDialog(
        icon: icon,
        iconColor: iconColor ?? (isDanger ? SellerUiTokens.error : SellerUiTokens.brand),
        iconBackgroundColor: iconBackgroundColor ?? (isDanger ? SellerUiTokens.errorLight : SellerUiTokens.brandSurface),
        title: title,
        message: message,
        content: content,
        cancelLabel: cancelLabel,
        confirmLabel: confirmLabel,
        isDanger: isDanger,
        onCancel: () => Navigator.of(dialogContext).pop(false),
        onConfirm: () => Navigator.of(dialogContext).pop(true),
      ),
    );
    return result ?? false;
  }

  /// Displays a danger / destructive confirmation dialog (e.g. Delete, Deactivate, Reject).
  static Future<bool> showDangerConfirmation(
    BuildContext context, {
    IconData icon = Icons.delete_outline_rounded,
    required String title,
    String? message,
    Widget? content,
    String cancelLabel = 'Cancel',
    String confirmLabel = 'Delete',
  }) {
    return showConfirmation(
      context,
      icon: icon,
      iconColor: SellerUiTokens.error,
      iconBackgroundColor: SellerUiTokens.errorLight,
      title: title,
      message: message,
      content: content,
      cancelLabel: cancelLabel,
      confirmLabel: confirmLabel,
      isDanger: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    final Color effectiveIconColor =
        iconColor ?? (isDanger ? SellerUiTokens.error : SellerUiTokens.brand);
    final Color effectiveIconBg =
        iconBackgroundColor ?? (isDanger ? SellerUiTokens.errorLight : SellerUiTokens.brandSurface);
    final Color effectiveConfirmColor =
        isDanger ? SellerUiTokens.error : SellerUiTokens.brand;

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(SellerUiTokens.radiusDialog),
      ),
      elevation: 0,
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: SellerUiTokens.maxWidthDialog),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(SellerUiTokens.radiusDialog),
              boxShadow: SellerUiTokens.dialogShadow,
              border: Border.all(color: SellerUiTokens.borderSubtle),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                if (icon != null) ...[
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: effectiveIconBg,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      icon,
                      color: effectiveIconColor,
                      size: 28,
                    ),
                  ),
                  const SizedBox(height: 18),
                ],
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 19,
                    fontWeight: FontWeight.w700,
                    color: SellerUiTokens.textPrimary,
                  ),
                ),
                if (message != null) ...[
                  const SizedBox(height: 10),
                  Text(
                    message!,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: SellerUiTokens.textSecondary,
                      height: 1.45,
                    ),
                  ),
                ],
                if (content != null) ...[
                  const SizedBox(height: 18),
                  Flexible(
                    child: SingleChildScrollView(
                      child: content!,
                    ),
                  ),
                ],
                const SizedBox(height: 24),
                if (customActions != null)
                  Row(
                    children: customActions!,
                  )
                else
                  Row(
                    children: [
                      if (showCancel) ...[
                        Expanded(
                          child: SizedBox(
                            height: SellerUiTokens.secondaryButtonHeight,
                            child: OutlinedButton(
                              onPressed: isLoading ? null : (onCancel ?? () => Navigator.of(context).pop()),
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(color: SellerUiTokens.borderMuted),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(SellerUiTokens.radiusButton),
                                ),
                                padding: const EdgeInsets.symmetric(vertical: 12),
                              ),
                              child: Text(
                                cancelLabel,
                                style: GoogleFonts.inter(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: SellerUiTokens.textSecondary,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                      ],
                      Expanded(
                        child: SizedBox(
                          height: SellerUiTokens.secondaryButtonHeight,
                          child: ElevatedButton(
                            onPressed: isLoading ? null : onConfirm,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: effectiveConfirmColor,
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(SellerUiTokens.radiusButton),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                            child: isLoading
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  )
                                : Text(
                                    confirmLabel,
                                    style: GoogleFonts.inter(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                    ),
                                  ),
                          ),
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
