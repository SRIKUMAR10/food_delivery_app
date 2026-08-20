import 'package:flutter/material.dart';

/// Centralized floating SnackBar helper for the whole app.
///
/// Replaces the previously duplicated `_showSnack` implementations found in
/// buyer profile/settings/help/payment screens. Uses a consistent floating,
/// rounded, 16px-margin style with success/error coloring.
class AppSnackBar {
  static void show(
    BuildContext context,
    String message, {
    bool isError = false,
    IconData? icon,
    Duration duration = const Duration(seconds: 3),
  }) {
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(
        SnackBar(
          content: Row(
            children: [
              if (icon != null) ...[
                Icon(icon, color: Colors.white, size: 18),
                const SizedBox(width: 8),
              ],
              Expanded(
                child: Text(
                  message,
                  style: const TextStyle(color: Colors.white, fontSize: 13),
                ),
              ),
            ],
          ),
          backgroundColor: isError ? Colors.red.shade600 : Colors.green.shade600,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          margin: const EdgeInsets.all(16),
          duration: duration,
        ),
      );
  }
}