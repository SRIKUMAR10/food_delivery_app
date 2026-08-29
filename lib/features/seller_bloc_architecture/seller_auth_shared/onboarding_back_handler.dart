import 'package:flutter/material.dart';

/// Helper to handle back navigation across the multi-step onboarding wizard.
class OnboardingBackHandler {
  /// Prompts the user with an exit confirmation pop-up modal.
  static Future<bool> showExitConfirmationDialog(BuildContext context) async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: const [
            Icon(Icons.help_outline_rounded, color: Color(0xFFF59E0B), size: 28),
            SizedBox(width: 10),
            Expanded(
              child: Text(
                'Exit Store Setup?',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Color(0xFF1E293B)),
              ),
            ),
          ],
        ),
        content: const Text(
          'Your progress so far has been securely saved in drafts. You can log back in anytime to resume setup from this step.',
          style: TextStyle(fontSize: 14, color: Color(0xFF64748B), height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Stay & Continue', style: TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF3B82F6))),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEF4444),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              elevation: 0,
            ),
            child: const Text('Save & Exit', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );

    return result ?? false;
  }

  /// Handles back button press in an onboarding step.
  /// If [previousRoute] is provided, navigates back to that previous onboarding step.
  /// If at the very first step, shows the exit confirmation dialog.
  static Future<void> handleBack(
    BuildContext context, {
    String? previousRoute,
    bool isFirstStep = false,
  }) async {
    if (isFirstStep || previousRoute == null) {
      final shouldExit = await showExitConfirmationDialog(context);
      if (shouldExit && context.mounted) {
        if (Navigator.canPop(context)) {
          Navigator.of(context).pop();
        } else {
          Navigator.pushReplacementNamed(context, '/sellerLogin');
        }
      }
    } else {
      if (Navigator.canPop(context)) {
        Navigator.of(context).pop();
      } else {
        Navigator.pushReplacementNamed(
          context,
          previousRoute,
          arguments: {'isOnboardingFlow': true},
        );
      }
    }
  }
}
