import 'package:flutter/material.dart';

/// Shared confirm dialog with optional danger styling.
///
/// Centralizes the previously duplicated hand-rolled
/// `showDialog` + `AlertDialog` confirmations across seller pages.
/// Returns `true` when the user confirms, `false` on cancel.
Future<bool> showConfirmDialog(
  BuildContext context, {
  required String title,
  String? message,
  String confirmLabel = 'Confirm',
  String cancelLabel = 'Cancel',
  bool danger = false,
  Color? confirmColor,
  String? confirmButtonKey,
  String? cancelButtonKey,
}) async {
  final Color? resolvedConfirmColor = confirmColor ??
      (danger ? const Color(0xFFDC2626) : null);

  final bool? confirmed = await showDialog<bool>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: Text(title),
      content: message == null ? null : Text(message),
      actions: [
        TextButton(
          key: cancelButtonKey == null ? null : Key(cancelButtonKey),
          onPressed: () => Navigator.pop(dialogContext, false),
          child: Text(cancelLabel),
        ),
        ElevatedButton(
          key: confirmButtonKey == null ? null : Key(confirmButtonKey),
          onPressed: () => Navigator.pop(dialogContext, true),
          style: resolvedConfirmColor == null
              ? null
              : ElevatedButton.styleFrom(
                  backgroundColor: resolvedConfirmColor,
                  foregroundColor: Colors.white,
                ),
          child: Text(confirmLabel),
        ),
      ],
    ),
  );

  return confirmed ?? false;
}