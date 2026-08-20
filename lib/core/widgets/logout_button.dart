import 'package:flutter/material.dart';

/// Shared, themeable logout confirmation dialog.
///
/// Centralizes the previously duplicated Logout/AlertDialog implementations
/// across Seller / Buyer / Delivery roles. Callers supply the actual
/// sign-out side effect via [onConfirm] so each role keeps its own BLoC flow.
Future<bool> showLogoutConfirmDialog(
  BuildContext context, {
  required Future<void> Function() onConfirm,
  String? title,
  String? message,
  String? cancelLabel,
  String? confirmLabel,
  Color? confirmColor,
  Color? confirmForegroundColor,
  Color? backgroundColor,
  Color? titleColor,
  Color? contentColor,
  Color? cancelColor,
  String? confirmButtonKey,
  String? cancelButtonKey,
}) async {
  final bool? confirmed = await showDialog<bool>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      backgroundColor: backgroundColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Text(
        title ?? 'Logout',
        style: titleColor == null
            ? null
            : TextStyle(color: titleColor, fontWeight: FontWeight.w700),
      ),
      content: Text(
        message ?? 'Are you sure you want to log out?',
        style: contentColor == null ? null : TextStyle(color: contentColor),
      ),
      actions: [
        TextButton(
          key: cancelButtonKey == null ? null : Key(cancelButtonKey),
          onPressed: () => Navigator.pop(dialogContext, false),
          child: Text(
            cancelLabel ?? 'Cancel',
            style: cancelColor == null ? null : TextStyle(color: cancelColor),
          ),
        ),
        ElevatedButton(
          key: confirmButtonKey == null ? null : Key(confirmButtonKey),
          onPressed: () => Navigator.pop(dialogContext, true),
          style: ElevatedButton.styleFrom(
            backgroundColor: confirmColor ?? const Color(0xFFDC2626),
            foregroundColor: confirmForegroundColor ?? Colors.white,
          ),
          child: Text(
            confirmLabel ?? 'Logout',
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
        ),
      ],
    ),
  );

  if (confirmed ?? false) {
    await onConfirm();
  }
  return confirmed ?? false;
}

/// Shared logout action button used by role navigation bars / menus.
class LogoutButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String label;
  final IconData icon;
  final Color color;

  const LogoutButton({
    Key? key,
    required this.onPressed,
    this.label = 'Logout',
    this.icon = Icons.logout,
    this.color = const Color(0xFFDC2626),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.25)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 10),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}